public class PhysiotherapyEventLeaving extends Event{
	Physiotherapist physiotherapist;
	PhysiotherapyEventLeaving(Player player, Physiotherapist physiotherapist, double arrivalTime, double duration) {
		super(player, arrivalTime, duration);
		this.physiotherapist = physiotherapist;
	}

}
