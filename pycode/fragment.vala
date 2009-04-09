
using Gee;

namespace PyCode {
	public class Fragment : Node {
		private Gee.List<Node> children = new ArrayList<Node>();

		public void append (Node node) {
			children.add (node);
		}

		public override void write (Writer writer) {
			foreach (Node node in children)
				node.write(writer);
		}
	}
}
