
using Gee;
using Vala;

public class CtypesWriter : CodeVisitor {

	protected CodeContext context;
	protected Gee.List<SourceFile> source_files;
	protected weak FileStream stream;

	private PyCode.Class? current_class;

	private PyCode.Fragment wrapper_fragment = new PyCode.Fragment();
	private PyCode.Fragment delegate_fragment = new PyCode.Fragment();
	private PyCode.Fragment binding_fragment = new PyCode.Fragment();

	public void write_file(CodeContext context, Gee.List<SourceFile> source_files, string filename) {
		var stream = FileStream.open(filename, "w");

		stream.printf("from ctypes import *\n\n");
		stream.printf("lib = CDLL('libsyncml.so')\n\n");

		stream.printf("def instancemethod(method):\n");
		stream.printf("    def _(self, *args, **kwargs):\n");
		stream.printf("        return method(self, *args, **kwargs)\n");
		stream.printf("    return _\n\n");

		write_segment(context, source_files, stream);
	}

	protected bool interesting(CodeNode node) {
		if (node.source_reference == null)
			return true;

		foreach (var sr in source_files)
			if (node.source_reference.file == sr)
				return true;

		return false;
	}

	public override void visit_namespace (Namespace ns) {
		if (interesting(ns))
			ns.accept_children(this);
	}

	private void ctypes_set_arg_types(string lib, string name, PyCode.List list) {
		var l = new PyCode.Identifier("%s.%s.argtypes".printf(lib, name));
		binding_fragment.append(new PyCode.Assignment(l, list));
	}

	private void ctypes_set_return_type(string lib, string name, string type) {
		var l = new PyCode.Identifier("%s.%s.restype".printf(lib, name));
		var r = new PyCode.Identifier(type);
		binding_fragment.append(new PyCode.Assignment(l, r));
	}

	private DataType get_data_type_for_symbol (TypeSymbol sym) {
		DataType type = null;

		if (sym is Class) {
			type = new ObjectType ((Class) sym);
		} else if (sym is Interface) {
			type = new ObjectType ((Interface) sym);
		} else if (sym is Struct) {
			var st = (Struct) sym;
			if (st.is_boolean_type ()) {
				type = new BooleanType (st);
			} else if (st.is_integer_type ()) {
				type = new IntegerType (st);
			} else if (st.is_floating_type ()) {
				type = new FloatingType (st);
			} else {
				type = new StructValueType (st);
			}
		} else if (sym is Enum) {
			type = new EnumValueType ((Enum) sym);
		} else if (sym is ErrorDomain) {
			type = new Vala.ErrorType ((ErrorDomain) sym, null);
		} else if (sym is ErrorCode) {
			type = new Vala.ErrorType ((ErrorDomain) sym.parent_symbol, (ErrorCode) sym);
		} else {
			Report.error (null, "internal error: `%s' is not a supported type".printf (sym.get_full_name ()));
			return new InvalidType ();
		}

		return type;
	}

	private string get_type_string(DataType type) {
		if (type is ArrayType) {
			return "None";
		} else if (type is VoidType) {
			return "None";
		} else if (type is EnumValueType) {
			return "c_int";
		} else {
			var t = type.to_string();
			switch (t) {
				case "string":
				case "char*":
					return "c_char_p";
				case "char":
					return "c_char";
				case "int":
					return "c_int";
				case "uint":
					return "c_uint";
				case "bool":
					return "c_int";
				case "void*":
					return "c_void_p";
				case "long":
					return "c_long";
				case "ulong":
					return "c_ulong";
				default:
					uint j = 0;
					char *l = (char *)t;
					for (uint i = 0; i < t.len(); i++)
						if (l[i] == '.')
							j = i+1;

					if (l[t.len()-1] == '*')
						return "POINTER(%s)".printf(t.substring(j, t.len()-j-1));
					else
						return t.substring(j, t.len()-j);
			}
		}
	}

	private string get_param_type(FormalParameter p) {
		if (p.direction == ParameterDirection.REF || p.direction == ParameterDirection.OUT)
			return "POINTER(%s)".printf(get_type_string(p.parameter_type));
		return get_type_string(p.parameter_type);
	}

	public new void write_segment(CodeContext context, Gee.List<SourceFile> source_files, FileStream stream) {
		this.context = context;
		this.source_files = source_files;

		context.accept (this);

		var writer = new PyCode.Writer (stream);
		wrapper_fragment.write (writer);
		delegate_fragment.write (writer);
		binding_fragment.write (writer);
	}

	public override void visit_class(Class cl) {
		if (!interesting(cl))
			return;

		current_class = new PyCode.Class(cl.name);
		current_class.parent_class = "c_void_p";
		wrapper_fragment.append(current_class);

		cl.accept_children(this);

		current_class = null;
	}

	public override void visit_method(Method me) {
		var l = new PyCode.Identifier(me.name);
		var r = new PyCode.Identifier("lib.%s".printf(me.get_cname())) as PyCode.Expression;

		if (current_class != null) {
			PyCode.Identifier id;

			if (me.binding == MemberBinding.INSTANCE)
				id = new PyCode.Identifier("instancemethod");
			else
				id = new PyCode.Identifier("staticmethod");

			var r2 = new PyCode.FunctionCall(id);
			r2.add_argument(r);

			r = r2;
		}

		var assignment = new PyCode.Assignment(l, r);

		if (current_class != null)
			current_class.add_member(assignment);
		else
			wrapper_fragment.append(assignment);

		var lst = new PyCode.List();
		if (me.binding == MemberBinding.INSTANCE) {
			var instance_type = get_data_type_for_symbol ((TypeSymbol) me.parent_symbol);
			lst.append(new PyCode.Identifier(get_type_string(instance_type)));
		}
		foreach (var a in me.get_parameters())
			lst.append(new PyCode.Identifier(get_param_type(a)));
		ctypes_set_arg_types("lib", me.get_cname(), lst);

		ctypes_set_return_type("lib", me.get_cname(), get_type_string(me.return_type));
	}

	public override void visit_creation_method(CreationMethod cr) {
		assert(current_class != null);

		var l = new PyCode.Identifier(cr.name);
		var r = new PyCode.FunctionCall(new PyCode.Identifier("staticmethod"));
		r.add_argument(new PyCode.Identifier("lib.%s".printf(cr.get_cname())));
		current_class.add_member(new PyCode.Assignment(l, r));

		var lst = new PyCode.List();
		foreach (var p in cr.get_parameters())
			lst.append(new PyCode.Identifier(get_param_type(p)));
		ctypes_set_arg_types("lib", cr.get_cname(), lst);

		var t = get_data_type_for_symbol((TypeSymbol) cr.parent_symbol);
		ctypes_set_return_type("lib", cr.get_cname(), get_type_string(t));
	}

	public override void visit_property(Property pr) {
		var instance_type = get_data_type_for_symbol ((TypeSymbol) pr.parent_symbol);

		if (pr.get_accessor != null) {
			// Attach the getter to a class object
			var l = new PyCode.Identifier("get_%s".printf(pr.name));
			var r = new PyCode.FunctionCall(new PyCode.Identifier("instancemethod"));
			r.add_argument(new PyCode.Identifier("lib.%s".printf(pr.get_accessor.get_cname())));
			current_class.add_member(new PyCode.Assignment(l, r));

			var lst = new PyCode.List();
			lst.append(new PyCode.Identifier(get_type_string(instance_type)));
			ctypes_set_arg_types("lib", pr.get_accessor.get_cname(), lst);

			ctypes_set_return_type("lib", pr.get_accessor.get_cname(), get_type_string(pr.property_type));
		}
		if (pr.set_accessor != null) {
			// Attach the setter to the class object
			var l = new PyCode.Identifier("set_%s".printf(pr.name));
			var r = new PyCode.FunctionCall(new PyCode.Identifier("instancemethod"));
			r.add_argument(new PyCode.Identifier("lib.%s".printf(pr.set_accessor.get_cname())));
			current_class.add_member(new PyCode.Assignment(l, r));

			var lst = new PyCode.List();
			lst.append(new PyCode.Identifier(get_type_string(instance_type)));
			lst.append(new PyCode.Identifier(get_type_string(pr.property_type)));
			ctypes_set_arg_types("lib", pr.set_accessor.get_cname(), lst);

			ctypes_set_return_type("lib", pr.set_accessor.get_cname(), "None");
		}

		var l = new PyCode.Identifier(pr.name);
		var r = new PyCode.FunctionCall(new PyCode.Identifier("property"));

		if (pr.get_accessor != null)
			r.add_argument(new PyCode.Identifier("fget=get_%s".printf(pr.name)));
		if (pr.set_accessor != null)
			r.add_argument(new PyCode.Identifier("fset=set_%s".printf(pr.name)));

		current_class.add_member(new PyCode.Assignment(l, r));
	}

	public override void visit_delegate(Delegate de) {
		var l = new PyCode.Identifier(de.name);
		var r = new PyCode.FunctionCall(new PyCode.Identifier("CFUNCTYPE"));
		r.add_argument(new PyCode.Identifier(get_type_string(de.return_type)));
		foreach (var p in de.get_parameters())
			r.add_argument(new PyCode.Identifier(get_param_type(p)));

		delegate_fragment.append(new PyCode.Assignment(l, r));
	}
}

