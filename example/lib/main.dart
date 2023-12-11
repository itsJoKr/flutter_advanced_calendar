import 'package:flutter/material.dart';
import 'package:flutter_advanced_calendar/flutter_advanced_calendar.dart';
import 'package:flutter_advanced_calendar_example/calendar_sliver_delegate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _calendarControllerToday = AdvancedCalendarController.today();
  final _calendarControllerCustom =
      AdvancedCalendarController(DateTime(2022, 10, 23));
  final events = <DateTime>[
    DateTime.now(),
    DateTime(2022, 10, 10),
  ];

  late ScrollController _scrollController;


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Calendar Example'),
        ),
        body: Builder(builder: (context) {
          final theme = Theme.of(context);

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: CalendarSliverDelegate(
                  title: 'title',
                  topPadding: MediaQuery.of(context).padding.top,
                  scrollController: _scrollController,
                  controller: _calendarControllerToday,
                ),
              ),
              // SliverToBoxAdapter(
              //   child:
              //   AdvancedCalendar(
              //     controller: _calendarControllerToday,
              //     parentScrollController: _scrollController,
              //     events: events,
              //
              //     startWeekDay: 1,
              //   ),
              // ),
              SliverToBoxAdapter(
                child: Container(
                  height: 300,
                  color: Colors.red,
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 300,
                  color: Colors.yellow,
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 300,
                  color: Colors.red,
                ),
              ),
            ],
            // mainAxisSize: MainAxisSize.max,
            // crossAxisAlignment: CrossAxisAlignment.start,
          );
        }),
      ),
    );
  }
}
