import java.util.ArrayList;

public class Vertex {
	int id;
	int height;
	int excessFlow;
	int capacity;
	ArrayList<Edge> edges;
	boolean isVehicle = false;
	
	Vertex(int id, int height, int excessFlow, int capacity) {
		this.id = id;
		this.height = height;
		this.excessFlow = excessFlow;
		this.capacity = capacity;
		this.edges = new ArrayList<>();	
	}
	void addEdge(Vertex to, int flow, int capacity) {
		edges.add(new Edge(this, to, flow, capacity));
	}
}