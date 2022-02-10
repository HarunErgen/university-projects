import java.util.Comparator;

public class HouseComparator implements Comparator<House> {
	@Override
	public int compare(House x, House y) {
		if (x.getId() < y.getId()) {
			return -1;
		}
		if (x.getId() > y.getId()) {
			return 1;
		}
		return 0;
	}
}