namespace PyCode {
	public class ContinueStatement : Statement {
		public override void write (Writer writer) {
			writer.write_string ("continue")
			writer.write_newline ();
		}
	}
}
