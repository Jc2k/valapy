
using Gee;
using Vala;

public class TankWriter : CodeVisitor {

	private CodeContext context;
	private FileStream cstream;
	private FileStream stream;

	private uint indent;

	private bool class_has_members;


	public void write_file(CodeContext context, string filename) {
		this.context = context;
		this.stream = FileStream.open(filename, "w");

		this.indent = 0;

		context.accept(this);
	}

	private void write_indent() {
		for (uint i = 0; i < this.indent; i++)
			this.stream.printf("    ");
	}

	public override void visit_namespace (Namespace ns) {
		ns.accept_children(this);
	}

	public override void visit_enum (Enum en) {
		en.accept_children(this);
		stream.printf("\n");
	}

	public override void visit_enum_value(Vala.EnumValue ev) {
		stream.printf("%s\n", ev.get_cname());
	}

	public override void visit_constant(Constant co) {
		stream.printf("%s\n", co.get_cname());
	}

	public override void visit_class(Class cl) {
		// cstream.printf("%s\n", cl.get_cname());

		this.write_indent();

		stream.printf("class %s:\n", cl.name);

		this.indent++;
		this.class_has_members = false;

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
		stream.printf("%s = None\n", me.name);

		this.class_has_members = true;
	}

	public override void visit_creation_method(CreationMethod cr) {
		this.write_indent();
		stream.printf("%s = None\n", cr.name);

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
