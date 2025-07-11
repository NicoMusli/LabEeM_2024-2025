import 'package:flutter/material.dart';
import 'GameCard.dart';

class CardWidget extends StatelessWidget {
  final GameCard card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CardWidget({
    required this.card,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = card.imageURL != "";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 0.7,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    card.type,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8A93A2),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildStatChip("ATK", card.attack, const Color(0xFF60A5FA)),
                      const SizedBox(width: 6),
                      _buildStatChip("COS", card.defense, const Color(0xFFAB47BC)),
                    ],
                  ),
                  const SizedBox(height: 7),
                  if (card.color != "")
                    Chip(
                      label: Text(
                        card.color,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: _getColorBackground(card.color),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded),
                        color: const Color(0xFF60A5FA),
                        tooltip: 'Edit',
                        splashRadius: 20,
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: Colors.red[400],
                        tooltip: 'Delete',
                        splashRadius: 20,
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (hasImage)
              Container(
                margin: const EdgeInsets.only(left: 15),
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    card.imageURL,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.blueGrey[50],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatChip(String label, int value, Color color) {
    return Chip(
      label: Text(
        "$label $value",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  static Color _getColorBackground(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'white':
        return Colors.white70;
      case 'black':
        return Colors.black87;
      case 'all':
        return Colors.grey;
      default:
        return const Color(0xFFF9B940); // fallback color
    }
  }
}