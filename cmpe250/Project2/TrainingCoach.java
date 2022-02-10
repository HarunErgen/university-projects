import java.util.PriorityQueue;

public class TrainingCoach {
	boolean available = true;
	PriorityQueue<TrainingEventArrival> tcQueue;
	
	TrainingCoach(PriorityQueue<TrainingEventArrival> tcQueue) {
		this.tcQueue = tcQueue;
	}
}
