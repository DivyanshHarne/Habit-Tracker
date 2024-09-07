import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/app_settings.dart';
import '../models/habit.dart';

class HabitDatabase extends ChangeNotifier{
  static late Isar isar;

  //S E T  U P

  // I N I T I A L I S E   D A T A B A S E
  static Future<void> initialize() async{
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
  }

  // Save the first date of app start-up(for heatmap)
  Future<void> saveFirstLaunchDate() async{
    final existingSettings = await isar.appSettings.where().findFirst();
    if(existingSettings==null){
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // get the first date of app start-up(for heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }
  // CRUD OPERATIONS

  // List of habits
  final List<Habit> currentHabits = [];
  // C R E A T E a new habit
  Future<void> addHabit(String habitName) async{
    // create a new habit
    final newHabit = Habit()..name = habitName;
    // save it to db
    await isar.writeTxn(() => isar.habits.put(newHabit));
    //re-read from db
    readHabits();
  }
  // R E A D from database
  Future<void> readHabits() async{
    //fetch all the habits from db
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);
    //update UI
    notifyListeners();
  }
  // U P D A T E - check habit on/off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    //find the specific habit
    final habit = await  isar.habits.get(id);
    //update the completion status
    if(habit != null){
      await isar.writeTxn(()async {
        //if habit is completed then --> add current date to the completedDays list
        if(isCompleted && !habit.completedDays.contains(DateTime.now())){
          //today
          final today = DateTime.now();
          // add the current date if it is not already in the list
          habit.completedDays.add(DateTime(today.year,today.month, today.day));
        }
        // if habit is NOT completed then --> remove current date from the completedDays list
        else{
          // remove the current date if the habit is marked as NOT completed
          habit.completedDays.removeWhere((date) =>
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day
          );
        }
        //save the updated habits back to db
        await isar.habits.put(habit);
      });
    }
    //re-read from the db
    readHabits();
  }
  // U P D A T E the name
  Future<void> updateHabitName(int id, String newName) async{
    //find the specific habit
    final habit = await isar.habits.get(id);
    // update the habit name
    if(habit != null){
      //update the name
      await isar.writeTxn(() async {
        habit.name = newName;
        //save updated habit back to  db
        await isar.habits.put(habit);
      });
    }
    // re-read from the database
    readHabits();
  }

  // D E L E T E  habit
  Future<void> deleteHabit(int id)async {
    //performing the deletion
    await isar.writeTxn(() async{
      await isar.habits.delete(id);
    });
    //re-read from the db
    readHabits();
  }
}