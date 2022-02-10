public class MassageEventArrival extends Event{
	Masseur masseur;
	MassageEventArrival(Player player, Masseur masseur, double arrivalTime, double duration){
		super(player, arrivalTime, duration);
		this.masseur = masseur;
	}
}