namespace PyCode {
	public class IfStatement : Statement {
		public Expression condition { get; set; }
		public Statement true_statement { get; set; }
		public Statement? false_statement { get; set; }

		public IfStatement (Expression c, Statement t, Statement? f = null) {
			condition = c;
			true_statement = t;
			false_statement = f;
		}

		public override void write (Writer writer) {
			writer.write_string ("if ");
			condition.write (writer);
			writer.write_string (":");
			writer.write_newline ();

			writer.begin_block ();
			true_statement.write (writer);
			writer.end_block ();
		}
	}
}
