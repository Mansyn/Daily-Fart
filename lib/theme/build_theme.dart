import 'package:daily_fart/theme/colors.dart';
import 'package:flutter/material.dart';

class FartThemeBuilder {
  static ThemeData build() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      accentColor: kFartGray900,
      primaryColor: kFartGreen100,
      scaffoldBackgroundColor: kFartBackgroundWhite,
      cardColor: kFartBackgroundWhite,
      textSelectionColor: kFartGreen100,
      errorColor: kFartErrorRed,
      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: kFartGreen100,
        textTheme: ButtonTextTheme.normal,
      ),
      primaryIconTheme: base.iconTheme.copyWith(color: kFartGray900),
      textTheme: _buildShrineTextTheme(base.textTheme),
      primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildShrineTextTheme(base.accentTextTheme),
      iconTheme: _customIconTheme(base.iconTheme),
    );
  }

  static IconThemeData _customIconTheme(IconThemeData original) {
    return original.copyWith(color: kFartGray900);
  }

  static TextTheme _buildShrineTextTheme(TextTheme base) {
    return base
        .copyWith(
          headline: base.headline.copyWith(
            fontWeight: FontWeight.w500,
          ),
          title: base.title.copyWith(fontSize: 22.0),
          caption: base.caption.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
          ),
          body2: base.body2.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
          ),
        )
        .apply(
          fontFamily: 'ZCOOL',
          displayColor: kFartGray900,
          bodyColor: kFartGray900,
        );
  }
}
