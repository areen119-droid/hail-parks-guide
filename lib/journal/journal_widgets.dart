import 'package:flutter/material.dart';
import 'package:hail_parks_guide/core/widgets/smart_image.dart';
import 'package:hail_parks_guide/journal/journal_theme.dart';
import 'package:hail_parks_guide/models/place_model.dart';

/// A thin ruled line.
class JRule extends StatelessWidget {
  final double indent;
  final Color color;
  const JRule({super.key, this.indent = 0, this.color = J.rule});

  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        margin: EdgeInsetsDirectional.only(start: indent),
        color: color,
      );
}

/// A section opener: a small ochre number over a Kufi title, then a rule.
class JSection extends StatelessWidget {
  final int number;
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const JSection({
    super.key,
    required this.number,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(J.gutter, 36, J.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(J.index(number), style: J.number),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text(title, style: J.title)),
              if (action != null)
                JLink(label: action!, onTap: onAction),
            ],
          ),
          const SizedBox(height: 10),
          const JRule(color: J.ink),
        ],
      ),
    );
  }
}

/// Underlined text action with an arrow, e.g. "التفاصيل ←".
class JLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const JLink({super.key, required this.label, this.onTap, this.color = J.ink});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: color,
                decoration: TextDecoration.underline,
                decorationColor: color,
              ),
            ),
            const SizedBox(width: 4),
            // Mirrored in right-to-left, so it points left (forward).
            Icon(Icons.arrow_forward, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

/// Text tabs with an ochre bar under the selected one.
class JTabs<T> extends StatelessWidget {
  final List<(T, String)> tabs;
  final T selected;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;

  const JTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: J.gutter),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (final (value, label) in tabs)
            InkWell(
              onTap: () => onSelected(value),
              child: Container(
                padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
                margin: const EdgeInsetsDirectional.only(end: 22),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: value == selected ? J.ochre : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: value == selected ? FontWeight.w700 : FontWeight.w500,
                    color: value == selected ? J.ink : J.inkSoft,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A square ink-outlined icon button (back, close, location...).
class JSquareButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool filled;
  final double size;

  const JSquareButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = false,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled ? J.ink : J.paper,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: J.ink, width: 1.4),
        ),
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.45, color: filled ? J.onInk : J.ink),
          ),
        ),
      ),
    );
  }
}

/// A place's photo with sharp corners, or a block in the place's color with a
/// rock-art ibex when there is no photo.
class JPhoto extends StatelessWidget {
  final PlaceModel place;
  final String? image;
  final double? width;
  final double? height;

  const JPhoto({super.key, required this.place, this.image, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final src = image ?? place.image;
    if (src.isNotEmpty) {
      return SmartImage(
        imageData: src,
        width: width,
        height: height,
        placeholderIcon: place.category.icon,
      );
    }
    return Container(
      width: width,
      height: height,
      color: J.paperDeep,
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, c) {
          final side = (c.maxWidth.isFinite ? c.maxWidth : 120) * 0.42;
          return Ibex(size: side.clamp(18, 90), color: J.category(place.category));
        },
      ),
    );
  }
}

/// A small square in a place's category color.
class JCategoryMark extends StatelessWidget {
  final PlaceCategory category;
  const JCategoryMark(this.category, {super.key});

  @override
  Widget build(BuildContext context) =>
      Container(width: 9, height: 9, color: J.category(category));
}

/// An ibex drawn like the petroglyphs at Jubbah: thick strokes, long horns.
class Ibex extends StatelessWidget {
  final double size;
  final Color color;
  const Ibex({super.key, this.size = 40, this.color = J.ochre});

  @override
  // Align keeps its own size even inside a list, which stretches children.
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: 1,
        heightFactor: 1,
        child: CustomPaint(size: Size(size, size * 0.75), painter: _IbexPainter(color)),
      );
}

class _IbexPainter extends CustomPainter {
  final Color color;
  _IbexPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Drawn on a 40 x 30 grid, facing right; mirrored so it faces the
    // reading direction in Arabic.
    final s = size.width / 40;
    canvas.translate(size.width, 0);
    canvas.scale(-s, s);
    final fill = Paint()..color = color;
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final body = Path()
      ..moveTo(7, 13)
      ..quadraticBezierTo(17, 10.5, 27, 12)
      ..lineTo(27.5, 17)
      ..quadraticBezierTo(17, 18.5, 8, 17.5)
      ..close();
    final rest = Path()
      ..moveTo(26, 13) // neck and muzzle
      ..lineTo(31, 8.5)
      ..lineTo(35, 10)
      ..moveTo(33.5, 10) // beard
      ..lineTo(33, 13)
      ..moveTo(7.5, 13.5) // tail
      ..lineTo(5, 10)
      ..moveTo(9.5, 17.5) // legs
      ..lineTo(8.5, 27.5)
      ..moveTo(13, 18)
      ..lineTo(14, 27.5)
      ..moveTo(23.5, 17.5)
      ..lineTo(22.5, 27.5)
      ..moveTo(26.5, 17)
      ..lineTo(27.5, 27.5);
    // The long horn sweeping back over the body.
    final horn = Path()
      ..moveTo(30.5, 8.5)
      ..cubicTo(31, 2, 24, 0.5, 16.5, 4.5);
    canvas
      ..drawPath(body, fill)
      ..drawPath(rest, line)
      ..drawPath(horn, line..strokeWidth = 2.8);
  }

  @override
  bool shouldRepaint(_IbexPainter old) => old.color != color;
}

/// Underlined search field.
class JSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const JSearchField({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16, color: J.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: J.inkSoft),
        prefixIcon: const Icon(Icons.search, color: J.ink),
        prefixIconConstraints: const BoxConstraints(minWidth: 36),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: J.ink, width: 1.2)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: J.ochre, width: 2)),
      ),
    );
  }
}

/// Today's date in Arabic, e.g. "السبت ٧ نوفمبر".
String journalDate(DateTime d) {
  const days = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو',
      'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  return '${days[d.weekday - 1]} ${J.digits('${d.day}')} ${months[d.month - 1]}';
}
