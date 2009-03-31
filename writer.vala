
using Gee;
using Vala;

public class Writer : CodeVisitor {

	private CodeContext context;
	private FileStream stream;

	public void write_file(CodeContext context, string filename) {
		this.context = context;
		this.stream = FileStream.open(filename, "w");

		context.accept(this);
	}

	public override void visit_enum (Enum en) {
		if (!en.external_package) {
			return;
		}

		stream.printf("%s\n", en.name);

		en.accept_children(this);

		stream.printf("\n");
	}

	public override void visit_enum_value(Vala.EnumValue ev) {
		if (!ev.external_package) {
			return;
		}

		stream.printf("%s\n", ev.name);
	}
}
