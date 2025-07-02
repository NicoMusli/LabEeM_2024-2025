import 'package:flutter/material.dart';

import 'GameCard.dart';

class CardWidget extends StatelessWidget {
  final GameCard card;
  final VoidCallback onEdit;

  const CardWidget({
    required this.card,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        title: Text(card.name),
        subtitle: Text("${card.type} • ATK ${card.attack} / DEF ${card.defense}"),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: onEdit,
        ),
      ),
    );
  }
}