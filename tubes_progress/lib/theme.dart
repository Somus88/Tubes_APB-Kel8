import 'package:flutter/material.dart';

const backgroundColorGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xffff), Color(0xFF3565F5)],
);

/// Base styles (tanpa fontFamily karena sudah di-set di ThemeData)
TextStyle textReguler = TextStyle(fontWeight: FontWeight.w400);
TextStyle textSemiBold = TextStyle(fontWeight: FontWeight.w600);
TextStyle textBold = TextStyle(fontWeight: FontWeight.w700);

/// Font sizes
const double fontSizeSm = 12;
const double fontSizeMd = 14;
const double fontSizeLg = 18;
const double fontSizeXl = 24;

/// Reguler
TextStyle textRegulerSm = textReguler.copyWith(fontSize: fontSizeSm);
TextStyle textRegulerMd = textReguler.copyWith(fontSize: fontSizeMd);
TextStyle textRegulerLg = textReguler.copyWith(fontSize: fontSizeLg);
TextStyle textRegulerXl = textReguler.copyWith(fontSize: fontSizeXl);

/// SemiBold
TextStyle textSemiBoldSm = textSemiBold.copyWith(fontSize: fontSizeSm);
TextStyle textSemiBoldMd = textSemiBold.copyWith(fontSize: fontSizeMd);
TextStyle textSemiBoldLg = textSemiBold.copyWith(fontSize: fontSizeLg);
TextStyle textSemiBoldXl = textSemiBold.copyWith(fontSize: fontSizeXl);

/// Bold
TextStyle textBoldSm = textBold.copyWith(fontSize: fontSizeSm);
TextStyle textBoldMd = textBold.copyWith(fontSize: fontSizeMd);
TextStyle textBoldLg = textBold.copyWith(fontSize: fontSizeLg);
TextStyle textBoldXl = textBold.copyWith(fontSize: fontSizeXl);
