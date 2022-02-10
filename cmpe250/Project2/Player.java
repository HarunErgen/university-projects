public class Player implements Comparable<Player> {
	int id;
	int skill;
	double trainingTime = 0;
	double ptTime = 0;
	double ptWaitTime = 0;
	double mWaitTime = 0;
	int massageLimit = 1;
	boolean busy = false;
	
	Player(int id, int skill){
		this.id = id;
		this.skill = skill;
	}

	@Override
	public int compareTo(Player o) {
		if(this.id < o.id) {
			return -1;
		}
		if(this.id > o.id) {
			return 1;
		}
		return 0;
	}
}
