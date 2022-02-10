public class Train extends Vertex{
	String region;
	Train(int id, int height, int excessFlow, int capacity, String region) {
		super(id, height, excessFlow, capacity);
		this.region = region;
		this.isVehicle = true;
	}
}
