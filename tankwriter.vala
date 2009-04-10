
using Gee;
using Vala;

public class TankWriter : CodeVisitor {
	public void write_file(CodeContext context, Gee.List<SourceFile> source_files, string filename) {
		var stream = FileStream.open(filename, "w");
		var cstream = FileStream.open(filename+".c", "w");

		stream.printf("from ctypes import *\n\n");
		stream.printf("lib = CDLL('libsyncml.so')\n\n");

		stream.printf("def instancemethod(method):\n");
		stream.printf("    def _(self, *args, **kwargs):\n");
		stream.printf("        return method(self, *args, **kwargs)\n");
		stream.printf("    return _\n\n");

		var wg = new WrapperWriter();
		wg.write_segment(context, source_files, stream);

		var dg = new DelegateWriter();
		dg.write_segment(context, source_files, stream);

		var bg = new BindingWriter();
		bg.write_segment(context, source_files, stream);

		// FIXME: We can totally work out what headers to pull in from the VAPI!
		cstream.printf("#include <stdio.h>\n");
		cstream.printf("#include <libsyncml/data_sync_api/standard.h>\n");
		cstream.printf("#include <libsyncml/data_sync_api/defines.h>\n");

		cstream.printf("int main (int argc, char ** argv) {\n");

		var ew = new EnumsAndConstsWriter();
		ew.write_segment(context, source_files, cstream);

		cstream.printf("return 0;\n");
		cstream.printf("}\n");
	}
}

public class SegmentWriter : CodeVisitor {

	protected CodeContext context;
	protected Gee.List<SourceFile> source_files;
	protected weak FileStream stream;

	protected uint indent = 0;

	public void write_segment(CodeContext context, Gee.List<SourceFile> source_files, FileStream stream) {
		this.context = context;
		this.source_files = source_files;
		this.stream = stream;

		context.accept(this);
	}

	protected bool interesting(CodeNode node) {
		if (node.source_reference == null)
			return true;

		foreach (var sr in source_files)
			if (node.source_reference.file == sr)
				return true;

		return false;
	}

	protected void write_indent() {
		for (uint i = 0; i < this.indent; i++)
			this.stream.printf("    ");
	}

	public static DataType get_data_type_for_symbol (TypeSymbol sym) {
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

	protected void write_type(DataType type) {
		if (type is ArrayType) {
			stream.printf("None");
		} else if (type is VoidType) {
			stream.printf("None");
		} else if (type is EnumValueType) {
			stream.printf("c_int");
		} else {
			var t = type.to_string();
			switch (t) {
				case "string":
				case "char*":
					stream.printf("c_char_p");
					break;
				case "char":
					stream.printf("c_char");
					break;
				case "int":
					stream.printf("c_int");
					break;
				case "uint":
					stream.printf("c_uint");
					break;
				case "bool":
					stream.printf("c_int");
					break;
				case "void*":
					stream.printf("c_void_p");
					break;
				case "long":
					stream.printf("c_long");
					break;
				case "ulong":
					stream.printf("c_ulong");
					break;
				default:
					uint j = 0;
					char *l = (char *)t;
					for (uint i = 0; i < t.len(); i++)
						if (l[i] == '.')
							j = i+1;

					if (l[t.len()-1] == '*')
						stream.printf("POINTER(%s)", t.substring(j, t.len()-j-1));
					else
						stream.printf(t.substring(j, t.len()-j));
					break;
			}
		}
	}

	protected void write_params(Gee.List<FormalParameter> params, bool first = true) {
		foreach(var p in params) {
			if (!first)
				stream.printf(", ");
			first = false;

			if (p.direction == ParameterDirection.REF || p.direction == ParameterDirection.OUT) {
				stream.printf("POINTER(");
				write_type(p.parameter_type);
				stream.printf(")");
			} else {
				write_type(p.parameter_type);
			}

		}
	}

	protected void write_call(string cname, DataType ?instance_type, Gee.List<FormalParameter> ?params, DataType ?return_type) {
		stream.printf("lib.%s.argtypes = [", cname);
		bool first = true;
		if (instance_type != null) {
			write_type(instance_type);
			first = false;
		}
		if (params != null)
			write_params(params, first);
		stream.printf("]\n");

		if (return_type != null) {
			stream.printf("lib.%s.restype = ", cname);
			write_type(return_type);
			stream.printf("\n");
		}

		stream.printf("\n");
	}


	public override void visit_namespace (Namespace ns) {
		if (interesting(ns))
			ns.accept_children(this);
	}
}

public class EnumsAndConstsWriter : SegmentWriter {

	public override void visit_enum (Enum en) {
		en.accept_children(this);
		stream.printf("\n");
	}

	private void write_declaration(string cname, string datatype) {
		stream.printf("printf(\"%s = %s\\n\", %s);\n", cname, datatype, cname);
	}

	public override void visit_enum_value(Vala.EnumValue ev) {
		if (interesting(ev))
			write_declaration(ev.get_cname(), "%d");
	}

	public override void visit_constant(Constant co) {
		if (interesting(co))
			write_declaration(co.get_cname(), "\\\"%s\\\"");
	}
}

public class WrapperWriter : SegmentWriter {

	PyCode.Class? current_class;

	PyCode.Fragment wrapper_fragment = new PyCode.Fragment();

	public new void write_segment(CodeContext context, Gee.List<SourceFile> source_files, FileStream stream) {
		this.context = context;
		this.source_files = source_files;

		context.accept (this);

		var writer = new PyCode.Writer (stream);
		wrapper_fragment.write (writer);
	}

	public override void visit_class(Class cl) {
		if (!interesting(cl))
			return;

		current_class = new PyCode.Class(cl.name);
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
	}

	public override void visit_creation_method(CreationMethod cr) {
		assert(current_class != null);

		var l = new PyCode.Identifier(cr.name);
		var r = new PyCode.FunctionCall(new PyCode.Identifier("staticmethod"));
		r.add_argument(new PyCode.Identifier("lib.%s".printf(cr.get_cname())));

		current_class.add_member(new PyCode.Assignment(l, r));
	}

	public override void visit_property(Property pr) {
		if (pr.get_accessor != null) {
			var l = new PyCode.Identifier("get_%s".printf(pr.name));
			var r = new PyCode.FunctionCall(new PyCode.Identifier("instancemethod"));
			r.add_argument(new PyCode.Identifier("lib.%s".printf(pr.get_accessor.get_cname())));
			current_class.add_member(new PyCode.Assignment(l, r));
		}
		if (pr.set_accessor != null) {
			var l = new PyCode.Identifier("set_%s".printf(pr.name));
			var r = new PyCode.FunctionCall(new PyCode.Identifier("instancemethod"));
			r.add_argument(new PyCode.Identifier("lib.%s".printf(pr.set_accessor.get_cname())));
			current_class.add_member(new PyCode.Assignment(l, r));
		}

		var l = new PyCode.Identifier(pr.name);
		var r = new PyCode.FunctionCall(new PyCode.Identifier("property"));

		if (pr.get_accessor != null)
			r.add_argument(new PyCode.Identifier("fget=get_%s".printf(pr.name)));
		if (pr.set_accessor != null)
			r.add_argument(new PyCode.Identifier("fset=set_%s".printf(pr.name)));

		current_class.add_member(new PyCode.Assignment(l, r));
	}
}

class DelegateWriter : SegmentWriter {
	public override void visit_delegate(Delegate de) {
		stream.printf("%s = CFUNCTYPE(", de.name);
		write_type(de.return_type);
		write_params(de.get_parameters(), false);
		stream.printf(")\n");
	}
}

class BindingWriter : SegmentWriter {
	public override void visit_class(Class cl) {
		if (interesting(cl))
			cl.accept_children(this);
	}


	public override void visit_method(Method me) {
		DataType instance_type = null;
		if (me.binding == MemberBinding.INSTANCE) {
			instance_type = get_data_type_for_symbol ((TypeSymbol) me.parent_symbol);
		}
		write_call(me.get_cname(), instance_type, me.get_parameters(), me.return_type);
	}

	public override void visit_creation_method(CreationMethod cr) {
		// do stuff with parent_symbol again..
		write_call(cr.get_cname(), null, cr.get_parameters(), get_data_type_for_symbol((TypeSymbol) cr.parent_symbol));
	}

	public override void visit_property(Property pr) {
		if (pr.get_accessor != null) {
			write_call(pr.get_accessor.get_cname(), null, null, pr.property_type);
		}
		if (pr.set_accessor != null) {
			// var f = new ArrayList<FormalParameter>();
			// f.add(pr.property_type);
			// write_call(pr.set_accessor.get_cname(), null, f, null);
		}
	}
}
