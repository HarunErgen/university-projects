import java.util.Comparator;
	
public class StudentComparator implements Comparator<Student> {
	@Override
	public int compare(Student x, Student y) {
		if (x.getId() < y.getId()) {
			return -1;
		}
		if (x.getId() > y.getId()) {
			return 1;
		}
		return 0;
	}
}