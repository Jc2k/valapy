using Gee;

namespace PyCode {
	public class Function : Node {
		public string name { get; set; }
		public Fragment? body { get; set; default=null; }
		private Gee.List<Identifier> arguments = new ArrayList<Identifier>();

		public Function (string n) {
			name = n;
		}

		public void add_argument (Identifier arg) {
			arguments.add (arg);
		}

		public override void write (Writer writer) {
			writer.write_string ("def ");
			writer.write_string (name);
			writer.write_string ("(");
			bool first = true;
			foreach (var arg in arguments) {
				if (!first)
					writer.write_string (", ");
				else
					first = false;

				arg.write (writer);
			}
			writer.write_string ("):");
			writer.write_newline();

			writer.begin_block();

			if (body != null) {
				body.write (writer);
			} else {
				writer.write_string ("pass");
				writer.write_newline();
			}

			writer.write_newline();
			writer.end_block();
		}
	}
}
