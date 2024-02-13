
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

Widget networkImage(String link,
    {double? height, double? width, Widget? noneWidget}) =>
    Container(
      width: width ?? 80,
      height: height ?? 80,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appWhiteColor,
          boxShadow: [BoxShadow(color: appBlackColor.withOpacity(0.4),offset: const Offset(5, 10))]
      ),
      child: ClipOval(
        child: Image.network(
          link.isEmptyOrNull ? AppAssets.defaulImg : link,
          fit: BoxFit.cover,
          width: width ?? 80,
          height: height ?? 80,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            }
          },
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Center(
              child: noneWidget ??
                  Image.asset(
                    AppAssets.USER_ICON,
                    width: width ?? 80,
                    height: height ?? 80,
                    fit: BoxFit.cover,
                  ),
            );
          },
          frameBuilder: (BuildContext context, Widget child, int? frame,
              bool wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              return child;
            }
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(seconds: 2),
              curve: Curves.easeOut,
              child: child,
            );
          },
        ),
      ),
    );