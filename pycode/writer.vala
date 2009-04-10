namespace PyCode {
	public class Writer {

		private int indent = 0;
		private bool bol = true;

		private weak FileStream stream;

		public Writer(FileStream s) {
			stream = s;
		}

		public void write_string (string s) {
			if (bol)
				write_indent();

			stream.printf(s);
		}

		public void write_indent() {
			bol = false;

			for (uint i = 0; i < indent; i++)
				write_string("    ");
		}

		public void write_newline() {
			stream.putc('\n');
			bol = true;
		}

		public void begin_block() {
			indent++;
		}

		public void end_block() {
			indent--;
		}
	}
}
