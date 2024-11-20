import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit_model.dart';
import '../services/habit_service.dart';

class HabitsList extends StatefulWidget {
  const HabitsList({super.key});

  @override
  _HabitsListState createState() => _HabitsListState();
}

class _HabitsListState extends State<HabitsList> {
  final _habitService = HabitService();
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() async {
    final habits = await _habitService.getHabits();
    setState(() {
      _habits = habits;
    });
  }

  void _deleteHabit(String habitName) async {
    await _habitService.deleteHabit(habitName);
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        final habit = _habits[index];
        return ListTile(
          title: Text(habit.name, style: GoogleFonts.poppins()),
          subtitle: Text(
            '${habit.period} - ${habit.time}',
            style: GoogleFonts.poppins(),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteHabit(habit.name),
          ),
        );
      },
    );
  }
}