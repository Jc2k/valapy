using Gee;

namespace PyCode {
	public class Block : Statement {
		private Gee.List<Node> statements = new ArrayList<Node> ();

		public void add_statement (Statement stmt) {
			statements.add (stmt);
		}

		public override void write (Writer writer) {
			writer.begin_block ();

			foreach (var s in statements)
				s.write (writer);

			writer.end_block ();
		}
	}
}
