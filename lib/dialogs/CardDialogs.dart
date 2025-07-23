import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/GameCard.dart';
import '../utils/MagicCardAPI.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';

void showDeleteDialog(
    BuildContext context, {
      required int index,
      required List<GameCard> allCards,
      required Function applyFilters,
      required Future<void> Function() saveCards,
    }) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.delete, color: Colors.redAccent),
            const SizedBox(width: 8),
            const Text('Delete card', style: TextStyle(color: Colors.amber)),
          ],
        ),
        content: const Text('Do you really want to delete this card?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
            onPressed: () {
              allCards.removeAt(index);
              applyFilters();
              saveCards();
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

void showInsertDialog(
    BuildContext context, {
      required List<GameCard> allCards,
      required Function applyFilters,
      required Future<void> Function() saveCards,
      String? preSelectedColor,
    }) {
  final colors = ["All", "Red", "Blue", "White", "Green", "Black", "Other"];
  final nameController = TextEditingController();
  String colorSelected = preSelectedColor ?? colors[1];

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Card', style: GoogleFonts.bebasNeue(fontSize: 32, color: Colors.amber)),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: colorSelected,
                dropdownColor: Colors.grey[900],
                decoration: InputDecoration(
                  labelText: 'Color',
                  labelStyle: TextStyle(color: Colors.amber[100]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: Colors.amber),
                items: colors.where((c) => c != "All").map((color) {
                  return DropdownMenuItem(
                    value: color,
                    child: Text(color),
                  );
                }).toList(),
                onChanged: (value) {
                  colorSelected = value ?? colors[1];
                },
              ),
              const SizedBox(height: 18),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Card name',
                  labelStyle: TextStyle(color: Colors.amber[100]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[850],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      final cardData = await MagicCardApi.fetchCardData(nameController.text);
                      final newCard = cardData != null
                          ? GameCard(
                        name: cardData['name'],
                        type: cardData['type'],
                        attack: int.tryParse(cardData['attack'] ?? '0') ?? 0,
                        defense: int.tryParse(cardData['defense'] ?? '0') ?? 0,
                        color: colorSelected,
                        imageURL: cardData['imageURL'] ?? "",
                      )
                          : GameCard(
                        name: nameController.text,
                        type: "NOT FOUND",
                        attack: 0,
                        defense: 0,
                        color: colorSelected,
                        imageURL: "",
                      );
                      allCards.add(newCard);
                      applyFilters();
                      saveCards();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showEditDialog(
    BuildContext context, {
      required GameCard card,
      required int index,
      required List<GameCard> allCards,
      required Function applyFilters,
      required Future<void> Function() saveCards,
    }) {
  final colors = ["Red", "Blue", "White", "Green", "Black", "Other"];
  final nameController = TextEditingController(text: card.name);
  final typeController = TextEditingController(text: card.type);
  final atkController = TextEditingController(text: card.attack.toString());
  final defController = TextEditingController(text: card.defense.toString());
  String colorSelected = colors.contains(card.color)
      ? card.color
      : colors.first;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Card', style: GoogleFonts.bebasNeue(fontSize: 32, color: Colors.amber)),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: colorSelected,
                dropdownColor: Colors.grey[900],
                decoration: InputDecoration(
                  labelText: 'Color',
                  labelStyle: TextStyle(color: Colors.amber[100]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: Colors.amber),
                items: colors.where((c) => c != "All").map((color) {
                  return DropdownMenuItem(value: color, child: Text(color));
                }).toList(),
                onChanged: (value) {
                  colorSelected = value ?? card.color;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.amber[100]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[850],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: typeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: TextStyle(color: Colors.amber[100]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[850],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: atkController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Attack',
                  labelStyle: TextStyle(color: Colors.amber[100]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[850],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: defController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Defense',
                  labelStyle: TextStyle(color: Colors.amber[100]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[850],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    child: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      allCards[index] = GameCard(
                        name: nameController.text,
                        type: typeController.text,
                        attack: int.tryParse(atkController.text) ?? card.attack,
                        defense: int.tryParse(defController.text) ?? card.defense,
                        color: colorSelected,
                        imageURL: card.imageURL,
                      );
                      applyFilters();
                      saveCards();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showBluetoothPendingCardDialog(
    BuildContext context, {
      required String color,
      required List<GameCard> allCards,
      required Function applyFilters,
      required Future<void> Function() saveCards,
      required void Function(String?) setPendingBluetoothColor,
      required FlutterBluetoothClassic bluetooth,
    }) {
  final TextEditingController nameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.bluetooth, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Card from Bluetooth', style: TextStyle(color: Colors.amber)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Received color: $color', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Card name',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.amber),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            onPressed: () {
              setPendingBluetoothColor(null);
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Add Card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
            ),
            onPressed: () async {
              final cardName = nameController.text;
              if (cardName.isNotEmpty) {
                final cardData = await MagicCardApi.fetchCardData(cardName);
                final newCard = cardData != null
                    ? GameCard(
                  name: cardData['name'],
                  type: cardData['type'],
                  attack: int.tryParse(cardData['attack'] ?? '0') ?? 0,
                  defense: int.tryParse(cardData['defense'] ?? '0') ?? 0,
                  color: color,
                  imageURL: cardData['imageURL'] ?? "",
                )
                    : GameCard(
                  name: cardName,
                  type: "Added via Bluetooth",
                  attack: 0,
                  defense: 0,
                  color: color,
                  imageURL: "",
                );
                allCards.add(newCard);
                setPendingBluetoothColor(null);
                saveCards();
                applyFilters();

                final List<int> response = [0x59];
                try {
                  await bluetooth.sendData(response);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

Widget buildPendingBluetoothAlertWidget({
  required BuildContext context,
  required String pendingBluetoothColor,
  required VoidCallback onInsert,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
    decoration: BoxDecoration(
      color: Colors.amber[100],
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "There's a card pending in the system with color: $pendingBluetoothColor",
            style: GoogleFonts.robotoMono(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 16),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Insert"),
          onPressed: onInsert,
        ),
      ],
    ),
  );
}

Widget buildBluetoothConnectionButtonWidget({
  required BuildContext context,
  required VoidCallback onConnect,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
    decoration: BoxDecoration(
      color: Colors.amber[100],
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        const Icon(Icons.bluetooth, color: Colors.amber, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "Try to connect to Bluetooth",
            style: GoogleFonts.robotoMono(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Connect"),
          onPressed: onConnect,
        ),
      ],
    ),
  );
}