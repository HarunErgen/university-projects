import java.util.PriorityQueue;

public class Physiotherapist {
	int id;
	double serviceTime;
	boolean available = true;
	PriorityQueue<PhysiotherapyEventArrival> physiotherapyQueue;
	
	Physiotherapist(int id, double serviceTime, PriorityQueue<PhysiotherapyEventArrival> physiotherapyQueue) {
		this.id = id;
		this.serviceTime = serviceTime;
		this.physiotherapyQueue = physiotherapyQueue;
	}
}