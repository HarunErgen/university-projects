import java.util.Comparator;

public class CityComparator implements Comparator<City>{
	@Override
	public int compare(City o1, City  o2) {
		if (o1.distance < o2.distance) {
			return -1;
		}
		if (o1.distance > o2.distance) {
			return 1;
		}
		return 0;
	}
}