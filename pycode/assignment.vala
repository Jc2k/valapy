namespace PyCode {
	public class Assignment : Expression {

		public Expression left { get; set; }
		public Expression right { get; set; }
		public AssignmentOperator operator { get; set; }

		public Assignment (Expression l, Expression r, AssignmentOperator op = AssignmentOperator.SIMPLE) {
			left = l;
			right = r;
			operator = op;
		}

		public override void write (Writer writer) {
			left.write (writer);
			writer.write_string(" = ");
			right.write (writer);
			writer.write_newline();
		}
	}

	public enum AssignmentOperator {
		SIMPLE,
		BITWISE_OR,
		BITWISE_AND,
		BITWISE_XOR,
		ADD,
		SUB,
		MUL,
		DIV,
		PERCENT,
		SHIFT_LEFT,
		SHIFT_RIGHT
	}
}
