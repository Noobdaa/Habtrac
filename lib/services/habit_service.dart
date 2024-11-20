import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit_model.dart';

class HabitService {
  static const String _habitsKey = 'habits';
  static const String _completedHabitsKey = 'completedHabits';

  Future<List<Habit>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getStringList(_habitsKey) ?? [];
    return habitsJson.map((habitJson) =>
        Habit.fromJson(json.decode(habitJson))
    ).toList();
  }

  Future<List<Habit>> getCompletedHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final completedHabitsJson = prefs.getStringList(_completedHabitsKey) ?? [];
    return completedHabitsJson.map((habitJson) =>
        Habit.fromJson(json.decode(habitJson))
    ).toList();
  }

  Future<void> addHabit(Habit habit) async {
    final prefs = await SharedPreferences.getInstance();
    final habits = await getHabits();
    habits.add(habit);

    final habitsJson = habits.map((habit) =>
        json.encode(habit.toJson())
    ).toList();

    await prefs.setStringList(_habitsKey, habitsJson);
  }

  Future<void> deleteHabit(String habitName) async {
    final prefs = await SharedPreferences.getInstance();
    final habits = await getHabits();
    habits.removeWhere((habit) => habit.name == habitName);

    final habitsJson = habits.map((habit) =>
        json.encode(habit.toJson())
    ).toList();

    await prefs.setStringList(_habitsKey, habitsJson);
  }

  Future<void> completeHabit(Habit habit) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove from habits
    final habits = await getHabits();
    habits.removeWhere((h) => h.name == habit.name);
    final habitsJson = habits.map((h) =>
        json.encode(h.toJson())
    ).toList();
    await prefs.setStringList(_habitsKey, habitsJson);

    // Add to completed habits
    final completedHabits = await getCompletedHabits();
    habit.isCompleted = true;
    completedHabits.add(habit);
    final completedHabitsJson = completedHabits.map((h) =>
        json.encode(h.toJson())
    ).toList();
    await prefs.setStringList(_completedHabitsKey, completedHabitsJson);
  }
}