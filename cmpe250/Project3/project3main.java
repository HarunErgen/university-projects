import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

public class project3main {
	public static boolean MARRIED = false;
	public static void main(String[] args) throws FileNotFoundException{
		Scanner in = new Scanner(new File(args[0]));
		PrintStream out = new PrintStream(new File(args[1]));
		
		int timeLimit = Integer.parseInt(in.nextLine());
		int numberOfCities = Integer.parseInt(in.nextLine());
		
		String[] startAndEnd = in.nextLine().replaceAll("[^0-9& ]", "").split(" ");
		int end = Integer.valueOf(startAndEnd[1]);
		int numberOfHoneyMoonCities = numberOfCities - end;
		
		ArrayList<City> cities = new ArrayList<City>();
		ArrayList<City> honeyMoonCities = new ArrayList<City>();
		for (int i = 1; i <= end; i++) {
			cities.add(new City(i));
		}
		for (int i = 1; i <= numberOfHoneyMoonCities; i++) {
			honeyMoonCities.add(new City(i));
		}
		// DIJKSTRA
		for (int i = 1; i < end; i++) {
			String[] inputData = in.nextLine().split(" ");
			for (int j = 1; j < inputData.length; j+=2) {
				int cityID = Integer.valueOf(inputData[j].replaceAll("[^0-9]", ""));
				Integer distance = Integer.valueOf(inputData[j+1]);
				if (cities.get(i-1).neighbours.containsKey(cities.get(cityID-1))) {
					if (cities.get(i-1).neighbours.get(cities.get(cityID-1)) < distance) {
						distance = cities.get(i-1).neighbours.get(cities.get(cityID-1));
					}
				}
				cities.get(i-1).neighbours.put(cities.get(cityID-1), distance);
			}
		}
		Map<City, City> pathToEnd = new HashMap<>();
		Map<City, Integer> totalCosts = new HashMap<>();
		
		totalCosts.putAll(Dijkstra.shortestPath(cities.get(0), cities, pathToEnd));
		
		ArrayList<String> route = new ArrayList<>();
		City path = cities.get(end-1);
		try {
			while(!path.equals(cities.get(0))) {
				route.add(path.name);
				path = pathToEnd.get(path);
			}
			Collections.reverse(route);
			if(totalCosts.get(cities.get(end-1)) <= timeLimit) {
				System.out.println(totalCosts.get(cities.get(end-1)));
				MARRIED = true;
			}
			String result = "c1 ";
			for(int i = 0; i < route.size(); i++) {
				result += route.get(i) + " ";
			}
			out.println(result.strip());
		} catch (Exception e) {
			out.println(-1);
		}
		// PRIM
		for (int i = 0; i <= numberOfHoneyMoonCities; i++) {
			String[] inputData = in.nextLine().split(" ");
			for (int j = 1; j < inputData.length; j+=2) {
				if (i == 0) {
					int cityID = Integer.valueOf(inputData[j].replaceAll("[^0-9]", ""));
					Integer distance = Integer.valueOf(inputData[j+1]);
					if(cities.get(end-1).neighbours.containsKey(honeyMoonCities.get(cityID-1))) {
						if(cities.get(end-1).neighbours.get(honeyMoonCities.get(cityID-1)) < distance) {
							distance = cities.get(end-1).neighbours.get(honeyMoonCities.get(cityID-1));
						}
					}
					cities.get(end-1).neighbours.put(honeyMoonCities.get(cityID-1), distance);
					honeyMoonCities.get(cityID-1).neighbours.put(cities.get(end-1), distance);
				}
				else {
					int cityID = Integer.valueOf(inputData[j].replaceAll("[^0-9]", ""));
					Integer distance = Integer.valueOf(inputData[j+1]);
					if (!honeyMoonCities.get(i-1).equals(honeyMoonCities.get(cityID-1))) {
						if (honeyMoonCities.get(i-1).neighbours.containsKey(honeyMoonCities.get(cityID-1))) {
							if (honeyMoonCities.get(i-1).neighbours.get(honeyMoonCities.get(cityID-1)) < distance) {
								distance = honeyMoonCities.get(i-1).neighbours.get(honeyMoonCities.get(cityID-1));
							}
						}
						honeyMoonCities.get(i-1).neighbours.put(honeyMoonCities.get(cityID-1), distance);
						honeyMoonCities.get(cityID-1).neighbours.put(honeyMoonCities.get(i-1), distance);
					}
				}
			}
		}
		honeyMoon: {
			if (MARRIED) {
				Map<City, City> minSpanningTree = new HashMap<>();
				Map<City, Integer> costs = new HashMap<>();
				Prim.prim(cities.get(end-1), honeyMoonCities, minSpanningTree, costs);
				for (City city : honeyMoonCities) {
					if (!minSpanningTree.containsKey(city)) {
						out.print(-2);
						break honeyMoon;
					}
				}
				int sum = 0;
				for(int i : costs.values()) {
					sum += i;
				}
				out.print(sum*2);
			} else {
				out.print(-1);
			} 
		}
		in.close();
		out.close();
	}
}