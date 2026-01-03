import 'dart:ui';

class MTextStyles {
  MTextStyles._();

  static const String _font = 'Pretendard';

  // weights
  static const FontWeight _bold = FontWeight.w700;   // B
  static const FontWeight _medium = FontWeight.w500; // M

  //베이스 스타일 설정
  static TextStyle _base(double size, FontWeight weight) => TextStyle(
    fontFamily: _font,
    fontSize: size,
    fontWeight: weight,
  );

  // L Headline
  static final TextStyle lHeadlineB = _base(36, _bold);
  static final TextStyle lHeadlineM = _base(36, _medium);

  // Headline
  static final TextStyle headlineB = _base(32, _bold);
  static final TextStyle headlineM = _base(32, _medium);

  // Title
  static final TextStyle titleB = _base(28, _bold);
  static final TextStyle titleM = _base(28, _medium);

  // sTitle
  static final TextStyle sTitleB = _base(24, _bold);
  static final TextStyle sTitleM = _base(24, _medium);

  // L Body
  static final TextStyle lBodyB = _base(20, _bold);
  static final TextStyle lBodyM = _base(20, _medium);

  // Body
  static final TextStyle bodyB = _base(16, _bold);
  static final TextStyle bodyM = _base(16, _medium);

  // label
  static final TextStyle labelB = _base(12, _bold);
  static final TextStyle labelM = _base(12, _medium);

  // sLabel
  static final TextStyle sLabelB = _base(10, _bold);
  static final TextStyle sLabelM = _base(10, _medium);
}