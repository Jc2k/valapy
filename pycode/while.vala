namespace PyCode {
	public class WhileStatement : Statement {
		public Expression condition { get; set; }
		public Block block { get; set; }

		public WhileStatement (Expression cdtn, Block blk) {
			condition = cdtn;
			block = blk;
		}

		public override void write (Writer writer) {
			writer.write_string ("while ");
			condition.write (writer);
			writer.write_string (":");
			writer.write_newline ();

			block.write (writer);
		}
	}
}
