package cram_project;

import java.util.ArrayList;
import java.util.Date;

public class Subject {

	String name;
	int workloads;
	ArrayList<Integer> workCompleted;
	Date startDate;
	Date endDate;
	Date examDate;
	ArrayList<Workload> remainingWork;
	
	public Subject(String _name, int _workloads, ArrayList<Integer> _workCompleted, Date _startDate, Date _endDate, Date _examDate) {
		this.name = _name;
		this.workloads = _workloads;
		this.workCompleted = _workCompleted;
		this.startDate = _startDate;
		this.endDate = _endDate;
		this.examDate = _examDate;
		this.remainingWork = find_workload();
	}
	
	public ArrayList<Workload> find_workload() {
		ArrayList<Workload> workLoad = new ArrayList<>();
		for(int i=1; i<workloads+1; i++) {
			if(!workCompleted.contains(i)) {
				workLoad.add(new Workload (i, 1));
			}
		}
		return workLoad;
	}
	
}
