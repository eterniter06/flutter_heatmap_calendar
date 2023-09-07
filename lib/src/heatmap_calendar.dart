import 'package:flutter/material.dart';
import './data/heatmap_color_mode.dart';
import './widget/heatmap_calendar_page.dart';
import './widget/heatmap_color_tip.dart';
import './util/date_util.dart';
import './util/widget_util.dart';

class HeatMapCalendar extends StatefulWidget {
  /// The datasets which fill blocks based on its value.
  final Map<DateTime, int>? datasets;

  /// The color value of every block's default color.
  final Color? defaultColor;

  /// The colorsets which give the color value for its thresholds key value.
  ///
  /// Be aware that first Color is the maximum value if [ColorMode] is [ColorMode.opacity].
  /// Also colorsets must have at least one color.
  final Map<int, Color> colorsets;

  /// The double value of every block's borderRadius.
  final double? borderRadius;

  /// The date values of initial year and month.
  final DateTime? initDate;

  /// Limit how far behind the calendar can be viewed.
  /// Set to null by default which does not set any bound.
  ///
  /// This date is inclusive.
  final DateTime? calendarBeginDate;

  /// Limit how far ahead the calendar can be viewed.
  /// Set to null by default which does tno set any bound.
  ///
  /// This date is inclusive.
  final DateTime? calendarEndDate;

  /// The double value of every block's size.
  final double size;

  /// The text color value of every blocks.
  final Color? textColor;

  /// The double value of every block's fontSize.
  final double? fontSize;

  /// The double value of month label's fontSize.
  final double? monthFontSize;

  /// The double value of week label's fontSize.
  final double? weekFontSize;

  /// The text color value of week labels.
  final Color? weekTextColor;

  /// Make block size flexible if value is true.
  ///
  /// Default value is false.
  final bool? flexible;

  /// The margin value for every block.
  final EdgeInsets? margin;

  /// ColorMode changes the color mode of blocks.
  ///
  /// [ColorMode.opacity] requires just one colorsets value and changes color
  /// dynamically based on hightest value of [datasets].
  /// [ColorMode.color] changes colors based on [colorsets] thresholds key value.
  ///
  /// Default value is [ColorMode.opacity].
  final ColorMode colorMode;

  /// Function that will be called when a block is clicked.
  ///
  /// Paratmeter gives clicked [DateTime] value.
  final Function(DateTime)? onClick;

  /// Function that will be called when month is changed.
  ///
  /// Paratmeter gives [DateTime] value of current month.
  final Function(DateTime)? onMonthChange;

  /// Show color tip which represents the color range at the below.
  ///
  /// Default value is true.
  final bool? showColorTip;

  /// Widgets which shown at left and right side of colorTip.
  ///
  /// First value is the left side widget and second value is the right side widget.
  /// Be aware that [colorTipHelper.length] have to greater or equal to 2.
  /// Give null value makes default 'Less' and 'More' [Text].
  final List<Widget?>? colorTipHelper;

  /// Widget that appears to the left of the colorTipWidget
  /// Setting this to null builds a [Text] widget "Less" with [TextStyle.bold] and fontSize as colorTipSize
  final Widget? leadingColorTipHelper;

  /// Widget that appears on the right of colorTipWidget
  /// Setting this to null builds a [Text] widget "More" with [TextStyle.bold] and fontSize as colorTipSize
  final Widget? trailingColorTipHelper;

  /// The integer value which represents the number of [HeatMapColorTip]'s tip container.
  final int? colorTipCount;

  /// The double value of [HeatMapColorTip]'s tip container's size.
  final double colorTipSize;

  const HeatMapCalendar({
    Key? key,
    required this.colorsets,
    this.colorMode = ColorMode.opacity,
    this.showColorTip = true,
    this.flexible = false,
    this.size = 42,
    this.colorTipSize = 10,
    this.defaultColor,
    this.datasets,
    this.initDate,
    this.fontSize,
    this.monthFontSize,
    this.textColor,
    this.weekFontSize,
    this.weekTextColor,
    this.borderRadius,
    this.margin,
    this.onClick,
    this.onMonthChange,
    this.colorTipCount,
    this.calendarBeginDate,
    this.calendarEndDate,
    this.leadingColorTipHelper,
    this.trailingColorTipHelper,
    @Deprecated(
        'Please use leadingColorTipHelper and trailingColorTipHelper instead.')
    this.colorTipHelper,
  })  : assert(
            (trailingColorTipHelper == null && leadingColorTipHelper == null) ||
                colorTipHelper == null,
            'colorTipHelper is deprecated. Please use the trailing and leading counterparts.\ncolorTipHelper cannot be used in conjunction with trailingColorTipHelper or leadingColorTipHelpers'),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _HeatMapCalendar();
}

class _HeatMapCalendar extends State<HeatMapCalendar> {
  // The DateTime value of first day of the current month.
  late DateTime _currentDate;

  late DateTime? calendarEndDate;
  late DateTime? calendarBeginDate;

  stripHourLevelAndBelowDetails(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }

    DateTime strippedDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    return strippedDate;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      // Set _currentDate value to first day of initialized date or
      // today's month if widget.initDate is null.
      _currentDate =
          DateUtil.startDayOfMonth(widget.initDate ?? DateTime.now());
    });

    // Hour, minutes and other low level details do not make any sense
    // as the smallest unit is a day
    calendarEndDate = stripHourLevelAndBelowDetails(widget.calendarEndDate);
    calendarBeginDate = stripHourLevelAndBelowDetails(widget.calendarBeginDate);
  }

  void changeMonth(int direction) {
    setState(() {
      _currentDate = DateUtil.changeMonth(_currentDate, direction);
    });
    if (widget.onMonthChange != null) widget.onMonthChange!(_currentDate);
  }

  /// Header widget which shows left, right buttons and year/month text.
  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Previous month button.
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 14,
          ),
          onPressed:
              isMonthAfterCalendarBeginDate() ? () => changeMonth(-1) : null,
        ),

        // Text which shows the current year and month
        Text(
          DateUtil.monthLabel[_currentDate.month] +
              ' ' +
              (_currentDate.year).toString(),
          style: TextStyle(
            fontSize: widget.monthFontSize ?? 12,
          ),
        ),
        // Next month button.
        IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
          ),
          onPressed:
              isMonthBeforeCalendarEndDate() ? () => changeMonth(1) : null,
        ),
      ],
    );
  }

  bool isMonthBeforeCalendarEndDate() {
    return calendarEndDate == null ||
        _currentDate.year < calendarEndDate!.year ||
        (_currentDate.year == calendarEndDate!.year &&
            _currentDate.month < calendarEndDate!.month);
  }

  bool isMonthAfterCalendarBeginDate() {
    return calendarBeginDate == null ||
        _currentDate.year > calendarBeginDate!.year ||
        (_currentDate.year == calendarBeginDate!.year &&
            _currentDate.month > calendarBeginDate!.month);
  }

  Widget _weekLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (String label in DateUtil.weekLabel.skip(1))
          WidgetUtil.flexibleContainer(
            widget.flexible ?? false,
            false,
            Container(
              margin: EdgeInsets.only(
                  left: widget.margin?.left ?? 2,
                  right: widget.margin?.right ?? 2),
              width: widget.size,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: widget.weekFontSize ?? 12,
                  color: widget.weekTextColor ?? const Color(0xFF758EA1),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Expand width dynamically if [flexible] is true.
  Widget _intrinsicWidth({
    required Widget child,
  }) =>
      (widget.flexible ?? false) ? child : IntrinsicWidth(child: child);

  @override
  Widget build(BuildContext context) {
    return _intrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _header(),
          _weekLabel(),
          HeatMapCalendarPage(
            calendarEndDate: calendarEndDate,
            calendarBeginDate: calendarBeginDate,
            baseDate: _currentDate,
            colorMode: widget.colorMode,
            flexible: widget.flexible,
            size: widget.size,
            fontSize: widget.fontSize,
            defaultColor: widget.defaultColor,
            textColor: widget.textColor,
            margin: widget.margin,
            datasets: widget.datasets,
            colorsets: widget.colorsets,
            borderRadius: widget.borderRadius,
            onClick: widget.onClick,
          ),
          if (widget.showColorTip == true)
            HeatMapColorTip(
              colorMode: widget.colorMode,
              colorsets: widget.colorsets,
              leftWidget:
                  widget.leadingColorTipHelper ?? widget.colorTipHelper?[0],
              rightWidget:
                  widget.trailingColorTipHelper ?? widget.colorTipHelper?[1],
              containerCount: widget.colorTipCount,
              size: widget.colorTipSize,
            ),
        ],
      ),
    );
  }
}
