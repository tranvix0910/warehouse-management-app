import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedProductImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedProductImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildDefaultWidget();
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 32,
      ),
    );
  }

  Widget _buildDefaultWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: Colors.grey,
        size: 32,
      ),
    );
  }
}

class CachedAvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackInitials;
  final Color backgroundColor;

  const CachedAvatarImage({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.fallbackInitials,
    this.backgroundColor = const Color(0xFF3B82F6),
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallbackAvatar();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor.withOpacity(0.3),
        child: SizedBox(
          width: radius,
          height: radius,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => _buildFallbackAvatar(),
    );
  }

  Widget _buildFallbackAvatar() {
    if (fallbackInitials != null && fallbackInitials!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Text(
          fallbackInitials!.substring(0, fallbackInitials!.length > 2 ? 2 : fallbackInitials!.length).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.7,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: radius,
      ),
    );
  }
}

class CachedThumbnailGrid extends StatelessWidget {
  final List<String> imageUrls;
  final int maxDisplay;
  final double size;
  final double spacing;
  final VoidCallback? onMoreTap;

  const CachedThumbnailGrid({
    super.key,
    required this.imageUrls,
    this.maxDisplay = 4,
    this.size = 60,
    this.spacing = 8,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = imageUrls.length > maxDisplay ? maxDisplay : imageUrls.length;
    final hasMore = imageUrls.length > maxDisplay;
    final remainingCount = imageUrls.length - maxDisplay;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (int i = 0; i < displayCount; i++)
          if (i == displayCount - 1 && hasMore)
            GestureDetector(
              onTap: onMoreTap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedProductImage(
                      imageUrl: imageUrls[i],
                      width: size,
                      height: size,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '+$remainingCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            CachedProductImage(
              imageUrl: imageUrls[i],
              width: size,
              height: size,
              borderRadius: BorderRadius.circular(8),
            ),
      ],
    );
  }
}
