public class Edge {
	Vertex from, to;
	int flow;
	int capacity;
	
	Edge(Vertex from, Vertex to, int flow, int capacity) {
		this.from = from;
		this.to = to;
		this.flow = flow;
		this.capacity = capacity;
	}
}