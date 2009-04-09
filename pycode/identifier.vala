namespace PyCode {
	public class Identifier : Expression {
		public string name { get; set; }

		public Identifier (string n) {
			name = n;
		}

		public override void write (Writer writer) {
			writer.write_string(name);
		}
	}
}
