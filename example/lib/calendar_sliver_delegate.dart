import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_advanced_calendar/flutter_advanced_calendar.dart';

class CalendarSliverDelegate implements SliverPersistentHeaderDelegate {
  CalendarSliverDelegate({
    required this.title,
    required this.topPadding,
    this.trailing,
    required this.scrollController,
    required this.controller,
  });

  final events = <DateTime>[
    DateTime.now(),
    DateTime(2022, 10, 10),
  ];

  final String title;
  final double topPadding; // MediaQuery.of(context).padding.top,
  final Widget? trailing;
  final ScrollController scrollController;
  final AdvancedCalendarController controller;

  /// max height
  @override
  double get maxExtent => (32.0 * 6) + 100;

  /// collapsed height
  @override
  double get minExtent => 32.0 + 100;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double height = maxExtent - shrinkOffset > minExtent ? maxExtent - shrinkOffset : minExtent;
    final percentage = (height - minExtent) / (maxExtent - minExtent);

    return Container(
      color: Colors.black,
      height: height,
      // width: double.infinity,
      child: AdvancedCalendar(
        controller: controller,
        innerDot: true,
        preloadMonthViewAmount: 4 * 12, // 4 years
        preloadWeekViewAmount: 4 * 51,
        parentScrollController: scrollController,
        events: events,
        startWeekDay: 7,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration => PersistentHeaderShowOnScreenConfiguration(
        minShowOnScreenExtent: minExtent,
        maxShowOnScreenExtent: maxExtent,
      );

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration => null;

  @override
  TickerProvider? get vsync => null;
}
