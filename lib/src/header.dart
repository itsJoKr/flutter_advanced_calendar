part of 'widget.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
    required this.monthDate,
    this.margin = const EdgeInsets.only(
      left: 16.0,
      right: 8.0,
      top: 4.0,
      bottom: 4.0,
    ),
    required this.onLeftTap,
    required this.onRightTap,
    this.onPressed,
    this.dateStyle,
    this.todayStyle,
  }) : super(key: key);

  static final _dateFormatter = DateFormat().add_yMMMM();
  final DateTime monthDate;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onPressed;
  final TextStyle? dateStyle;
  final TextStyle? todayStyle;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: onLeftTap, icon: const Icon(Icons.chevron_left)),
          Text(
            _dateFormatter.format(monthDate),
            style: dateStyle ?? theme.textTheme.titleMedium,
          ),
          // InkWell(
          //   onTap: onPressed,
          //   borderRadius: const BorderRadius.all(
          //     Radius.circular(4.0),
          //   ),
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(
          //       horizontal: 8.0,
          //       vertical: 4.0,
          //     ),
          //     child: Text(
          //       'Today',
          //       style: todayStyle ?? theme.textTheme.titleMedium,
          //     ),
          //   ),
          // ),
          IconButton(onPressed: onRightTap, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}
