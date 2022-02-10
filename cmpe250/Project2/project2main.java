import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Locale;
import java.util.PriorityQueue;
import java.util.Scanner;

public class project2main {
	public static void main(String[] args) throws FileNotFoundException{
		Scanner in = new Scanner(new File(args[0]));
		PrintStream out = new PrintStream(new File(args[1]));
		
		Comparators mainComparator = new Comparators();
		
		PriorityQueue<Physiotherapist> physiotherapists = new PriorityQueue<Physiotherapist>(mainComparator.new PhysiotherapistComparator());
		PriorityQueue<PhysiotherapyEventArrival> physiotherapyQueue = new PriorityQueue<PhysiotherapyEventArrival>(mainComparator.new PhysiotherapyComparator());
		
		ArrayList<TrainingCoach> trainingCoaches = new ArrayList<TrainingCoach>();
		PriorityQueue<TrainingEventArrival> trainingQueue = new PriorityQueue<TrainingEventArrival>(mainComparator.new TrainingComparator());
		
		ArrayList<Masseur> masseurs = new ArrayList<Masseur>();
		PriorityQueue<MassageEventArrival> massageQueue = new PriorityQueue<MassageEventArrival>(mainComparator.new MassageComparator());
		
		// PLAYER INITIALIZATION
		int numberOfPlayers = Integer.valueOf(in.nextLine());
		ArrayList<Player> players = new ArrayList<Player>();

		for(int i = 0; i < numberOfPlayers; i++) {
			String[] inputData = in.nextLine().split(" ");
			int id = Integer.valueOf(inputData[0]);
			int skill = Integer.valueOf(inputData[1]);
			players.add(new Player(id, skill));
		}
		Collections.sort(players);

		// EVENTS
		int numberOfArrivals = Integer.valueOf(in.nextLine());
		PriorityQueue<Event> events = new PriorityQueue<Event>(mainComparator.new EventComparator());
		
		for(int i = 0; i < numberOfArrivals; i++) {
			String[] inputData = in.nextLine().split(" ");

			if (inputData[0].equals("t")) {
				Player player = players.get(Integer.valueOf(inputData[1]));
				double arrivalTime = Double.valueOf(inputData[2]);
				double duration = Double.valueOf(inputData[3]);
				
				events.add(new TrainingEventArrival(player, null, arrivalTime, duration));
			}
			if (inputData[0].equals("m")) {
				Player player = players.get(Integer.valueOf(inputData[1]));
				double arrivalTime = Double.valueOf(inputData[2]);
				double duration = Double.valueOf(inputData[3]);
				
				events.add(new MassageEventArrival(player, null, arrivalTime, duration));
			}
		}
		// PHYSIOTHERAPISTS
		String[] physiotherapyLine = in.nextLine().split(" ");
		int numberOfPTs = Integer.valueOf(physiotherapyLine[0]);
		for (int i = 1; i <= numberOfPTs; i++) {
			double serviceTime = Double.valueOf(physiotherapyLine[i]);
			physiotherapists.add(new Physiotherapist(i-1, serviceTime, physiotherapyQueue));
		}
		// TRAININGCOACHES AND MASSEURS
		String[] trainingCoaches_masseurs = in.nextLine().split(" ");
		int numberOfTrainingCoaches = Integer.valueOf(trainingCoaches_masseurs[0]);
		for (int i = 0; i < numberOfTrainingCoaches; i++) {
			trainingCoaches.add(new TrainingCoach(trainingQueue));
		}
		int numberOfMasseurs = Integer.valueOf(trainingCoaches_masseurs[1]);
		for (int i = 0; i < numberOfMasseurs; i++) {
			masseurs.add(new Masseur(massageQueue));
		}
		while(!events.isEmpty()) {
			Simulator.simulate(trainingCoaches, masseurs, physiotherapists, players, events);
		}
		// PLAYER WAITED MOST IN PT QUEUE
		PriorityQueue<Player> physiotherapyWaitTimeQueue = new PriorityQueue<Player>(mainComparator.new PhysiotherapyWaitTimeComparator());
		physiotherapyWaitTimeQueue.addAll(players);
		// PLAYER WAITED LEAST IN MASSAGE QUEUE
		PriorityQueue<Player> massageWaitTimeQueue = new PriorityQueue<Player>(mainComparator.new MassageWaitTimeComparator());
		for(Player player : players) {
			if(player.massageLimit == 4) {
				massageWaitTimeQueue.add(player);
			}
		}
		// OUTPUT
		out.println(Simulator.MAX_TRAINING_LENGTH);
		out.println(Simulator.MAX_PT_LENGTH);
		out.println(Simulator.MAX_MASSAGE_LENGTH);
		out.printf(Locale.US, "%.3f\n", (Simulator.TOTAL_TRAINING_WAIT/(double)Simulator.TOTAL_TRAINING_NUMBER));
		out.printf(Locale.US, "%.3f\n", (Simulator.TOTAL_PT_WAIT/(double)Simulator.TOTAL_PT_NUMBER));
		out.printf(Locale.US, "%.3f\n", (Simulator.TOTAL_MASSAGE_WAIT/(double)Simulator.TOTAL_MASSAGE_NUMBER));
		out.printf(Locale.US, "%.3f\n", (Simulator.TOTAL_TRAINING_TIME/(double)Simulator.TOTAL_TRAINING_NUMBER));
		out.printf(Locale.US, "%.3f\n", (Simulator.TOTAL_PT_TIME/(double)Simulator.TOTAL_PT_NUMBER));
		out.printf(Locale.US, "%.3f\n", (Simulator.TOTAL_MASSAGE_TIME/(double)Simulator.TOTAL_MASSAGE_NUMBER));
		out.printf(Locale.US, "%.3f\n", ((Simulator.TOTAL_TRAINING_TIME+Simulator.TOTAL_TRAINING_WAIT+Simulator.TOTAL_PT_TIME+Simulator.TOTAL_PT_WAIT)/(double)Simulator.TOTAL_TRAINING_NUMBER));
		out.printf(Locale.US, "%d %.3f\n", physiotherapyWaitTimeQueue.peek().id, physiotherapyWaitTimeQueue.peek().ptWaitTime);
		if(!massageWaitTimeQueue.isEmpty()) {
			out.printf(Locale.US, "%d %.3f\n", massageWaitTimeQueue.peek().id, massageWaitTimeQueue.peek().mWaitTime);
		}
		else {
			out.println("-1 -1");
		}
		out.println(Simulator.INVALID);
		out.println(Simulator.CANCELLED);
		out.printf(Locale.US, "%.3f", Simulator.TIME);
	}
}