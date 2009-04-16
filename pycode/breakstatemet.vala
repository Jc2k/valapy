namespace PyCode {
	public class BreakStatement : Statement {
		public override void write (Writer writer) {
			writer.write_string ("break")
			writer.write_newline ();
		}
	}
}
