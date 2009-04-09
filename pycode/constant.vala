namespace PyCode {
	public class Constant : Expression {
		public string name { get; set; }

		public Constant (string n) {
			name = n;
		}

		public override void write (Writer writer) {
			writer.write_string(name);
		}
	}
}
