public class TrainingEventArrival extends Event{
	TrainingCoach trainingCoach;
	TrainingEventArrival(Player player, TrainingCoach trainingCoach, double arrivalTime, double duration) {
		super(player, arrivalTime, duration);
		this.trainingCoach = trainingCoach;
	}
}