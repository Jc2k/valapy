namespace PyCode {
	public class ReturnStatement : Statement {

		public Expression? expression { get; set; default=null; }

		public ReturnStatement (Expression e) {
			expression = e;
		}

		public override void write (Writer writer) {
			writer.write_string ("return");

			if (expression != null) {
				writer.write_string (" ");
				expression.write (writer);
			}

			writer.write_newline ();
		}
	}
}
