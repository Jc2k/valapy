
using Gee;
using Vala;

public class TankWriter : CodeVisitor {

	private CodeContext context;
	private Gee.List<SourceFile> source_files;

	private FileStream cstream;
	private FileStream stream;

	private uint indent;

	private bool class_has_members;

	public void write_file(CodeContext context, Gee.List<SourceFile> source_files, string filename) {
		this.context = context;
		this.source_files = source_files;

		this.stream = FileStream.open(filename, "w");
		this.cstream = FileStream.open(filename+".c", "w");

		this.indent = 0;

		stream.printf("from ctypes import *\n\n");
		stream.printf("lib = CDLL('libsyncml.so')\n\n");

		context.accept(this);
	}

	private bool interesting(CodeNode node) {
		if (node.source_reference == null)
			return true;

		foreach (var sr in source_files)
			if (node.source_reference.file == sr)
				return true;

		return false;
	}

	private void write_indent() {
		for (uint i = 0; i < this.indent; i++)
			this.stream.printf("    ");
	}

	public override void visit_namespace (Namespace ns) {
		if (!interesting(ns))
			return;

		ns.accept_children(this);
	}

	public override void visit_enum (Enum en) {
		en.accept_children(this);
		cstream.printf("\n");
	}

	public override void visit_enum_value(Vala.EnumValue ev) {
		cstream.printf("%s\n", ev.get_cname());
	}

	public override void visit_constant(Constant co) {
		cstream.printf("%s\n", co.get_cname());
	}

	public override void visit_class(Class cl) {
		if (!interesting(cl))
			return;

		this.write_indent();
		stream.printf("class %s(c_void_p):\n\n", cl.name);

		this.class_has_members = false;

		this.indent++;
		cl.accept_children(this);
		if (this.class_has_members == false) {
			this.write_indent();
			stream.printf("pass\n");
		}
		this.indent--;

		stream.printf("\n\n");
	}

	public override void visit_method(Method me) {
		this.write_indent();
		stream.printf("%s = instancemethod(lib.%s)\n", me.name, me.get_cname());

		this.class_has_members = true;
	}

	public override void visit_creation_method(CreationMethod cr) {
		this.write_indent();
		stream.printf("%s = staticmethod(lib.%s)\n", cr.name, cr.get_cname());

		this.class_has_members = true;
	}

	public override void visit_property(Property pr) {
		if (pr.get_accessor != null) {
			this.write_indent();
			stream.printf("get_%s = None\n", pr.name);
		}
		if (pr.set_accessor != null) {
			this.write_indent();
			stream.printf("set_%s = None\n", pr.name);
		}

		this.write_indent();
		stream.printf("%s = property(", pr.name);
		stream.printf(")\n");

		this.class_has_members = true;
	}

}
