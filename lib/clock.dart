import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Clock extends StatefulWidget {
  const Clock({Key? key}) : super(key: key);
  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  List<TimeOfDay> selectedTimes = [];
  late Timer _timer;
  final player = AudioPlayer(); // Moved player instance to class level

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), _checkAlarms);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _checkAlarms(Timer timer) {
    final now = TimeOfDay.now();
    for (var alarmTime in selectedTimes) {
      if (alarmTime.hour == now.hour && alarmTime.minute == now.minute) {
        playSound();
      }
    }
  }

  Future<void> playSound() async {
    String url = 'sound.mp3'; // Replace 'sound.mp3' with your sound file path
    await player.play(AssetSource(url));
    // Stop sound after 3 seconds
    await Future.delayed(Duration(seconds: 3));
    await player.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 50,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Alarm",style: TextStyle(fontSize: 30),),
              SizedBox(width: 5,)
              ,Icon(Icons.alarm)],),
          Expanded(
            child: ListView.builder(
              itemCount: selectedTimes.length,
              itemBuilder: (BuildContext context, int index) {
                final selectTime = selectedTimes[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        '${selectTime.hourOfPeriod} : ${selectTime.minute} ${selectTime.period == DayPeriod.am ? 'AM' : 'PM'}', // Time with AM/PM
                        style: TextStyle(fontSize: 24),
                      ),
                      subtitle: Text(
                        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', // Date
                        style: TextStyle(fontSize: 15),
                      ),
                      leading: Icon(Icons.alarm_rounded),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Remove the selected time
                          setState(() {
                            selectedTimes.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final TimeOfDay? timeOfDay = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            initialEntryMode: TimePickerEntryMode.dial,
          );
          if (timeOfDay != null) {
            setState(() {
              selectedTimes.add(timeOfDay);
            });
          }
        },
        child: Icon(Icons.access_time),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
