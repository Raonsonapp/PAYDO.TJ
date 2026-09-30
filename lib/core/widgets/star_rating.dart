import 'package:flutter/material.dart';

class StarRatingInput extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  final double size;

  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        return IconButton(
          tooltip: '$value',
          onPressed: () => onChanged(value),
          iconSize: size,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          icon: Icon(
            value <= rating ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber,
          ),
        );
      }),
    );
  }
}
