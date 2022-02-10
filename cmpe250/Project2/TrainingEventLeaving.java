public class TrainingEventLeaving extends Event{
	TrainingCoach trainingCoach;
	TrainingEventLeaving(Player player, TrainingCoach trainingCoach, double arrivalTime, double duration) {
		super(player, arrivalTime, duration);
		this.trainingCoach = trainingCoach;
	}
}
