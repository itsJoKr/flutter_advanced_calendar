import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'controller.dart';
import 'datetime_util.dart';

part 'date_box.dart';

part 'handlebar.dart';

part 'header.dart';

part 'month_view.dart';

part 'month_view_bean.dart';

part 'week_days.dart';

part 'week_view.dart';

/// Advanced Calendar widget.
class AdvancedCalendar extends StatefulWidget {
  const AdvancedCalendar({
    Key? key,
    this.controller,
    required this.parentScrollController,
    this.onSelect,
    this.startWeekDay,
    this.events,
    this.weekLineHeight = 32.0,
    this.preloadMonthViewAmount = 13,
    this.preloadWeekViewAmount = 21,
    this.weeksInMonthViewAmount = 6,
    this.dotColor,
    this.todayStyle,
    this.headerStyle,
    this.onHorizontalDrag,
    this.innerDot = false,
    this.keepLineSize = false,
    this.calendarTextStyle,
    this.locale,
  })  : assert(
          keepLineSize && innerDot || innerDot && !keepLineSize || !innerDot && !keepLineSize,
          'keepLineSize should be used only when innerDot is true',
        ),
        super(key: key);

  final ScrollController parentScrollController;

  /// Calendar selection date controller.
  final AdvancedCalendarController? controller;

  final Function(DateTime)? onSelect;

  /// Executes on horizontal calendar swipe. Allows to load additional dates.
  final Function(DateTime)? onHorizontalDrag;

  /// Height of week line.
  final double weekLineHeight;

  /// Amount of months in month view to preload.
  final int preloadMonthViewAmount;

  /// Amount of weeks in week view to preload.
  final int preloadWeekViewAmount;

  /// Weeks lines amount in month view.
  final int weeksInMonthViewAmount;

  /// List of points for the week and month
  final List<DateTime>? events;

  /// The first day of the week starts[0-6]
  final int? startWeekDay;

  /// Style of headers date
  final TextStyle? headerStyle;

  /// Style of Today button
  final TextStyle? todayStyle;

  final Color? dotColor;

  /// Show DateBox event in container.
  final bool innerDot;

  /// Keeps consistent line size for dates
  /// Can't be used without innerDot
  final bool keepLineSize;

  /// Text style for dates in calendar
  final TextStyle? calendarTextStyle;

  final String? locale;

  @override
  _AdvancedCalendarState createState() => _AdvancedCalendarState();
}

class _AdvancedCalendarState extends State<AdvancedCalendar> with SingleTickerProviderStateMixin {
  late ValueNotifier<int> _monthViewCurrentPage;

  late AnimationController _animationController;

  late AdvancedCalendarController _controller;
  late double _animationValue;
  late List<ViewRange> _monthRangeList;
  late List<List<DateTime>> _weekRangeList;

  PageController? _monthPageController;
  PageController? _weekPageController;
  Offset? _captureOffset;
  DateTime? _todayDate;
  List<String>? _weekNames;

  @override
  void initState() {
    super.initState();

    final height = widget.weekLineHeight * widget.weeksInMonthViewAmount;

    final monthPageIndex = widget.preloadMonthViewAmount ~/ 2;

    _monthViewCurrentPage = ValueNotifier(monthPageIndex);

    _monthPageController = PageController(
      initialPage: monthPageIndex,
    );

    final weekPageIndex = widget.preloadWeekViewAmount ~/ 2;

    _weekPageController = PageController(
      initialPage: weekPageIndex,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0,
    );

    _animationValue = _animationController.value;

    _controller = widget.controller ?? AdvancedCalendarController.today();
    _todayDate = _controller.value;

    _monthRangeList = List.generate(
      widget.preloadMonthViewAmount,
      (index) => ViewRange.generateDates(
        _todayDate!,
        _todayDate!.month + (index - _monthPageController!.initialPage),
        widget.weeksInMonthViewAmount,
        startWeekDay: widget.startWeekDay,
      ),
    );

    _weekRangeList = _controller.value.generateWeeks(
      widget.preloadWeekViewAmount,
      startWeekDay: widget.startWeekDay,
    );

    _controller.addListener(() {
      _weekRangeList = _controller.value.generateWeeks(
        widget.preloadWeekViewAmount,
        startWeekDay: widget.startWeekDay,
      );

      if (_weekPageController!.hasClients) {
        _weekPageController!.jumpToPage(widget.preloadWeekViewAmount ~/ 2);
      }
      widget.onSelect?.call(_controller.value);
    });

    if (widget.startWeekDay != null && widget.startWeekDay! < 7) {
      final time = _controller.value.subtract(
        Duration(days: _controller.value.weekday - widget.startWeekDay!),
      );
      final list = List<DateTime>.generate(
        8,
        (index) => time.add(Duration(days: index * 1)),
      ).toList();
      _weekNames = List<String>.generate(7, (index) {
        return DateFormat("EEEE").format(list[index]).split('').first;
      });
    }
    widget.parentScrollController.addListener(_onParentScrolled);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle.merge(
        style: theme.textTheme.bodyMedium,
        child: GestureDetector(
          // onVerticalDragStart: (details) {
          //   _captureOffset = details.globalPosition;
          // },
          // onVerticalDragUpdate: (details) {
          //   final moveOffset = details.globalPosition;
          //   final diffY = moveOffset.dy - _captureOffset!.dy;
          //
          //   _animationController.value =
          //       _animationValue + diffY / (widget.weekLineHeight * 5);
          // },
          // onVerticalDragEnd: (details) => _handleFinishDrag(),
          // onVerticalDragCancel: _handleFinishDrag,
          child: Container(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: _monthViewCurrentPage,
                  builder: (_, value, __) {
                    return Header(
                      onLeftTap: _handleLeftTap,
                      onRightTap: _handleRightTap,
                      monthDate: _monthRangeList[_monthViewCurrentPage.value].firstDay,
                      onPressed: _handleTodayPressed,
                      dateStyle: widget.headerStyle,
                      todayStyle: widget.todayStyle,
                      locale: widget.locale,
                    );
                  },
                ),
                WeekDays(
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.hintColor,
                  ),
                  keepLineSize: widget.keepLineSize,
                  weekNames: _weekNames != null ? _weekNames! : const <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'],
                ),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (_, __) {
                    final height = Tween<double>(
                      begin: widget.weekLineHeight * widget.weeksInMonthViewAmount,
                      end: widget.weekLineHeight,
                    ).transform(_animationController.value);
                    return SizedBox(
                      height: height,
                      child: ValueListenableBuilder<DateTime>(
                        valueListenable: _controller,
                        builder: (_, selectedDate, __) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              IgnorePointer(
                                ignoring: _animationController.value > 0.9,
                                child: Opacity(
                                  opacity: Tween<double>(
                                    begin: 1.0,
                                    end: 0.0,
                                  ).evaluate(_animationController),
                                  child: PageView.builder(
                                    onPageChanged: (pageIndex) {
                                      if (widget.onHorizontalDrag != null) {
                                        widget.onHorizontalDrag!(
                                          _monthRangeList[pageIndex].firstDay,
                                        );
                                      }
                                      _monthViewCurrentPage.value = pageIndex;
                                      _alsoChangeWeekPage(pageIndex);
                                    },
                                    controller: _monthPageController,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: _monthRangeList.length,
                                    itemBuilder: (_, pageIndex) {
                                      return MonthView(
                                        dotColor: widget.dotColor,
                                        innerDot: widget.innerDot,
                                        monthView: _monthRangeList[pageIndex],
                                        todayDate: _todayDate,
                                        selectedDate: selectedDate,
                                        weekLineHeight: widget.weekLineHeight,
                                        weeksAmount: widget.weeksInMonthViewAmount,
                                        onChanged: _handleDateChanged,
                                        events: widget.events,
                                        keepLineSize: widget.keepLineSize,
                                        textStyle: widget.calendarTextStyle,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // WEEK VIEW
                              ValueListenableBuilder<int>(
                                valueListenable: _monthViewCurrentPage,
                                builder: (_, pageIndex, __) {
                                  final index = selectedDate.findWeekIndex(
                                    _monthRangeList[_monthViewCurrentPage.value].dates,
                                  );

                                  final offset = index / (widget.weeksInMonthViewAmount - 1) * 2 - 1.0;
                                  return Align(
                                    alignment: Alignment(0.0, offset),
                                    child: IgnorePointer(
                                      ignoring: _animationController.value <= 0.9,
                                      child: Opacity(
                                        opacity: Tween<double>(
                                          begin: 0.0,
                                          end: 1.0,
                                        ).evaluate(_animationController),
                                        child: SizedBox(
                                          height: widget.weekLineHeight,
                                          child: PageView.builder(
                                            onPageChanged: (indexPage) {
                                              final pageIndex = _monthRangeList.indexWhere((index) =>
                                                  index.firstDay.month == _weekRangeList[indexPage].first.month &&
                                                  index.firstDay.year == _weekRangeList[indexPage].first.year);

                                              if (widget.onHorizontalDrag != null) {
                                                widget.onHorizontalDrag!(
                                                  _monthRangeList[pageIndex].firstDay,
                                                );
                                              }

                                              _monthViewCurrentPage.value = pageIndex;
                                              _monthPageController!.jumpToPage(
                                                _monthViewCurrentPage.value,
                                              );
                                            },
                                            controller: _weekPageController,
                                            itemCount: _weekRangeList.length,
                                            physics: _closeMonthScroll(),
                                            itemBuilder: (context, index) {
                                              return WeekView(
                                                dotColor: widget.dotColor,
                                                innerDot: widget.innerDot,
                                                dates: _weekRangeList[index],
                                                selectedDate: selectedDate,
                                                lineHeight: widget.weekLineHeight,
                                                onChanged: _handleWeekDateChanged,
                                                events: widget.events,
                                                keepLineSize: widget.keepLineSize,
                                                textStyle: widget.calendarTextStyle,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _monthPageController!.dispose();
    _monthViewCurrentPage.dispose();
    widget.parentScrollController.removeListener(_onParentScrolled);

    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  void _onParentScrolled() {
    final offset = widget.parentScrollController.offset;
    _animationController.value = _animationValue + offset / (widget.weekLineHeight * 5);
  }

  void _handleWeekDateChanged(DateTime date) {
    _handleDateChanged(date);

    _monthViewCurrentPage.value = _monthRangeList.lastIndexWhere((monthRange) => monthRange.dates.contains(date));
    _monthPageController!.jumpToPage(_monthViewCurrentPage.value);
  }

  void _handleDateChanged(DateTime date) {
    _controller.value = date;
  }

  void _alsoChangeWeekPage(int monthPageIndex) {
    _weekPageController!.jumpToPage(
      _weekRangeList.indexWhere(
        (index) =>
            index.first.month == _monthRangeList[monthPageIndex].firstDay.month &&
            index.first.year == _monthRangeList[monthPageIndex].firstDay.year,
      ),
    );
  }

  void _handleFinishDrag() async {
    _captureOffset = null;

    if (_animationController.value > 0.5) {
      await _animationController.forward();
      _animationValue = 1.0;
    } else {
      await _animationController.reverse();
      _animationValue = 0.0;
    }
  }

  void _handleTodayPressed() {
    _controller.value = DateTime.now().toZeroTime();

    _monthPageController!.jumpToPage(widget.preloadMonthViewAmount ~/ 2);
    _weekPageController!.jumpToPage(widget.preloadWeekViewAmount ~/ 2);
  }

  void _handleLeftTap() {
    if (_animationController.value >= 0.9) {
      _weekPageController!.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _monthPageController!.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleRightTap() {
    if (_animationController.value >= 0.9) {
      _weekPageController!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _monthPageController!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  ScrollPhysics _closeMonthScroll() {
    if ((_monthViewCurrentPage.value == (widget.preloadMonthViewAmount ~/ 2) + 3 ||
        _monthViewCurrentPage.value == (widget.preloadMonthViewAmount ~/ 2) - 3)) {
      return const NeverScrollableScrollPhysics();
    } else {
      return const AlwaysScrollableScrollPhysics();
    }
  }
}
