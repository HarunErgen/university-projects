public class MassageEventLeaving extends Event{
	Masseur masseur;
	MassageEventLeaving(Player player, Masseur masseur, double arrivalTime, double duration) {
		super(player, arrivalTime, duration);
		this.masseur = masseur;
	}
}
