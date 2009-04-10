using Gee;

namespace PyCode {
	public class List : Expression {
		private Gee.List<Expression> elements = new ArrayList<Expression>();

		public void append(Expression e) {
			elements.add(e);
		}

		public override void write (Writer writer) {
			writer.write_string("[");

			bool first = true;
			foreach (var e in elements) {
				if (!first)
					writer.write_string (", ");
				else
					first = false;

				e.write (writer);
			}

			writer.write_string("]");
		}
	}
}
