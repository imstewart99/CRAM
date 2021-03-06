package cram_project;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.TimeUnit;

public class Main {
	
	/*
	______________________________________________________________________________________________________________
	|NEXT ISSUE:																								  |
	|	- ENSURE THAT WHEN MOVING WORKLOADS FORWARD A DATE, THE WORKLOAD ISN'T SURPASSING IT'S SUBJECT'S END DATE |
	|_____________________________________________________________________________________________________________|
	*/
	
	//MAIN METHOD 
	public static void main(String[] args) {
		
		ArrayList<Subject> subjects = new ArrayList<Subject>();
		ArrayList<Date> skip_dates = new ArrayList<Date>();
		
		Subject CSF = new Subject(
				"CSF",
				27, 
				new ArrayList<Integer>(Arrays.asList(1, 2, 3)),
				new GregorianCalendar(2021, Calendar.MAY, 1).getTime(), 
				new GregorianCalendar(2021, Calendar.MAY, 22).getTime(), 
				new GregorianCalendar(2021, Calendar.MAY, 23).getTime()
				);
		Subject MHCI = new Subject(
				"MHCI",
				11, 
				new ArrayList<Integer>(Arrays.asList(1, 2)),
				new GregorianCalendar(2021, Calendar.MAY, 1).getTime(), 
				new GregorianCalendar(2021, Calendar.MAY, 20).getTime(), 
				new GregorianCalendar(2021, Calendar.MAY, 21).getTime()
				);
		Subject PSD = new Subject(
				"PSD",
				12, 
				new ArrayList<Integer>(Arrays.asList(1)),
				new GregorianCalendar(2021, Calendar.MAY, 4).getTime(), 
				new GregorianCalendar(2021, Calendar.MAY, 25).getTime(), 
				new GregorianCalendar(2021, Calendar.MAY, 27).getTime()
				);
		
		subjects.add(CSF);
		subjects.add(MHCI);
		subjects.add(PSD);
		
		//add exam dates to skip_dates list
		for(int i=0; i<subjects.size(); i++) {
			if(!skip_dates.contains(subjects.get(i).examDate)) {
				skip_dates.add(subjects.get(i).examDate);
			}
		}
		
		//spreading out workload process
		Map<Date, HashMap<String, ArrayList<Workload>>> calendar = new HashMap<Date, HashMap<String, ArrayList<Workload>>>();
		for(Subject subject : subjects) {
			long total_days = TimeUnit.DAYS.convert((subject.endDate.getTime() - subject.startDate.getTime()), TimeUnit.MILLISECONDS);	//1 + (endDate - startDate)
			
			//if exam date within startDate & endDate, decrease study time (days) by 1 day
			for (Date date : skip_dates) {
				if(date.after(subject.startDate) && date.before(subject.endDate)) {
					total_days -= 1;
				}
			}
			
			//evenly spread remaining workload between available days.
			int workPosition = 0;
			Date dateToStore = subject.startDate;
			double skipValue = 0.0;
			double remainingSize = (double)subject.remainingWork.size()-1;

			//Finds evenly spread out values between 0.0 and total available days.
			//Start-date + the floor of each value is the date a workload is to be completed.
			for(double i=0.0; i<=total_days+0.0001; i += total_days/remainingSize) {
				dateToStore = incrementDateBy(subject.startDate, Math.floor(i)+skipValue);
				if(skip_dates.contains(dateToStore)) {
					skipValue += 1.0;
					dateToStore = incrementDateBy(subject.startDate, Math.floor(i)+skipValue);
				}
				calendar.putIfAbsent(dateToStore, new HashMap<>());
				calendar.get(dateToStore).putIfAbsent(subject.name, new ArrayList<>());
				calendar.get(dateToStore).get(subject.name).add(subject.remainingWork.get(workPosition));
				workPosition += 1;
			}	
		}
		
		//if previous date contains 2 or more workloads than current day, take away 1 workload from previous and add to current
		Map<Date, HashMap<String, ArrayList<Workload>>> sortedMap = new TreeMap<Date, HashMap<String, ArrayList<Workload>>>(calendar);
		
		int prevDifficulty = -99999;
		Date prevDate = null;
		for(Date date : sortedMap.keySet()) {
			int currentDifficulty = 0;
			for(String subject : sortedMap.get(date).keySet()) {
				for(Workload wl : sortedMap.get(date).get(subject)) {
					currentDifficulty += wl.difficulty;
				}
			}
			//if previous date has 2 or more workloads than current date, use wlToMove method to decide which workloads in the
			//previous date to move forward to the current date.
			if(prevDifficulty-currentDifficulty>1) {
				HashMap<String, ArrayList<Workload>> wlToMove = findWlToMove(sortedMap.get(prevDate), prevDifficulty-currentDifficulty);
				
				for(String subj : wlToMove.keySet()) {
					for(Workload wl : wlToMove.get(subj)) {
						sortedMap.get(date).putIfAbsent(subj, new ArrayList<>());
						sortedMap.get(date).get(subj).add(wl);
						sortedMap.get(prevDate).get(subj).remove(wl);
						if(sortedMap.get(prevDate).get(subj).isEmpty()) {
							sortedMap.get(prevDate).remove(subj);
						}
					}
				}
			}
			prevDifficulty = currentDifficulty;
			prevDate = date;
		}
		
		//print the results for testing purposes
		int weight;
		for(Date date : sortedMap.keySet()) {
			weight = 0;
			for(String subject : sortedMap.get(date).keySet()) {
				for(Workload wl : sortedMap.get(date).get(subject)) {
					System.out.println("Date: " + date + "--- Subject: " + subject + "--- Workload: " + wl.workloadNo);
					weight += wl.difficulty;
				}
			}
			System.out.println("Weight: " + weight);
			System.out.println();
		}
	}
	
	//helper method to increment a date by a number of days
	public static Date incrementDateBy(Date currentDate, double dta) {
		Calendar c = Calendar.getInstance(); 
		c.setTime(currentDate); 
		c.add(Calendar.DATE, (int)dta);
		return c.getTime();
	}
	
	//helper method to find out which workloads to move from previous date to current date for equal spreading purposes.
	public static HashMap<String, ArrayList<Workload>> findWlToMove(HashMap<String, ArrayList<Workload>> workload, Integer difficulty) {
		HashMap<String, ArrayList<Workload>> wlToMove = new HashMap<>();
		ArrayList<Workload> finalWl;
		Integer currentDifficultyTotal = 0;
		for(String subject : workload.keySet()) {
			for(Workload wl : workload.get(subject)) {
				if(wl.difficulty == difficulty) {
					finalWl = new ArrayList<>(Arrays.asList(wl));
					wlToMove = new HashMap<>();
					wlToMove.put(subject, finalWl);
					return wlToMove;
				}
				else if(wl.difficulty <= difficulty-1 && currentDifficultyTotal < difficulty-wl.difficulty) {
					if(wlToMove.containsKey(subject)) {
						wlToMove.get(subject).add(wl);
					}
					else {
						finalWl = new ArrayList<>(Arrays.asList(wl));
						wlToMove.put(subject, finalWl);
					}
					currentDifficultyTotal += wl.difficulty;
				}
			}
		}
		if(wlToMove.isEmpty()) {
			return null;
		}
		return wlToMove;
	}
}
