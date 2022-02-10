public class Bag extends Vertex {
	boolean a = false;
	boolean b = false;
	boolean c = false;
	boolean d = false;
	boolean e = false;
	Bag(int id, int height, int excessFlow, int capacity, String type) {
		super(id, height, excessFlow, capacity);
		if (type.contains("a")) {
			this.a = true;
		}
		if (type.contains("b")) {
			this.b = true;
		}
		if (type.contains("c")) {
			this.c = true;
		}
		if (type.contains("d")) {
			this.d = true;
		}
		if (type.contains("e")) {
			this.e = true;
		}
	}
}