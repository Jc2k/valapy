using Gee;

namespace PyCode {
	public class Class : Node {
		public string name { get; set; }

		// FIXME: Single inheritance..
		public string? parent_class { get; set; default=null; }

		private Gee.List<Node> nodes = new ArrayList<Node>();

		public Class (string n) {
			name = n;
		}

		public void add_member (Node n) {
			nodes.add(n);
		}

		public override void write (Writer writer) {
			writer.write_string("class ");
			writer.write_string(name);
			if (base != null) {
				writer.write_string("(%s)".printf(parent_class));
			}
			writer.write_string(":");
			writer.write_newline();

			writer.begin_block();

			bool flag = true;
			foreach (var n in nodes) {
				n.write (writer);
				flag = false;
			}

			// If this class has no members then emit pass statment..
			if (flag) {
				writer.write_indent();
				writer.write_string("pass");
				writer.write_newline();
			}

			writer.end_block();

			writer.write_newline();
			writer.write_newline();
		}
	}
}
