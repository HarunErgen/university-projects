import java.util.HashMap;
import java.util.Map;

public class City {
	int id;
	String name;
	Integer distance = Integer.MAX_VALUE;
	Map<City, Integer> neighbours = new HashMap<>();
	
	City(int id) {
		this.id = id;
		this.name = "c" + id;
	}
}