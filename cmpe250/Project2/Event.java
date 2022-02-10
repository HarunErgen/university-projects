public class Event {
	Player player;
	double arrivalTime;
	double duration;
	double finishTime;
	
	Event(Player player, double arrivalTime, double duration){
		this.player = player;
		this.arrivalTime = arrivalTime;
		this.duration = duration;
		this.finishTime = this.arrivalTime + this.duration;
	}
}
