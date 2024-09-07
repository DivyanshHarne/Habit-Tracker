//given a habit list of completion days
//is habit completed today
import '../models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completedDays){
  final today  = DateTime.now();
  return completedDays.any((date) =>
    date.year == today.year &&
    date.month == today.month &&
    date.day == today.day
  );
}

// prepare the heatmap datasets
Map<DateTime, int> prepHeatMapDataset(List<Habit> habits){
  Map<DateTime, int> dataset = {};

  for(var habit in habits){
    for(var date in habit.completedDays){
      // normalizing date to avoid time mismatch
      final normalizedDate = DateTime(date.year, date.month, date.day);

      //if the date already exists in the datasets, increment it's count
      if(dataset.containsKey(normalizedDate)){
        dataset[normalizedDate] =  dataset[normalizedDate]! + 1;
      }else{
        //initialize with a count of one
        dataset[normalizedDate] =  1;
      }
    }
  }
  return dataset;
}