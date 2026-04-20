import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget boxContainer({
  required String text,
  required String svgAsset,
  VoidCallback? onTap, // 👈 New parameter
  Color bgColor = const Color.fromARGB(255, 255, 255, 255),
  Color? iconColor,
  double iconWidth = 38,
  double iconHeight = 55,
  double fontSize = 13,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap, // 👈 Triggered when tapped
    child: Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgAsset,
              width: iconWidth,
              height: iconHeight,
              colorFilter: iconColor != null
                  ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
