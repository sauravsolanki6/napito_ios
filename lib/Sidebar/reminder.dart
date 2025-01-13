import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:ms_salon_task/Colors/custom_colors.dart';
import 'package:ms_salon_task/homepage.dart';
import 'package:ms_salon_task/tip_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ReminderDialog extends StatefulWidget {
  @override
  _ReminderDialogState createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  String _selectedReminder = '';
  bool _isReminderSelected = false;
  final List<String> reminderOptions = [
    'Don\'t remind',
    '15 mins',
    '30 mins',
    '45 mins',
    '60 mins'
  ];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AudioPlayer audioPlayer = AudioPlayer();

  // Global variable to store the appointment time (example: 12:30 PM)
  DateTime? appointmentTime;
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadAppointmentTime();
  }

  Future<void> _loadAppointmentTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAppointmentTime = prefs.getString('appointment_time');
    if (savedAppointmentTime != null) {
      // Parse the saved appointment time string to DateTime
      setState(() {
        appointmentTime = DateTime.parse(savedAppointmentTime);
      });
      print('appointmentTime is $appointmentTime');
    } else {
      // Default time if nothing is saved
      setState(() {
        appointmentTime =
            DateTime(2024, 11, 27, 13, 48); // Example time (12:30 PM)
      });
    }
  }

  void _initializeNotifications() {
    var androidInitialization = AndroidInitializationSettings('app_icon');
    var initializationSettings =
        InitializationSettings(android: androidInitialization);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String reminderTime) async {
    // Local notification setup
    var androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Notifications',
      channelDescription: 'Channel for appointment reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
          'buzzer'), // without .mp3 extension
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    // Show local notification
    await flutterLocalNotificationsPlugin.show(
      0,
      'Appointment Reminder for your Booking',
      'Reminder for your appointment: $reminderTime before',
      notificationDetails,
      payload: 'item x',
    );

    // Simulate alarm by playing sound again
    await _playAlarmSound();

    // Send Firebase Notification (FCM)
    await _sendFirebaseNotification(reminderTime);
  }

  Future<void> _sendFirebaseNotification(String reminderTime) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Construct FCM payload
    Map<String, String> notificationPayload = {
      'title': 'Appointment Reminder for your Booking',
      'body': 'Reminder for your appointment: $reminderTime before',
    };

    try {
      // Sending notification via FCM
      await messaging.subscribeToTopic(
          'appointment_reminders'); // Subscribe to a topic or target individual token
      await messaging.sendMessage(
        to: 'appointment_topic', // or a device token
        data: notificationPayload,
      );
      print('Firebase Notification Sent');
    } catch (e) {
      print('Error sending Firebase notification: $e');
    }
  }

  Future<void> _playReminderSoundAndVibrate() async {
    try {
      // Play the alarm sound
      await audioPlayer.play(AssetSource('buzzer.mp3'));

      // Stop the sound after 2 seconds
      await Future.delayed(Duration(seconds: 2));
      await audioPlayer.stop();

      // Trigger vibration if possible
      if (await Vibrate.canVibrate) {
        Vibrate.vibrate();
      }
    } catch (e) {
      print('Error playing sound or vibrating: $e');
    }
  }

  Future<void> _playAlarmSound() async {
    // Play alarm sound
    await audioPlayer.play(
        AssetSource('buzzer.mp3')); // Ensure you have an alarm sound asset
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogMaxWidth = screenWidth * 0.8;
    bool isBookingTimeExceeded =
        appointmentTime != null && DateTime.now().isAfter(appointmentTime!);
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Appointment Reminder',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: screenWidth < 400 ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            // Latest Booking Time Display
            Text(
              appointmentTime != null
                  ? 'Latest Booking: ${appointmentTime!.day.toString().padLeft(2, '0')}/${appointmentTime!.month.toString().padLeft(2, '0')}/${appointmentTime!.year} '
                      'at ${appointmentTime!.hour.toString().padLeft(2, '0')}:${appointmentTime!.minute.toString().padLeft(2, '0')}'
                  : 'No booking time available',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: screenWidth < 400 ? 14 : 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ),
            if (isBookingTimeExceeded)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Booking time exceeded. You can\'t set a reminder now. Please create a new booking.',
                  style: TextStyle(
                    color: Colors.red, // Red color for exceeded time
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
      content: Container(
        width: dialogMaxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: reminderOptions.map((option) {
            return InkWell(
              onTap: () {
                setState(() {
                  if (_selectedReminder == option) {
                    // If the selected option is already tapped, deselect it
                    _selectedReminder = '';
                    _isReminderSelected =
                        false; // Disable the "Set Reminder" button
                  } else {
                    // If it's not selected, select it
                    _selectedReminder = option;
                    _isReminderSelected =
                        true; // Enable the "Set Reminder" button
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    Icon(
                      _selectedReminder == option
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: _selectedReminder == option
                          ? CustomColors.backgroundtext
                          : Colors.grey[500],
                      size: 22.0,
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        option,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontSize: screenWidth < 400 ? 14 : 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        // Set Reminder Button
        TextButton(
          onPressed: _isReminderSelected || _selectedReminder == "Don't remind"
              ? () async {
                  // Check if the "Don't remind" option is selected
                  if (_selectedReminder == "Don't remind") {
                    // Reset reminder logic to behave as before, meaning no reminder is set
                    print('Reminder is disabled (No reminder set).');
                    await flutterLocalNotificationsPlugin.cancelAll();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reminder has been disabled.'),
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                                title: '',
                              )),
                    );
                    // Close the dialog
                    // Navigator.pop(context);
                    return; // Exit early if no reminder is to be set
                  }

                  // Check if the booking time has been exceeded
                  if (appointmentTime != null &&
                      DateTime.now().isAfter(appointmentTime!)) {
                    // Show a dialog box for exceeded booking time
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        title: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: CustomColors.backgroundtext, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Booking Time Exceeded',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          'The booking time has passed. Please create a new booking to continue.',
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[700],
                              height: 1.5, // Line height for better readability
                            ),
                          ),
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(
                                          title: '',
                                        )),
                              );
                            },
                            child: Text(
                              'OK',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.backgroundtext,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 12.0),
                            ),
                          ),
                        ],
                      ),
                    );
                    return; // Prevent further execution if the booking time has passed
                  }

                  // Handle Reminder Time Validation for valid reminders
                  Duration reminderDuration;
                  switch (_selectedReminder) {
                    case '15 mins':
                      reminderDuration = Duration(minutes: 15);
                      break;
                    case '30 mins':
                      reminderDuration = Duration(minutes: 30);
                      break;
                    case '45 mins':
                      reminderDuration = Duration(minutes: 45);
                      break;
                    case '60 mins':
                      reminderDuration = Duration(minutes: 60);
                      break;
                    default:
                      return;
                  }

                  DateTime reminderTime =
                      appointmentTime!.subtract(reminderDuration);

                  // Check if the reminder time is in the past compared to the current time
                  if (reminderTime.isBefore(DateTime.now())) {
                    // Show dialog indicating that the reminder cannot be set
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        title: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: CustomColors.backgroundtext, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Invalid Reminder Time',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          'The reminder cannot be set for this time because it would be in the past.\n\nLatest Appointment time: ${appointmentTime!.hour.toString().padLeft(2, '0')}:${appointmentTime!.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[700],
                              height: 1.5, // Line height for better readability
                            ),
                          ),
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text(
                              'OK',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.backgroundtext,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 12.0),
                            ),
                          ),
                        ],
                      ),
                    );
                    return; // Prevent setting reminder if it's invalid
                  }

                  // If reminder is valid, set it as before
                  Duration timeDifference =
                      reminderTime.difference(DateTime.now());
                  Future.delayed(timeDifference, () async {
                    await _showNotification(_selectedReminder);
                    await _playReminderSoundAndVibrate();
                  });

                  print(
                      'Reminder set for: $_selectedReminder at $reminderTime');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Reminder set for $_selectedReminder before your appointment!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );

                  Navigator.pop(context); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              title: '',
                            )), // Replace HomePage() with your actual home page widget
                  );
                }
              : null,
          child: Text(
            'Set Reminder',
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                fontSize: screenWidth < 400 ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor:
                _isReminderSelected || _selectedReminder == "Don't remind"
                    ? CustomColors.backgroundtext // active color
                    : Colors.grey, // grey color when disabled
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),

        // Close Button
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Close',
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                fontSize: screenWidth < 400 ? 14 : 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
