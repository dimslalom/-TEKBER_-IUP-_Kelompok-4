import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_state.dart';
import 'profile_page.dart';
import 'course.dart';
import 'dart:io';
import 'quiz_page.dart';  // Add this import
import 'parentsdashboard.dart'; // Import the Parent's Dashboard page
import 'dart:async';  // Add this for Timer

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authState = AuthState();
  await authState.init();
  
  runApp(
    ChangeNotifierProvider.value(
      value: authState,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: ScreenTimeTracker(
        child: Consumer<AuthState>(
          builder: (context, authState, child) {
            return const Dashboard();
          },
        ),
      ),
    );
  }
}

class ScreenTimeTracker extends StatefulWidget {
  final Widget child;

  const ScreenTimeTracker({
    required this.child,
    super.key,
  });

  @override
  State<ScreenTimeTracker> createState() => ScreenTimeTrackerState();
}

class ScreenTimeTrackerState extends State<ScreenTimeTracker> with WidgetsBindingObserver {
  DateTime? _startTime;
  Timer? _timer;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTracking();
  }

  void _startTracking() {
    if (_timer == null) {
      _startTime = DateTime.now();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateScreenTime();
      });
    }
  }

  void _stopTracking() {
    if (_timer != null) {
      _updateScreenTime();
      _timer!.cancel();
      _timer = null;
    }
  }

  void _updateScreenTime() {
    final authState = context.read<AuthState>();

    if (authState.isLoggedIn && !_isLocked) {
      DateTime now = DateTime.now();
      Duration elapsed = now.difference(_startTime ?? now);
      _startTime = now;
      authState.updateScreenTime(elapsed);

      // Check if time limit is reached
      if (authState.totalScreenTime >= authState.dailyTimeLimit) {
        _lockApp();
        return;
      }

      // Check if current time is within allowed time period
      TimeOfDay nowTime = TimeOfDay.fromDateTime(now);
      if (authState.allowedStartTime != null && authState.allowedEndTime != null) {
        bool isWithinAllowedTime = _isWithinTimeRange(
          nowTime,
          authState.allowedStartTime!,
          authState.allowedEndTime!,
        );
        if (!isWithinAllowedTime) {
          _lockApp();
          return;
        }
      }
    }
  }

  bool _isWithinTimeRange(TimeOfDay now, TimeOfDay start, TimeOfDay end) {
    int nowMinutes = now.hour * 60 + now.minute;
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;

    // Handle cases where end time is on the next day
    if (endMinutes <= startMinutes) {
      endMinutes += 24 * 60; // Add 24 hours worth of minutes
      if (nowMinutes < startMinutes) {
        nowMinutes += 24 * 60; // Add 24 hours if we're past midnight
      }
    }

    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }

  void _lockApp() {
    if (!_isLocked) {
      _isLocked = true;
      _stopTracking();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LockedScreen(onUnlock: _unlockApp),
      ));
    }
  }

  void _unlockApp() {
    setState(() {
      _isLocked = false;
      _startTracking();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTracking();
      final authState = context.read<AuthState>();
      DateTime? lastUpdate = authState.lastScreenTimeUpdate;
      if (lastUpdate != null && !isSameDate(lastUpdate, DateTime.now())) {
        authState.resetDailyScreenTime();
      }
    } else {
      _stopTracking();
    }
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class LockedScreen extends StatelessWidget {
  final VoidCallback onUnlock;

  const LockedScreen({required this.onUnlock, super.key});

  @override
  Widget build(BuildContext context) {
    final passcodeController = TextEditingController();
    final authState = context.read<AuthState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Locked'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Time limit reached or access restricted.\nEnter parent passcode to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passcodeController,
                decoration: const InputDecoration(labelText: 'Parent Passcode'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (passcodeController.text == authState.parentPasscode) {
                    Navigator.of(context).pop();
                    onUnlock();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect passcode')),
                    );
                  }
                },
                child: const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  void navigateToHome(BuildContext context, String section) {
    if (section == 'Courses') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (section == 'Quiz') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QuizPage()),
      );
    } else if (section == "Parent's Dashboard") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ParentDashboardPage()),
      );
    }
  }

  Widget buildSectionButton(
      BuildContext context, String title, String subtitle) {
    bool isQuizCompleted = false;
    if (title == 'Quiz') {
      isQuizCompleted = context.watch<AuthState>().hasCompletedQuizToday();
    }

    return GestureDetector(
      onTap: () => navigateToHome(context, title),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 2, // Restrict text to 2 lines
                    overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                  ),
                ],
              ),
            ),
            if (isQuizCompleted)
              const Icon(Icons.check_circle, color: Colors.green),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: MediaQuery.of(context).size.width * 0.05,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, authState, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good Morning,',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      authState.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: authState.profileImage == 'default'
                        ? const AssetImage('assets/default_avatar.png')
                        : FileImage(File(authState.profileImage)) as ImageProvider,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildSectionButton(
                context,
                'Courses',
                'Engaging courses designed to make learning fun and interactive!',
              ),
              buildSectionButton(
                context,
                'Quiz',
                'Test your knowledge with fun quizzes that make learning exciting!',
              ),
              buildSectionButton(
                context,
                'Daily Challenges',
                'Take on daily challenges to boost your skills and keep learning fresh!',
              ),
              buildSectionButton(
                context,
                'Feedbacks',
                'Receive personalized feedback to help you improve your learning journey!',
              ),
              buildSectionButton(
                context,
                "Parent's Dashboard",
                'Access tools and reports to monitor and support your child\'s learning.',
              ),
            ],
          ),
        );
      },
    );
  }
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, authState, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Courses'),
            backgroundColor: Colors.orange,
          ),
          body: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Your Courses',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfilePage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: authState.profileImage == 'default'
                              ? const AssetImage('assets/default_avatar.png')
                              : FileImage(File(authState.profileImage)) as ImageProvider,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 100,
                        color: Colors.orange[300],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No Courses Available',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Check back later for new courses',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
