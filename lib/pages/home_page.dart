import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit_model.dart';
import '../services/habit_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _habitService = HabitService();
  List<Habit> _habits = [];
  List<Habit> _completedHabits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() async {
    final habits = await _habitService.getHabits();
    final completedHabits = await _habitService.getCompletedHabits();
    setState(() {
      _habits = habits;
      _completedHabits = completedHabits;
    });
  }

  void _showAddHabitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddHabitDialog(onHabitAdded: _loadHabits);
      },
    );
  }

  void _completeHabit(Habit habit) async {
    await _habitService.completeHabit(habit);
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Active Habits
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Active Habits',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color:CupertinoColors.lightBackgroundGray,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _habits.length,
                    itemBuilder: (context, index) {
                      final habit = _habits[index];
                      return HabitTile(
                        habit: habit,
                        onComplete: () => _completeHabit(habit),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Completed Habits
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Completed Habits',
                    style: GoogleFonts.poppins(
                      color:CupertinoColors.lightBackgroundGray,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _completedHabits.length,
                    itemBuilder: (context, index) {
                      final habit = _completedHabits[index];
                      return ListTile(
                        title: Text(
                          habit.name,
                          style: GoogleFonts.poppins(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Text(
                          '${habit.period} - ${habit.time}',
                          style: GoogleFonts.poppins(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context),
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HabitTile extends StatefulWidget {
  final Habit habit;
  final VoidCallback onComplete;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onComplete,
  });

  @override
  _HabitTileState createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        widget.habit.name,
        style: GoogleFonts.poppins(),
      ),
      subtitle: Text(
        '${widget.habit.period} - ${widget.habit.time}',
        style: GoogleFonts.poppins(),
      ),
      children: [
        Wrap(
          spacing: 8,
          children: widget.habit.weekDays.keys.map((day) {
            final isActive = widget.habit.weekDays[day]!;
            return ChoiceChip(
              label: Text(day),
              selected: isActive,
              onSelected: (bool selected) {
                setState(() {
                  widget.habit.weekDays[day] = selected;
                });
              },
              selectedColor: Colors.redAccent,
              backgroundColor: Colors.grey[300],
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: widget.onComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
          ),
          child: Text(
            'Complete Habit',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class AddHabitDialog extends StatefulWidget {
  final VoidCallback onHabitAdded;

  const AddHabitDialog({
    super.key,
    required this.onHabitAdded,
  });

  @override
  _AddHabitDialogState createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _habitNameController = TextEditingController();
  final _habitService = HabitService();
  String _selectedPeriod = 'Weekly';
  TimeOfDay? _selectedTime;
  Map<String, bool> _selectedDays = {
    'Mon': false,
    'Tue': false,
    'Wed': false,
    'Thu': false,
    'Fri': false,
    'Sat': false,
    'Sun': false,
  };

  void _saveHabit() {
    if (_habitNameController.text.isNotEmpty && _selectedTime != null) {
      final habit = Habit(
        name: _habitNameController.text,
        period: _selectedPeriod,
        time: _selectedTime!.format(context),
        weekDays: _selectedDays,
      );

      _habitService.addHabit(habit);
      widget.onHabitAdded();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add New Habit',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _habitNameController,
              decoration: InputDecoration(
                labelText: 'Enter Habit Name',
                labelStyle: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Notification Time:',
                  style: GoogleFonts.poppins(),
                ),
                TextButton(
                  onPressed: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedTime = pickedTime;
                      });
                    }
                  },
                  child: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select Time',
                    style: GoogleFonts.poppins(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Habit Period:',
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  items: ['Weekly', 'Monthly']
                      .map((period) => DropdownMenuItem(
                    value: period,
                    child: Text(
                      period,
                      style: GoogleFonts.poppins(),
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Select Active Days:',
              style: GoogleFonts.poppins(),
            ),
            Wrap(
              spacing: 8,
              children: _selectedDays.keys.map((day) {
                return ChoiceChip(
                  label: Text(day),
                  selected: _selectedDays[day]!,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedDays[day] = selected;
                    });
                  },
                  selectedColor: Colors.redAccent,
                  backgroundColor: Colors.grey[300],
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: _saveHabit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: Text(
            'Add',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _habitNameController.dispose();
    super.dispose();
  }
}