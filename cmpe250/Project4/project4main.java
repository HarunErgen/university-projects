import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Scanner;

public class project4main {
	public static void main(String[] args) throws FileNotFoundException {
		Scanner in = new Scanner(new File(args[0]));
		PrintStream out = new PrintStream(new File(args[1]));
		
		int numberOfGreenTrains;
		int numberOfRedTrains;
		int numberOfGreenReindeers;
		int numberOfRedReindeers;
		int totalGifts = 0;
		// INPUT
		// GREEN TRAINS
		numberOfGreenTrains = Integer.parseInt(in.nextLine());
		ArrayList<Train> greenTrains = new ArrayList<>(numberOfGreenTrains);
		String[] capacitiesOfGreenTrains = in.nextLine().split(" ");
		for(int i = 0; i < numberOfGreenTrains; i++) {
			int capacity = Integer.parseInt(capacitiesOfGreenTrains[i]);
			greenTrains.add(new Train(-1, 1, 0, capacity, "Green"));
		}
		// RED TRAINS
		numberOfRedTrains = Integer.parseInt(in.nextLine());
		ArrayList<Train> redTrains = new ArrayList<>(numberOfRedTrains);
		String[] capacitiesOfRedTrains = in.nextLine().split(" ");
		for(int i = 0; i < numberOfRedTrains; i++) {
			int capacity = Integer.parseInt(capacitiesOfRedTrains[i]);
			redTrains.add(new Train(-1, 1, 0, capacity, "Red"));
		}
		// GREEN REINDEERS
		numberOfGreenReindeers = Integer.parseInt(in.nextLine());
		ArrayList<Reindeer> greenReindeers = new ArrayList<>(numberOfGreenReindeers);
		String[] capacitiesOfGreenReindeers = in.nextLine().split(" ");
		for(int i = 0; i < numberOfGreenReindeers; i++) {
			int capacity = Integer.parseInt(capacitiesOfGreenReindeers[i]);
			greenReindeers.add(new Reindeer(-1, 1, 0, capacity, "Green"));
		}
		// RED REINDEERS
		numberOfRedReindeers = Integer.parseInt(in.nextLine());
		ArrayList<Reindeer> redReindeers = new ArrayList<>(numberOfRedReindeers);
		String[] capacitiesOfRedReindeers = in.nextLine().split(" ");
		for(int i = 0; i < numberOfRedReindeers; i++) {
			int capacity = Integer.parseInt(capacitiesOfRedReindeers[i]);
			redReindeers.add(new Reindeer(-1, 1, 0, capacity, "Red"));
		}
		// Number of Gift Types
		int N = Integer.parseInt(in.nextLine());
		ArrayList<Bag> bags = new ArrayList<>();
		Bag BDbag = new Bag(-1, 2, 0, 0, "bd");
		Bag BEbag = new Bag(-1, 2, 0, 0, "be");
		Bag CDbag = new Bag(-1, 2, 0, 0, "cd");
		Bag CEbag = new Bag(-1, 2, 0, 0, "ce");
		Bag Bbag = new Bag(-1, 2, 0, 0, "b");
		Bag Cbag = new Bag(-1, 2, 0, 0, "c");
		Bag Dbag = new Bag(-1, 2, 0, 0, "d");
		Bag Ebag = new Bag(-1, 2, 0, 0, "e");
		if (N!=0) {
			// Types of Bags
			String[] typesOfBags = in.nextLine().split(" ");
			for (int i = 0; i < typesOfBags.length; i += 2) {
				String type = typesOfBags[i];
				int numberOfGifts = Integer.parseInt(typesOfBags[i + 1]);
				totalGifts += numberOfGifts;
				if (type.contains("a")) {
					bags.add(new Bag(-1, 2, 0, numberOfGifts, type));
				}
				else if(type.contains("b")) {
					if(type.contains("d")) {
						BDbag.capacity += numberOfGifts;
					}
					else if(type.contains("e")) {
						BEbag.capacity += numberOfGifts;
					}
					else {
						Bbag.capacity += numberOfGifts;
					}
				}
				else if(type.contains("c")) {
					if(type.contains("d")) {
						CDbag.capacity += numberOfGifts;
					}
					else if(type.contains("e")) {
						CEbag.capacity += numberOfGifts;
					}
					else {
						Cbag.capacity += numberOfGifts;
					}
				}
				else if(type.contains("d")) {
					Dbag.capacity += numberOfGifts;
				}
				else if(type.contains("e")) {
					Ebag.capacity += numberOfGifts;
				}
			} 
		}
		bags.add(BDbag);
		bags.add(BEbag);
		bags.add(CDbag);
		bags.add(CEbag);
		bags.add(Bbag);
		bags.add(Cbag);
		bags.add(Dbag);
		bags.add(Ebag);
		// Combining Trains and Reindeers
		ArrayList<Train> trains = new ArrayList<>(numberOfGreenTrains + numberOfRedTrains);
		ArrayList<Reindeer> reindeers = new ArrayList<>(numberOfGreenReindeers + numberOfRedReindeers);
		trains.addAll(greenTrains);
		trains.addAll(redTrains);
		reindeers.addAll(greenReindeers);
		reindeers.addAll(redReindeers);
		// VERTICES
		ArrayList<Vertex> vertices = new ArrayList<>(1+bags.size()+trains.size()+reindeers.size()+1);
		Vertex source = new Vertex(-1, 0, 0, -1);
		vertices.add(source);
		vertices.addAll(bags);
		vertices.addAll(trains);
		vertices.addAll(reindeers);
		Vertex terminal = new Vertex(-1, 0, 0, -1);
		vertices.add(terminal);
		for(int i = 0; i < vertices.size(); i++) {
			vertices.get(i).id = i;
		}
		// PUSH-RELABEL
		PushRelabel solve = new PushRelabel(vertices.size(), vertices);
		for(int i = 0; i < bags.size(); i++) {
			solve.addEdge(source, bags.get(i), bags.get(i).capacity);
		}
		distribute(solve, trains, reindeers, bags);
		for(int i = 0; i < reindeers.size(); i++) {
			solve.addEdge(reindeers.get(i), terminal, reindeers.get(i).capacity);
		}
		for(int i = 0; i < trains.size(); i++) {
			solve.addEdge(trains.get(i), terminal, trains.get(i).capacity);
		}
		out.print(totalGifts-solve.getMaxFlow());
	}
	public static void distribute(PushRelabel solve, ArrayList<Train> trains,ArrayList<Reindeer> reindeers, ArrayList<Bag> bags) {
		for (Bag bag : bags) {
			if (bag.a) {
				if (bag.b) {
					if (bag.d) {
						for(Train train : trains) {
							if (train.region.equals("Green")) {
								solve.addEdge(bag, train, 1);
							}
						}
					}
					else if(bag.e) {
						for(Reindeer reindeer : reindeers) {
							if (reindeer.region.equals("Green")) {
								solve.addEdge(bag, reindeer, 1);
							}
						}
					}
					else {
						for(Train train : trains) {
							if (train.region.equals("Green")) {
								solve.addEdge(bag, train, 1);
							}
						}
						for(Reindeer reindeer : reindeers) {
							if (reindeer.region.equals("Green")) {
								solve.addEdge(bag, reindeer, 1);
							}
						}
					}
				}
				else if (bag.c) {
					if (bag.d) {
						for(Train train : trains) {
							if (train.region.equals("Red")) {
								solve.addEdge(bag, train, 1);
							}
						}
						
					}
					else if(bag.e) {
						for(Reindeer reindeer : reindeers) {
							if (reindeer.region.equals("Red")) {
								solve.addEdge(bag, reindeer, 1);
							}
						}
					}
					else {
						for(Train train : trains) {
							if (train.region.equals("Red")) {
								solve.addEdge(bag, train, 1);
							}
						}
						for(Reindeer reindeer : reindeers) {
							if (reindeer.region.equals("Red")) {
								solve.addEdge(bag, reindeer, 1);
							}
						}
					}
				}
				else if (bag.d) {
					for(Train train : trains) {
						solve.addEdge(bag, train, 1);
					}
				}
				else if (bag.e) {
					for(Reindeer reindeer : reindeers) {
						solve.addEdge(bag, reindeer, 1);
					}
				}
				else {
					for(Train train : trains) {
						solve.addEdge(bag, train, 1);
					}
					for (Reindeer reindeer : reindeers) {
						solve.addEdge(bag, reindeer, 1);
					}
				}
			}
			else if(bag.b) {
				if(bag.d) {
					for(Train train : trains) {
						if (train.region.equals("Green")) {
							solve.addEdge(bag, train, bag.capacity);
						}
					}
				}
				else if(bag.e) {
					for(Reindeer reindeer : reindeers) {
						if (reindeer.region.equals("Green")) {
							solve.addEdge(bag, reindeer, bag.capacity);
						}
					}
				}
				else {
					for(Train train : trains) {
						if(train.region.equals("Green")) {
							solve.addEdge(bag, train, bag.capacity);
						}
					}
					for(Reindeer reindeer: reindeers) {
						if(reindeer.region.equals("Green")) {
							solve.addEdge(bag, reindeer, bag.capacity);
						}
					}
				}
			}
			else if(bag.c) {
				if(bag.d) {
					for(Train train : trains) {
						if (train.region.equals("Red")) {
							solve.addEdge(bag, train, bag.capacity);
						}
					}
				}
				else if(bag.e) {
					for(Reindeer reindeer : reindeers) {
						if (reindeer.region.equals("Red")) {
							solve.addEdge(bag, reindeer, bag.capacity);
						}
					}
				}
				else {
					for(Train train : trains) {
						if(train.region.equals("Red")) {
							solve.addEdge(bag, train, bag.capacity);
						}
					}
					for(Reindeer reindeer: reindeers) {
						if(reindeer.region.equals("Red")) {
							solve.addEdge(bag, reindeer, bag.capacity);
						}
					}
				}
			}
			else if(bag.d) {
				for(Train train : trains) {
					solve.addEdge(bag, train, bag.capacity);
				}
			}
			else if(bag.e) {
				for(Reindeer reindeer : reindeers) {
					solve.addEdge(bag, reindeer, bag.capacity);
				}
			}
		}
	}
}