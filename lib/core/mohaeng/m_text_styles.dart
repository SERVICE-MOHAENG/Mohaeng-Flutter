import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MTextStyles {
  MTextStyles._();

  // font families
  static const String _boldFont = 'GmarketSansBold';
  static const String _mediumFont = 'GmarketSansMedium';

  // weights
  static const FontWeight _bold = FontWeight.w700;   // B
  static const FontWeight _medium = FontWeight.w500; // M

  // 베이스 스타일 설정
  static TextStyle _base(
      double size,
      FontWeight weight,
      String fontFamily,
      ) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size.sp,
        fontWeight: weight,
      );

  // L Headline
  static final TextStyle lHeadlineB = _base(36, _bold, _boldFont);
  static final TextStyle lHeadlineM = _base(36, _medium, _mediumFont);

  // Headline
  static final TextStyle headlineB = _base(32, _bold, _boldFont);
  static final TextStyle headlineM = _base(32, _medium, _mediumFont);

  // Title
  static final TextStyle titleB = _base(28, _bold, _boldFont);
  static final TextStyle titleM = _base(28, _medium, _mediumFont);

  // sTitle
  static final TextStyle sTitleB = _base(24, _bold, _boldFont);
  static final TextStyle sTitleM = _base(24, _medium, _mediumFont);

  // L Body
  static final TextStyle lBodyB = _base(20, _bold, _boldFont);
  static final TextStyle lBodyM = _base(20, _medium, _mediumFont);

  // Body
  static final TextStyle bodyB = _base(16, _bold, _boldFont);
  static final TextStyle bodyM = _base(16, _medium, _mediumFont);

  // Label
  static final TextStyle labelB = _base(12, _bold, _boldFont);
  static final TextStyle labelM = _base(12, _medium, _mediumFont);

  // sLabel
  static final TextStyle sLabelB = _base(10, _bold, _boldFont);
  static final TextStyle sLabelM = _base(10, _medium, _mediumFont);
}