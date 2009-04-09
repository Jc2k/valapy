using Gee;

namespace PyCode {
	public class FunctionCall : Expression {
		public Expression? call { get; set; }
		private Gee.List<Expression> arguments = new ArrayList<Expression>();

		public FunctionCall (Expression? c = null) {
			call = c;
		}

		public void add_argument (Expression a) {
			arguments.add(a);
		}

		public override void write (Writer writer) {
		}
	}
}
