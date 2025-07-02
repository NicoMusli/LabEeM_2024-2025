import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:polibaproject/utils/CardWidget.dart';

import '../utils/GameCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {

  final double horizontalPadding = 40.0;
  final double verticalPadding = 25.0;

  void _showEditDialog(BuildContext context, GameCard card, int index) {
    final nameController = TextEditingController(text: card.name);
    final typeController = TextEditingController(text: card.type);
    final atkController = TextEditingController(text: card.attack.toString());
    final defController = TextEditingController(text: card.defense.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifica Carta'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nome')),
                TextField(controller: typeController, decoration: InputDecoration(labelText: 'Tipo')),
                TextField(controller: atkController, decoration: InputDecoration(labelText: 'Attacco'), keyboardType: TextInputType.number),
                TextField(controller: defController, decoration: InputDecoration(labelText: 'Difesa'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(child: Text('Annulla'), onPressed: () => Navigator.pop(context)),
            ElevatedButton(
              child: Text('Salva'),
              onPressed: () {
                    setState(() {
                      cards[index] = GameCard(
                        name: nameController.text,
                        type: typeController.text,
                        attack: int.tryParse(atkController.text) ?? card.attack,
                        defense: int.tryParse(defController.text) ?? card.defense,
                    imagePath: card.imagePath,
                  );
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  List<GameCard> cards = [
      GameCard(
      name: 'Dark Magician',
      type: 'Spellcaster',
      attack: 2500,
      defense: 2100,
      imagePath: 'lib/images/dark_magician.png',
    ),
    GameCard(
      name: 'Dark Magician',
      type: 'Spellcaster',
      attack: 2500,
      defense: 2100,
      imagePath: 'lib/images/dark_magician.png',
    ),
    GameCard(
      name: 'Dark Magician',
      type: 'Spellcaster',
      attack: 2500,
      defense: 2100,
      imagePath: 'lib/images/dark_magician.png',
    ),
    GameCard(
      name: 'Dark Magician',
      type: 'Spellcaster',
      attack: 2500,
      defense: 2100,
      imagePath: 'lib/images/dark_magician.png',
    ),
    GameCard(
      name: 'Dark Magician',
      type: 'Spellcaster',
      attack: 2500,
      defense: 2100,
      imagePath: 'lib/images/dark_magician.png',
    ),
    GameCard(
      name: 'Dark Magician',
      type: 'Spellcaster',
      attack: 2500,
      defense: 2100,
      imagePath: 'lib/images/dark_magician.png',
    ),
    GameCard(
      name: 'Dark Magician',
      type: 'Spellcaster',
      attack: 2500,
      defense: 2100,
      imagePath: 'lib/images/dark_magician.png',
    ),
    GameCard(
      name: 'Dark Magician',
      type: 'Spellcaster',
      attack: 2500,
      defense: 2100,
      imagePath: 'lib/images/dark_magician.png',
    ),
    GameCard(
      name: 'Dark Magician',
      type: 'Spellcaster',
      attack: 2500,
      defense: 2100,
      imagePath: 'lib/images/dark_magician.png',
    ),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding,vertical: verticalPadding),
            child: Row(children: [
              Image.asset(
                  'lib/icons/points.png',
                  height: 30,
                  color: Colors.grey[800]),
            ],),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome Home,", style: TextStyle(fontSize: 20, color: Colors.grey[700]),),
                Text("YuGiOh! FAN!", style: GoogleFonts.bebasNeue(fontSize: 72),)
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            child: Divider(color: Colors.grey[400], thickness: 1),
          ),
            Expanded(
              child: ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return CardWidget(
                    card: card,
                    onEdit: () {
                      _showEditDialog(context, card, index);
                    },
                  );
                },
              ),
            ),
        ],
      ),)
    );
  }
}