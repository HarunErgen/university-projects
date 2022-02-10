import java.util.PriorityQueue;

abstract class Allocator {
	static boolean allocate(PriorityQueue<House> houseQueue, PriorityQueue<Student> studentQueue) {
		if (checkGraduation(studentQueue)) {
			return false;
		}
		
		PriorityQueue<House> houseQueueTemp = new PriorityQueue<House>(houseQueue.comparator());
		PriorityQueue<Student> studentQueueTemp = new PriorityQueue<Student>(studentQueue.comparator());

		while(!studentQueue.isEmpty()) {
			Student student = studentQueue.poll();
			if (student.getDuration() != 0) {
				if(!student.isResident()) {
					while(!houseQueue.isEmpty()) {
						House house = houseQueue.poll();
						if ((house.getDuration() == 0) && (house.getRating() >= student.getRating())) {
							house.setDuration(student.getDuration());
							student.setResident(true);
							houseQueueTemp.add(house);
							break;
						}
						houseQueueTemp.add(house);
					}
					houseQueue.addAll(houseQueueTemp);
					houseQueueTemp.clear();
				}
				student.setDuration(student.getDuration()-1);;
			}
			studentQueueTemp.add(student);
		}
		studentQueue.addAll(studentQueueTemp);
		
		for (House house : houseQueueTemp) {
			if (house.getDuration() != 0) {
				house.setDuration(house.getDuration()-1);
			}
		}
		for (House house : houseQueue) {
			if (house.getDuration() != 0) {
				house.setDuration(house.getDuration()-1);
			}
		}
		return true;
	}
	static boolean checkGraduation(PriorityQueue<Student> studentQueue) {
		for (Student student : studentQueue) {
			if (student.getDuration() != 0) 
				return false;
		}
		return true;
	}
}