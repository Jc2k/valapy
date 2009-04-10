using Gee;

namespace PyCode {
	public class Class : Node {
		public string name { get; set; }
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
			writer.write_string(":");
			writer.write_newline();

			bool flag = true;
			foreach (var n in nodes) {
				n.write (writer);
				flag = false;
			}

			// If this class has no members then emit pass statment..
			if (flag) {
				writer.write_string("pass");
				writer.write_newline();
			}

			writer.write_newline();
			writer.write_newline();
		}
	}
}
