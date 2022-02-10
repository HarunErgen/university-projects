import java.util.ArrayList;
import java.util.HashSet;

public class PushRelabel {
	ArrayList<Vertex> vertices;
	HashSet<Vertex> vehicles;

	PushRelabel(int size, ArrayList<Vertex> vertices) {
		this.vertices = vertices;
		this.vehicles = new HashSet<>();
		for(Vertex vertex : vertices) {
			if (vertex.isVehicle) {
				vehicles.add(vertex);
			}
		}
	}
	void addEdge(Vertex from, Vertex to, int capacity) {
		vertices.get(from.id).addEdge(vertices.get(to.id), 0, capacity);
	}
	void preFlow(Vertex source) {
		source.height = vertices.size();
		for (Edge edge : source.edges) {
			edge.flow = edge.capacity;
			edge.to.excessFlow += edge.flow;
			edge.to.addEdge(source, -edge.flow, 0);
		}
	}
	boolean push(Vertex current) {
		for (Edge edge : current.edges) {
			if ((current.height > edge.to.height) && (edge.flow != edge.capacity)) {
				int flow = Math.min(edge.capacity - edge.flow, current.excessFlow);
				current.excessFlow -= flow;
				edge.to.excessFlow += flow;
				edge.flow += flow;
				updateReverseEdge(edge, flow);
				return true;
			}	
		}
		return false;
	}
	void relabel(Vertex current) {
		int minHeight = Integer.MAX_VALUE;
		for (Edge edge : current.edges) {
			if ((edge.flow != edge.capacity) && (edge.to.height < minHeight)) {
				minHeight = edge.to.height;
				current.height = minHeight + 1;
				if(current.isVehicle) {
					vehicles.remove(current);
				}
			}
		}
	}
	Vertex getActiveVertex() {
		for (int i = vertices.size()-2; i > 0; i--) {
			if(vertices.get(i).excessFlow > 0) {
				return vertices.get(i);
			}
		}
		return null;
	}
	void updateReverseEdge(Edge edge, int flow) {
		for (Edge e : edge.to.edges) {
			if (e.to.equals(edge.from)) {
				e.flow -= flow;
				return;
			}
		}
		edge.to.addEdge(edge.from, -flow, 0);
	}
	int getMaxFlow() {
	    preFlow(vertices.get(0));
	    Vertex current = getActiveVertex();
	    while ((current != null) && (!vehicles.isEmpty())) {
	    	if (!push(current)) {
	    		relabel(current);
	    	}
	    	current = getActiveVertex();
	    }
	    return vertices.get(vertices.size()-1).excessFlow;
	}
}