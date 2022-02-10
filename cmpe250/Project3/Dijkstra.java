import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.PriorityQueue;
import java.util.Set;

abstract class Dijkstra {
	static Map<City, Integer> shortestPath(City start, ArrayList<City> cities, Map<City, City> pathToEnd) {
		Map<City, Integer> totalCosts = new HashMap<>();
		Map<City, City> prevCities = new HashMap<>();
		PriorityQueue<City> minCity = new PriorityQueue<>(new CityComparator());
		Set<City> visited = new HashSet<>();
		
		start.distance = 0;
		totalCosts.put(start, 0);
		minCity.add(start);
		
		for (City city : cities) {
			if(!city.equals(start)) {
				totalCosts.put(city, city.distance);
			}
		}
		while (!minCity.isEmpty()) {
			City currentCity = minCity.poll();
			minCity.add(currentCity);
			currentCity = minCity.poll();
			visited.add(currentCity);
			for (City neighbour : currentCity.neighbours.keySet()) {
				if(!visited.contains(neighbour)) {
					int path = totalCosts.get(currentCity) + currentCity.neighbours.get(neighbour);
					if (path < totalCosts.get(neighbour)) {
						neighbour.distance = path;
						totalCosts.put(neighbour, neighbour.distance);
						prevCities.put(neighbour, currentCity);
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
		pathToEnd.putAll(prevCities);
		return totalCosts;
	}
}