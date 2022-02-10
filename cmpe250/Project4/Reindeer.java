public class Reindeer extends Vertex{
	String region;
	Reindeer(int id, int height, int excessFlow, int capacity, String region) {
		super(id, height, excessFlow, capacity);
		this.region = region;
		this.isVehicle = true;
	}
}
