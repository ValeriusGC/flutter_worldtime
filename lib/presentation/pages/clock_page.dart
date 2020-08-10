import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_worldtime/data/model/time_info.dart';
import 'package:flutter_worldtime/data/service/worldtime_api.dart';
import 'package:flutter_worldtime/presentation/widgets/clock_container.dart';
import 'package:flutter_worldtime/presentation/widgets/clock_hands.dart';
import 'package:intl/intl.dart';
import 'package:state_notifier/state_notifier.dart';

class TimeNotifier extends StateNotifier<DateTime> {
  TimeNotifier() : super(DateTime.now()) {
    Timer.periodic(Duration(seconds: 1), (timer) {
      state = DateTime.now();
    });
  }
}

// final timeProvider = StateNotifierProvider((_) => TimeNotifier());
//
final timeProvider = StateProvider<DateTime>((ref) => DateTime.now());

final timezone = FutureProvider<TimeInfo>((ref) async {
  return WorldTimeApi.getCurrentTime();
});

class ClockPage extends StatefulWidget {
  @override
  _ClockPageState createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      timeProvider.read(context).state =
          timeProvider.read(context).state.add(Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Spacer(),
              MaterialButton(
                padding: const EdgeInsets.all(16.0),
                color: Colors.pink,
                shape: CircleBorder(),
                child: Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
          Container(
            child: Consumer((context, watch) {
              final time = watch(timeProvider).state;
              return Column(
                children: [
                  ClockContainer(
                    child: CustomPaint(
                      painter: ClockHands(time),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Consumer((context, watch) {
                    final timeinfo = watch(timezone);
                    return timeinfo.when(
                        data: (timeinfo) => Text(
                              timeinfo?.timezone ?? '',
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.w500,
                                fontSize: 24.0,
                              ),
                            ),
                        loading: () => const CircularProgressIndicator(),
                        error: (err, stack) => Container());
                  }),
                  Text(
                    DateFormat.jm().format(time),
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  const SizedBox(height: 10.0),
                ],
              );
            }),
          ),
          SizedBox(
            height: 200,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              scrollDirection: Axis.horizontal,
              children: [
                Card(
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "New York, USA",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 20.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "+3HRS | EST",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        Text(
                          DateFormat.jm().format(DateTime.now()),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
