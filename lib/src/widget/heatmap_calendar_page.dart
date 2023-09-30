import 'package:flutter/material.dart';
import './heatmap_calendar_row.dart';
import '../util/date_util.dart';
import '../util/datasets_util.dart';
import '../data/heatmap_color_mode.dart';

class HeatMapCalendarPage extends StatelessWidget {
  /// The DateTime value which contains the current calendar's date value.
  final DateTime baseDate;

  /// Date beyond which entries will be rendered as unavilable.
  /// Dates beyond this date will not have their date displayed in the container.
  /// Set to null by default on which all entries are shown the same way.
  ///
  /// This date is inclusive.
  final DateTime? calendarEndDate;

  /// Date before which entries will be rendered as unavilable.
  /// Dates before this date will not have their date displayed in the container.
  /// Set to null by default on which all entries are shown the same way.
  ///
  /// This date is inclusive.
  final DateTime? calendarBeginDate;

  /// The list value of the map value that contains
  /// separated start and end of every weeks on month.
  ///
  /// Separate [datasets] using [DateUtil.separatedMonth].
  final List<Map<DateTime, DateTime>> separatedDate;

  /// The margin value for every block.
  final EdgeInsets? margin;

  /// Make block size flexible if value is true.
  final bool? flexible;

  /// The double value of every block's width and height.
  final double size;

  /// The double value of every block's fontSize.
  final double? fontSize;

  /// The datasets which fill blocks based on its value.
  final Map<DateTime, int>? datasets;

  /// The default background color value of every blocks
  final Color? defaultColor;

  /// The text color value of every blocks
  final Color? textColor;

  /// Choose text color to be black or white based on the color of the container
  final bool contrastingTextColor;

  /// ColorMode changes the color mode of blocks.
  ///
  /// [ColorMode.opacity] requires just one colorsets value and changes color
  /// dynamically based on hightest value of [datasets].
  /// [ColorMode.color] changes colors based on [colorsets] thresholds key value.
  final ColorMode colorMode;

  /// The colorsets which give the color value for its thresholds key value.
  ///
  /// Be aware that first Color is the maximum value if [ColorMode] is [ColorMode.opacity].
  final Map<int, Color>? colorsets;

  /// The double value of every block's borderRadius
  final double? borderRadius;

  /// The integer value of the maximum value for the [datasets].
  ///
  /// Filtering [datasets] with [baseDate] using [DatasetsUtil.filterMonth].
  /// And get highest key value of filtered datasets using [DatasetsUtil.getMaxValue].
  final int? maxValue;

  /// Function that will be called when a block tap is registered.
  ///
  /// Paratmeter gives clicked [DateTime] value.
  final Function(DateTime, TapDownDetails)? onTapDown;

  /// Function called when tap is released
  ///
  /// Gives the [DateTime] value
  final Function(DateTime, TapUpDetails)? onTapUp;

  /// Function that will be called when a block is clicked.
  ///
  /// Paratmeter gives clicked [DateTime] value.
  final Function(DateTime)? onTap;

  HeatMapCalendarPage({
    Key? key,
    required this.baseDate,
    required this.colorMode,
    required this.size,
    this.flexible,
    this.fontSize,
    this.defaultColor,
    this.contrastingTextColor = false,
    this.textColor,
    this.margin,
    this.datasets,
    this.colorsets,
    this.borderRadius,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.calendarEndDate,
    this.calendarBeginDate,
  })  : separatedDate = DateUtil.separatedMonth(baseDate),
        maxValue = DatasetsUtil.getMaxValue(
            DatasetsUtil.filterMonth(datasets, baseDate)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var date in separatedDate)
          HeatMapCalendarRow(
            calendarEndDate: calendarEndDate,
            calendarBeginDate: calendarBeginDate,
            startDate: date.keys.first,
            endDate: date.values.first,
            colorMode: colorMode,
            size: size,
            fontSize: fontSize,
            defaultColor: defaultColor,
            colorsets: colorsets,
            textColor: textColor,
            contrastingTextColor: contrastingTextColor,
            borderRadius: borderRadius,
            flexible: flexible,
            margin: margin,
            maxValue: maxValue,
            onTapDown: onTapDown,
            onTapUp: onTapUp,
            onTap: onTap,
            datasets: Map.from(datasets ?? {})
              ..removeWhere(
                (key, value) => !(key.isAfter(date.keys.first) &&
                        key.isBefore(date.values.first) ||
                    key == date.keys.first ||
                    key == date.values.first),
              ),
          ),
      ],
    );
  }
}
