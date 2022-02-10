public class Student {
	private int id;
	private String name;
	private int duration;
	private double rating;
	private boolean isResident;
	
	public Student(int id, String name, int duration, double rating) {
		this.id = id;
		this.name = name;
		this.duration = duration;
		this.rating = rating;
		this.isResident = false;
	}
	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getDuration() {
		return duration;
	}

	public void setDuration(int duration) {
		this.duration = duration;
	}

	public double getRating() {
		return rating;
	}

	public void setRating(double rating) {
		this.rating = rating;
	}

	public boolean isResident() {
		return isResident;
	}

	public void setResident(boolean isResident) {
		this.isResident = isResident;
	}
}
