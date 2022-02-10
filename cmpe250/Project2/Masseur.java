import java.util.PriorityQueue;

public class Masseur {
	boolean available = true;
	PriorityQueue<MassageEventArrival> mQueue;
	
	Masseur(PriorityQueue<MassageEventArrival> mQueue) {
		this.mQueue = mQueue;
	}
}
