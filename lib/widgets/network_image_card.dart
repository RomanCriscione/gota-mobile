import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'loading_skeleton.dart';

class NetworkImageCard extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  final double? width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const NetworkImageCard({
    super.key,
    required this.imageUrl,
    required this.height,
    this.width,
    this.heroTag,
    this.borderRadius = 22,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(
            milliseconds: 250,
        ),
        fadeOutDuration: const Duration(
            milliseconds: 120,
        ),
        placeholder: (
            context,
            url,
        ) {
            return LoadingSkeleton(
            width: width,
            height: height,
            borderRadius: BorderRadius.circular(
                borderRadius,
            ),
            );
        },
        errorWidget: (
            context,
            url,
            error,
        ) {
            return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(
                borderRadius,
                ),
            ),
            child: Center(
                child: Opacity(
                opacity: .35,
                child: SvgPicture.asset(
                    'assets/icons/rating_cup.svg',
                    width: 70,
                    height: 70,
                ),
                ),
            ),
            );
        },
        ),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: image,
      );
    }

    return image;
  }
}