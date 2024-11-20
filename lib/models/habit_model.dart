class Habit {
  String name;
  String period;
  String time;
  Map<String, bool> weekDays;
  bool isCompleted;

  Habit({
    required this.name,
    required this.period,
    required this.time,
    Map<String, bool>? weekDays,
    this.isCompleted = false,
  }) : weekDays = weekDays ?? {
    'Mon': false,
    'Tue': false,
    'Wed': false,
    'Thu': false,
    'Fri': false,
    'Sat': false,
    'Sun': false,
  };

  Map<String, dynamic> toJson() => {
    'name': name,
    'period': period,
    'time': time,
    'weekDays': weekDays,
    'isCompleted': isCompleted,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    name: json['name'],
    period: json['period'],
    time: json['time'],
    weekDays: Map<String, bool>.from(json['weekDays'] ?? {}),
    isCompleted: json['isCompleted'] ?? false,
  );
}