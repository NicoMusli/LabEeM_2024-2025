import 'package:flutter/material.dart';
import 'CardWidget.dart';
import '../utils/GameCard.dart';

class CardListWidget extends StatelessWidget {
  final List<GameCard> filteredCards;
  final List<GameCard> allCards;
  final AnimationController controller;
  final void Function(GameCard card, int index) onEdit;
  final void Function(int index) onDelete;

  const CardListWidget({
    super.key,
    required this.filteredCards,
    required this.allCards,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredCards.isEmpty) {
      return Center(
        child: Text(
          "No cards found.",
          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: filteredCards.length,
      itemBuilder: (context, index) {
        final card = filteredCards[index];
        final idxInAll = allCards.indexOf(card);
        return AnimatedBuilder(
          animation: controller,
          builder: (_, child) => FadeTransition(
            opacity: CurvedAnimation(parent: controller, curve: Curves.easeIn),
            child: child,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7.0),
            child: CardWidget(
              card: card,
              onEdit: () => onEdit(card, idxInAll),
              onDelete: () => onDelete(idxInAll),
            ),
          ),
        );
      },
    );
  }
}