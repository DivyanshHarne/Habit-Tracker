import 'package:flutter/material.dart';
import 'package:habits/components/my_drawer.dart';
import 'package:habits/components/my_habit_tile.dart';
import 'package:habits/components/my_heat_map.dart';
import 'package:habits/database/habit_database.dart';
import 'package:habits/theme/theme_provider.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../util/habit_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    // read the existing habits on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();

    super.initState();
  }

  //text controller
  final TextEditingController textController = TextEditingController();

  //create new habit
  void createNewHabit(){
    showDialog(
        context: context,
        builder: (context)=> AlertDialog(
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: "Create a new habit"
            ),
          ),
          actions: [
            //S A V E  B U T T O N
            MaterialButton(onPressed: (){
              //get the new habit name
              String newHabitName = textController.text;

              //save to db
              context.read<HabitDatabase>().addHabit(newHabitName);
              //pop the box
              Navigator.pop(context);
              //clear the controller
              textController.clear();
            },
            child: const Text("Save"),
            ),
            //C A N C E L  B U T T O N
            MaterialButton(onPressed: (){
              //pop the box
              Navigator.pop(context);
              //clear the controller
              textController.clear();
            },
            child: const Text("Cancel"),)

          ],
        )
    );
  }

  //check habit on and off
  void checkHabitOnOff(bool? value, Habit habit){
    // UPDATE  habit completion status
    if(value != null){
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  //edit habit box
  void editHabitBox(Habit habit){
    //set text controller to habit's current name
    textController.text = habit.name;
    
    showDialog(context: context, builder: (context)=>AlertDialog(
      content: TextField(controller: textController,),
      actions: [
        //U P D A T E    B U T T O N
        MaterialButton(onPressed: (){
          //get the new habit name
          String newHabitName = textController.text;

          //save to db
          context.read<HabitDatabase>().updateHabitName(habit.id, newHabitName);
          //pop the box
          Navigator.pop(context);
          //clear the controller
          textController.clear();
        },
          child: const Text("Update"),
        ),
        //C A N C E L   B U T T O N
        MaterialButton(onPressed: (){
          //pop the box
          Navigator.pop(context);
          //clear the controller
          textController.clear();
        },
          child: const Text("Cancel"),)

      ],
    ));
  }

  //delete habit box
  void deleteHabitBox(Habit habit){
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: const Text("Are you super-duper sure?"),
      actions: [
        //D E L E T E   B U T T O N
        MaterialButton(onPressed: (){

          //delete from db
          context.read<HabitDatabase>().deleteHabit(habit.id);
          //pop the box
          Navigator.pop(context);
          //clear the controller
          textController.clear();
        },
          child: const Text("Delete"),
        ),
        //C A N C E L   B U T T O N
        MaterialButton(onPressed: (){
          //pop the box
          Navigator.pop(context);
        },
          child: const Text("Cancel"),)

      ],
    ));
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          //H E A T M A P
          _buildHeatMap(),

          //H A B I T
          _buildHabitList(),
        ],
      )
    );
  }

  Widget _buildHeatMap(){
    //habit database
    final habitDatabase = context.watch<HabitDatabase>();
    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;
    //return heatmap UI
    return FutureBuilder<DateTime?>(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot){
          // once the data is available --> build heatmap
          if(snapshot.hasData){
            return MyHeatMap(startDate: snapshot.data!, datasets: prepHeatMapDataset(currentHabits));
          }else{
            return Container();
          }
          //handle case where no data is returned
        }
    );
  }

  Widget _buildHabitList(){
    //habit db
    final habitDatabase = context.watch<HabitDatabase>();

    //current habit
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //return the list of habits UI
    return ListView.builder(
      itemCount: currentHabits.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context,index){
          //get each individual habit
          final habit = currentHabits[index];

          //check if the habit is completed today
          bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

          //return habit tile UI
          return MyHabitTile(
            text: habit.name,
            isCompleted: isCompletedToday,
            onChanged: (value)=> checkHabitOnOff(value, habit),
            editHabit: (context)=> editHabitBox(habit),
            deleteHabit: (context)=> deleteHabitBox(habit),
          );

    });
  }
}
