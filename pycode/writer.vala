namespace PyCode {
	public class Writer {

		private int indent;
		private weak FileStream stream;

		public Writer(FileStream s) {
			stream = s;
		}

		public void write_string (string s) {
			stream.printf(s);
		}

		public void write_indent() {
			for (uint i = 0; i < indent; i++)
				write_string("    ");
		}

		public void begin_block() {
			indent++;
		}

		public void end_block() {
			indent--;
		}
	}
}
