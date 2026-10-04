import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CurvedHeader extends StatelessWidget {
  final double height;

  const CurvedHeader({Key? key, this.height = 250}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.fill, // fills the container without losing the curve
        alignment: Alignment.center,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(1.05, 1.0), // widen slightly
          child: SvgPicture.asset(
            'lib/core/widgets/Rectangle 64.svg',
            // Remove hardcoded width/height; let FittedBox handle it
          ),
        ),
      ),
    );
  }
}