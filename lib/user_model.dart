import 'package:flutter/material.dart';

class User {
  String username;
  String password;
  String bio;
  String profileImage;
  DateTime? quizCompletedOn;
  String? parentPasscode;
  Duration totalScreenTime;
  Duration dailyTimeLimit;
  DateTime? lastScreenTimeUpdate;
  TimeOfDay? allowedStartTime;
  TimeOfDay? allowedEndTime;

  User({
    required this.username,
    required this.password,
    this.bio = 'No bio yet',
    this.profileImage = 'default',
    this.quizCompletedOn,
    this.parentPasscode,
    this.totalScreenTime = Duration.zero,
    this.dailyTimeLimit = const Duration(hours: 1),
    this.lastScreenTimeUpdate,
    this.allowedStartTime,
    this.allowedEndTime,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'bio': bio,
    'profileImage': profileImage,
    'quizCompletedOn': quizCompletedOn?.toIso8601String(),
    'parentPasscode': parentPasscode,
    'totalScreenTime': totalScreenTime.inSeconds,
    'dailyTimeLimit': dailyTimeLimit.inSeconds,
    'lastScreenTimeUpdate': lastScreenTimeUpdate?.toIso8601String(),
    'allowedStartTime': allowedStartTime != null
        ? {'hour': allowedStartTime!.hour, 'minute': allowedStartTime!.minute}
        : null,
    'allowedEndTime': allowedEndTime != null
        ? {'hour': allowedEndTime!.hour, 'minute': allowedEndTime!.minute}
        : null,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    username: json['username'] ?? '',
    password: json['password'] ?? '',
    bio: json['bio'] ?? 'No bio yet',
    profileImage: json['profileImage'] ?? 'default',
    quizCompletedOn: json['quizCompletedOn'] != null
        ? DateTime.parse(json['quizCompletedOn'])
        : null,
    parentPasscode: json['parentPasscode'],
    totalScreenTime: Duration(seconds: json['totalScreenTime'] ?? 0),
    dailyTimeLimit: Duration(seconds: json['dailyTimeLimit'] ?? 3600),
    lastScreenTimeUpdate: json['lastScreenTimeUpdate'] != null
        ? DateTime.parse(json['lastScreenTimeUpdate'])
        : null,
    allowedStartTime: json['allowedStartTime'] != null
        ? TimeOfDay(
            hour: json['allowedStartTime']['hour'],
            minute: json['allowedStartTime']['minute'],
          )
        : null,
    allowedEndTime: json['allowedEndTime'] != null
        ? TimeOfDay(
            hour: json['allowedEndTime']['hour'],
            minute: json['allowedEndTime']['minute'],
          )
        : null,
  );
}