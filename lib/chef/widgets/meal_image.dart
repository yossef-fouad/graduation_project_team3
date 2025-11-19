import 'package:flutter/material.dart';

class MealImage extends StatelessWidget {
  final String? url;
  const MealImage({super.key, this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(Icons.dinner_dining, color: Theme.of(context).colorScheme.primary),
      );
    }
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.transparent,
      backgroundImage: NetworkImage(url!),
      onBackgroundImageError: (exception, stackTrace) {
        print('Error loading image: $exception');
      },
      child: ClipOval(
        child: Image.network(
          url!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image, color: Colors.grey);
          },
        ),
      ),
    );
  }
}
