import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_state.dart';

class ParentDashboardPage extends StatelessWidget {
  const ParentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DashboardCard(
              title: 'Progress Tracking',
              description:
                  'Track your child\'s learning progress through detailed reports on time spent, skills mastered, and skills that need focus.',
              icon: Icons.bar_chart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressTrackingPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            DashboardCard(
              title: 'Time Management',
              description:
                  'Set daily time limits and schedule app usage to ensure a healthy technology balance.',
              icon: Icons.schedule,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimeManagementPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressTrackingPage extends StatelessWidget {
  const ProgressTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Math Skills'),
            subtitle: Text('Time Spent: 2 hours | Mastery: 85%'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Reading Skills'),
            subtitle: Text('Time Spent: 1.5 hours | Mastery: 90%'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.warning, color: Colors.orange),
            title: Text('Science Skills'),
            subtitle: Text('Time Spent: 1 hour | Mastery: 65% - Needs Focus'),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class TimeManagementPage extends StatefulWidget {
  @override
  _TimeManagementPageState createState() => _TimeManagementPageState();
}

class _TimeManagementPageState extends State<TimeManagementPage> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  double _dailyLimitHours = 1.0;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthState>();
    _startTime = authState.allowedStartTime ?? const TimeOfDay(hour: 8, minute: 0);
    _endTime = authState.allowedEndTime ?? const TimeOfDay(hour: 20, minute: 0);
    _dailyLimitHours = authState.dailyTimeLimit.inHours.toDouble();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          context.read<AuthState>().allowedStartTime = picked;
        } else {
          _endTime = picked;
          context.read<AuthState>().allowedEndTime = picked;
        }
      });
    }
  }

  void _updateDailyLimit(double value) {
    setState(() {
      _dailyLimitHours = value;
      context.read<AuthState>().dailyTimeLimit = Duration(hours: value.toInt());
    });
  }

  @override
  Widget build(BuildContext context) {
    Duration totalScreenTime = context.watch<AuthState>().totalScreenTime;

    String formattedDuration(Duration duration) {
      int hours = duration.inHours;
      int minutes = duration.inMinutes.remainder(60);
      return '$hours hours $minutes minutes';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Time Section
            Row(
              children: [
                const Icon(Icons.timer),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Screen Time Today',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(formattedDuration(totalScreenTime)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),

            // Start Time Section
            Row(
              children: [
                const Icon(Icons.schedule),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Allowed Start Time',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(_startTime?.format(context) ?? 'Not Set'),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _selectTime(context, true),
                ),
              ],
            ),
            const Divider(),

            // End Time Section
            Row(
              children: [
                const Icon(Icons.schedule),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Allowed End Time',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(_endTime?.format(context) ?? 'Not Set'),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _selectTime(context, false),
                ),
              ],
            ),
            const Divider(),

            // Daily Time Limit Section
            const Text(
              'Daily Time Limit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Icon(Icons.timelapse),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        value: _dailyLimitHours,
                        min: 1.0,
                        max: 8.0,
                        divisions: 7,
                        label: '${_dailyLimitHours.toInt()} hours',
                        onChanged: (value) => _updateDailyLimit(value),
                      ),
                      Text('${_dailyLimitHours.toInt()} hours per day'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}