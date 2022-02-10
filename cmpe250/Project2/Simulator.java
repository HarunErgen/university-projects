import java.util.ArrayList;
import java.util.PriorityQueue;

public abstract class Simulator {
	static double TIME;
	static int CANCELLED = 0;
	static int INVALID = 0;
	static int MAX_TRAINING_LENGTH = 0;
	static int MAX_MASSAGE_LENGTH = 0;
	static int MAX_PT_LENGTH = 0;
	static double TOTAL_TRAINING_WAIT = 0;
	static double TOTAL_TRAINING_TIME = 0;
	static int TOTAL_TRAINING_NUMBER = 0;
	static double TOTAL_PT_WAIT = 0;
	static double TOTAL_PT_TIME = 0;
	static int TOTAL_PT_NUMBER = 0;
	static double TOTAL_MASSAGE_WAIT = 0;
	static double TOTAL_MASSAGE_TIME = 0;
	static int TOTAL_MASSAGE_NUMBER = 0;

	static void simulate(ArrayList<TrainingCoach> TCs, ArrayList<Masseur> Ms, PriorityQueue<Physiotherapist> PTs, 
			ArrayList<Player> players, PriorityQueue<Event> events) {
		Event newEvent = events.poll();
		
		// TRAINING ARRIVAL
		if(newEvent.getClass().toString().equals("class TEventArrival")) {
			TrainingEventArrival training = (TrainingEventArrival) newEvent;
			TIME = training.arrivalTime;
			if (!training.player.busy) {
				training.player.busy = true;
				found: {
					for (TrainingCoach trainingCoach : TCs) {
						if (trainingCoach.available) {
							training.trainingCoach = trainingCoach;
							trainingCoach.available = false;
							training.finishTime = training.arrivalTime + training.duration;
							TOTAL_TRAINING_NUMBER ++;
							TOTAL_TRAINING_TIME += training.duration;
							training.player.trainingTime = training.duration;
							events.add(new TrainingEventLeaving(training.player, trainingCoach, training.finishTime, 0));
							break found;
						}
					}
					TOTAL_TRAINING_WAIT -= TIME;
					TCs.get(0).tcQueue.add(training);
					if(TCs.get(0).tcQueue.size() > MAX_TRAINING_LENGTH) {
						MAX_TRAINING_LENGTH = TCs.get(0).tcQueue.size();
					}
				}
			}
			else {
				CANCELLED++;
			}
		}
		
		// TRAINING LEAVING
		if(newEvent.getClass().toString().equals("class TEventLeaving")) {
			TrainingEventLeaving tLeaving = (TrainingEventLeaving) newEvent;
			TIME = tLeaving.arrivalTime;
			tLeaving.player.busy = false;
			tLeaving.trainingCoach.available = true;
			if(!tLeaving.trainingCoach.tcQueue.isEmpty()) {
				TrainingEventArrival tcQueueNewEvent = tLeaving.trainingCoach.tcQueue.poll();
				TOTAL_TRAINING_WAIT += TIME;
				tcQueueNewEvent.player.busy = false;
				tcQueueNewEvent.arrivalTime = tLeaving.finishTime;
				tcQueueNewEvent.finishTime = tcQueueNewEvent.arrivalTime + tcQueueNewEvent.duration;
				events.add(tcQueueNewEvent);
			}
			events.add(new PhysiotherapyEventArrival(tLeaving.player, null, tLeaving.arrivalTime, 0));
		}
		
		// MASSAGE ARRIVAL
		if(newEvent.getClass().toString().equals("class MEventArrival")) {
			MassageEventArrival massage = (MassageEventArrival) newEvent;
			TIME = massage.arrivalTime;
			if(massage.player.massageLimit > 3) {
				INVALID ++;
			}
			else {
				if (!massage.player.busy) {
					massage.player.busy = true;
					found: {
						for (Masseur masseur : Ms) {
							if (masseur.available) {
								massage.masseur = masseur;
								masseur.available = false;
								massage.player.massageLimit++;
								massage.finishTime = massage.arrivalTime + massage.duration;
								TOTAL_MASSAGE_NUMBER ++;
								TOTAL_MASSAGE_TIME += massage.duration;
								events.add(new MassageEventLeaving(massage.player, masseur, massage.finishTime, 0));
								break found;
							}
						}
						TOTAL_MASSAGE_WAIT -= TIME;
						massage.player.mWaitTime -= TIME;
						Ms.get(0).mQueue.add(massage);
						if(Ms.get(0).mQueue.size() > Simulator.MAX_MASSAGE_LENGTH) {
							Simulator.MAX_MASSAGE_LENGTH = Ms.get(0).mQueue.size();
						}
					}
				}
				else {
					CANCELLED++;
				}
			}
		}
		
		// MASSAGE LEAVING
		if(newEvent.getClass().toString().equals("class MEventLeaving")) {
			MassageEventLeaving mLeaving = (MassageEventLeaving) newEvent;
			TIME = mLeaving.arrivalTime;
			mLeaving.player.busy = false;
			mLeaving.masseur.available = true;
			if(!mLeaving.masseur.mQueue.isEmpty()) {
				MassageEventArrival mQueueNewEvent = mLeaving.masseur.mQueue.poll();
				TOTAL_MASSAGE_WAIT += TIME;
				mQueueNewEvent.player.mWaitTime += TIME;
				mQueueNewEvent.player.busy = false;
				mQueueNewEvent.arrivalTime = mLeaving.finishTime;
				mQueueNewEvent.finishTime = mQueueNewEvent.arrivalTime + mQueueNewEvent.duration;
				
				events.add(mQueueNewEvent);
			}
		}
		
		// PHYSIOTHERAPY ARRIVAL
		if(newEvent.getClass().toString().equals("class PEventArrival")) {
			PhysiotherapyEventArrival pEvent = (PhysiotherapyEventArrival) newEvent;
			TIME = pEvent.arrivalTime;
			pEvent.player.busy = true;
			available: {
				if (checkPTs(PTs, pEvent)) {
					pEvent.physiotherapist.available = false;
					pEvent.finishTime = pEvent.arrivalTime + pEvent.duration;
					TOTAL_PT_NUMBER++;
					TOTAL_PT_TIME += pEvent.duration;
					events.add(new PhysiotherapyEventLeaving(pEvent.player, pEvent.physiotherapist, pEvent.finishTime, 0));
					break available;
				}
				TOTAL_PT_WAIT -= TIME;
				pEvent.player.ptWaitTime -= TIME;
				PTs.peek().physiotherapyQueue.add(pEvent);
				if(PTs.peek().physiotherapyQueue.size() > MAX_PT_LENGTH) {
					MAX_PT_LENGTH = PTs.peek().physiotherapyQueue.size();
				}
			}
		}
		
		// PHYSIOTHERAPY LEAVING
		if(newEvent.getClass().toString().equals("class PEventLeaving")) {
			PhysiotherapyEventLeaving pLeaving = (PhysiotherapyEventLeaving) newEvent;
			TIME = pLeaving.arrivalTime;
			pLeaving.player.busy = false;
			pLeaving.physiotherapist.available = true;
			if(!pLeaving.physiotherapist.physiotherapyQueue.isEmpty()) {
				PhysiotherapyEventArrival ptQueueNewEvent = pLeaving.physiotherapist.physiotherapyQueue.poll();
				TOTAL_PT_WAIT += TIME;
				ptQueueNewEvent.player.ptWaitTime += TIME;
				ptQueueNewEvent.player.busy = false;
				ptQueueNewEvent.arrivalTime = pLeaving.finishTime;
				ptQueueNewEvent.finishTime = ptQueueNewEvent.arrivalTime + ptQueueNewEvent.duration;
				events.add(ptQueueNewEvent);
			}
		}
	}
	
	// CHECK IF ANY PHYSIOTHERAPIST IS AVAILABLE
	static boolean checkPTs(PriorityQueue<Physiotherapist> PTs, PhysiotherapyEventArrival PEvent) {
		PriorityQueue<Physiotherapist> PTsTemp = new PriorityQueue<Physiotherapist>(PTs.comparator());
		while(!PTs.isEmpty()) {
			Physiotherapist pt = PTs.poll();
			PTsTemp.add(pt);
			if(pt.available) {
				PTs.addAll(PTsTemp);
				PEvent.physiotherapist = pt;
				PEvent.duration = pt.serviceTime;
				return true;
			}
		}
		PTs.addAll(PTsTemp);
		return false;
	}
}
