
using Gee;
using Vala;

public class EnumsWriter : CodeVisitor {
	public void write_file(CodeContext context, Gee.List<SourceFile> source_files, string filename) {
		var cstream = FileStream.open(filename+".c", "w");

		cstream.printf("#include <stdio.h>\n");
		cstream.printf("#include <libsyncml/data_sync_api/standard.h>\n");
		cstream.printf("#include <libsyncml/data_sync_api/defines.h>\n");

		cstream.printf("int main (int argc, char ** argv) {\n");

		write_segment(context, source_files, cstream);

		cstream.printf("return 0;\n");
		cstream.printf("}\n");
	}

	protected CodeContext context;
	protected Gee.List<SourceFile> source_files;
	protected weak FileStream stream;

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

	public override void visit_namespace (Namespace ns) {
		if (interesting(ns))
			ns.accept_children(this);
	}

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

