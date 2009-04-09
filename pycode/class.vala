namespace PyCode {
	public class Class : Node {
		public string name { get; set; }

		public Class (string n) {
			name = n;
		}

		public override void write (Writer writer) {
			writer.write_string("class ");
			writer.write_string(name);
			writer.write_string(":");
		}
	}
}
