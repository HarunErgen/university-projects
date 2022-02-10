public class PhysiotherapyEventArrival extends Event{
	Physiotherapist physiotherapist;
	PhysiotherapyEventArrival(Player player, Physiotherapist physiotherapist, double arrivalTime, double duration) {
		super(player, arrivalTime, duration);
		this.physiotherapist = physiotherapist;
	}
}