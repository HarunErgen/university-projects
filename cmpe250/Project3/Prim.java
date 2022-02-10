import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.PriorityQueue;

abstract public class Prim {
	static void prim(City start, ArrayList<City> honeyMoonCities, Map<City, City> minSpanningTree, Map<City, Integer> costs) {
		Map<City, Integer> cost = new HashMap<>();
		Map<City, Boolean> known = new HashMap<>();
		Map<City, City> parent = new HashMap<>();
		PriorityQueue<City> minCity = new PriorityQueue<>(new CityComparator());
		
		start.distance = 0;
		cost.put(start, 0);
		known.put(start, false);
		parent.put(start, null);
		minCity.add(start);
		
		for (City city : honeyMoonCities) {
			cost.put(city, city.distance);
			known.put(city, false);
		}
		while(!minCity.isEmpty()) {
			City currentCity = minCity.poll();
			minCity.add(currentCity);
			currentCity = minCity.poll();
			if(!known.get(currentCity)) {
				known.put(currentCity, true);
				for(City neighbour : currentCity.neighbours.keySet()) {
					if(!(known.get(neighbour)) & currentCity.neighbours.get(neighbour) < cost.get(neighbour)) {
						neighbour.distance = currentCity.neighbours.get(neighbour);
						cost.put(neighbour, neighbour.distance);
						parent.put(neighbour, currentCity);
						if(minCity.contains(neighbour)) {
							minCity.remove(neighbour);
							minCity.add(neighbour);
						}
						else {
							minCity.add(neighbour);
						}
					}
				}
			}
		}
		costs.putAll(cost);
		minSpanningTree.putAll(parent);
	}
}