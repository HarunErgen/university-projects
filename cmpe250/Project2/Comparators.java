import java.util.Comparator;

public class Comparators {
	class TrainingComparator implements Comparator<TrainingEventArrival>{
		@Override
		public int compare(TrainingEventArrival o1, TrainingEventArrival o2) {
			if (o1.arrivalTime != o2.arrivalTime) {
				if (o1.arrivalTime < o2.arrivalTime) {
					return -1;
				}
				if (o1.arrivalTime > o2.arrivalTime) {
					return 1;
				}
			}
			else {
				if (o1.player.id < o2.player.id) {
					return -1;
				}
				if (o1.player.id > o2.player.id) {
					return 1;
				}
			}
			return 0;
		}
	}
	class MassageComparator implements Comparator<MassageEventArrival> {
		@Override
		public int compare(MassageEventArrival o1, MassageEventArrival o2) {
			if (o1.player.skill != o2.player.skill) {
				if (o1.player.skill > o2.player.skill) {
					return -1;
				}
				if (o1.player.skill < o2.player.skill) {
					return 1;
				}
			}
			else if (o1.arrivalTime != o2.arrivalTime) {
				if (o1.arrivalTime < o2.arrivalTime) {
					return -1;
				}
				if (o1.arrivalTime > o2.arrivalTime) {
					return 1;
				}
			}
			else {
				if (o1.player.id < o2.player.id) {
					return -1;
				}
				if (o1.player.id > o2.player.id) {
					return 1;
				}
			}
			return 0;
		}
	}
	class PhysiotherapyComparator implements Comparator<PhysiotherapyEventArrival>{
		@Override
		public int compare(PhysiotherapyEventArrival o1, PhysiotherapyEventArrival o2) {
			if (o1.player.trainingTime != o2.player.trainingTime) {
				if (o1.player.trainingTime > o2.player.trainingTime) {
					return -1;
				}
				if (o1.player.trainingTime < o2.player.trainingTime) {
					return 1;
				}
			}
			else if (o1.arrivalTime != o2.arrivalTime) {
				if (o1.arrivalTime < o2.arrivalTime) {
					return -1;
				}
				if (o1.arrivalTime > o2.arrivalTime) {
					return 1;
				}
			}
			else {
				if (o1.player.id < o2.player.id) {
					return -1;
				}
				if (o1.player.id > o2.player.id) {
					return 1;
				}
			}
			return 0;
		}
	}
	class PlayerComparator implements Comparator<Player>{

		@Override
		public int compare(Player o1, Player o2) {
			if(o1.id < o2.id) {
				return -1;
			}
			if(o1.id > o2.id) {
				return 1;
			}
			return 0;
		}

	}
	class PhysiotherapistComparator implements Comparator<Physiotherapist>{
		@Override
		public int compare(Physiotherapist o1, Physiotherapist o2) {
			if(o1.id < o2.id) {
				return -1;
			}
			if(o1.id > o2.id) {
				return 1;
			}
			return 0;
		}
		
	}
	class MassageWaitTimeComparator implements Comparator<Player>{

		@Override
		public int compare(Player o1, Player o2) {
			if (o1.mWaitTime != o2.mWaitTime) {
				if (o1.mWaitTime < o2.mWaitTime) {
					return -1;
				}
				if (o1.mWaitTime > o2.mWaitTime) {
					return 1;
				} 
			}
			else {
				if (o1.id < o2.id) {
					return -1;
				}
				if (o1.id > o2.id) {
					return 1;
				} 
			}
			return 0;
		}

	}
	class PhysiotherapyWaitTimeComparator implements Comparator<Player>{

		@Override
		public int compare(Player o1, Player o2) {
			if(o1.ptWaitTime != o2.ptWaitTime) {
				if(o1.ptWaitTime > o2.ptWaitTime) {
					return -1;
				}
				if(o1.ptWaitTime < o2.ptWaitTime) {
					return 1;
				}
			}
			else {
				if(o1.id < o2.id) {
					return -1;
				}
				if(o1.id > o2.id) {
					return 1;
				}
			}
			return 0;
		}
	}
	class EventComparator implements Comparator<Event>{
		@Override
		public int compare(Event o1, Event o2) {
			
			if (o1.arrivalTime != o2.arrivalTime) {
				if (o1.arrivalTime < o2.arrivalTime) {
					return -1;
				}
				if (o1.arrivalTime > o2.arrivalTime) {
					return 1;
				}
			}
			else {
				if (o1.player.id < o2.player.id) {
					return -1;
				}
				if (o1.player.id > o2.player.id) {
					return 1;
				}
			}
			return 0;
		}
	}
}
