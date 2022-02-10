import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.PriorityQueue;
import java.util.Scanner;

public class project1main {
	public static void main(String[] args) throws FileNotFoundException{
		Scanner in = new Scanner(new File(args[0]));
		PrintStream out = new PrintStream(new File(args[1]));

		PriorityQueue<House> houseQueue = new PriorityQueue<House>(new HouseComparator());
		PriorityQueue<Student> studentQueue = new PriorityQueue<Student>(new StudentComparator());
		
		// Input Processing
		while (in.hasNextLine()) {
			String[] inputData = in.nextLine().split(" ");

			if (inputData[0].equals("h")) {
				int id = Integer.parseInt(inputData[1]);
				int duration = Integer.parseInt(inputData[2]);
				double rating = Double.parseDouble(inputData[3]);
				houseQueue.add(new House(id, duration, rating));
			}
			else if (inputData[0].equals("s")) {
				int id = Integer.parseInt(inputData[1]);
				String name = inputData[2];
				int duration = Integer.parseInt(inputData[3]);
				double rating = Double.parseDouble(inputData[4]);
				studentQueue.add(new Student(id, name, duration, rating));
			}
		}
		while (Allocator.allocate(houseQueue, studentQueue)) {
		}
		// Output
		while(!studentQueue.isEmpty()) {
			Student student = studentQueue.poll();
			if(!student.isResident()) {
				out.println(student.getName());
			}	
		}
	}
}