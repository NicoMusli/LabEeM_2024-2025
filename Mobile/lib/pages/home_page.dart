import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
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

  List<GameCard> cards = [];

  @override
  void initState() {
    super.initState();
    loadCards();
  }

  Future<void> loadCards() async {
    final file = await _getLocalFile();
    if (!(await file.exists())) {
      final assetData = await rootBundle.loadString('lib/assets/storage.json');
      await file.writeAsString(assetData);
    }

    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = json.decode(jsonString);
    setState(() {
      cards = jsonList.map((e) => GameCard.fromJson(e)).toList();
    });
  }

  Future<void> saveCards() async {
    final file = await _getLocalFile();
    final jsonString = jsonEncode(cards.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/assets.json');
  }

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
                saveCards();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
              child: Row(
                children: [
                  Image.asset('lib/icons/points.png', height: 30, color: Colors.grey[800]),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("This is", style: TextStyle(fontSize: 20, color: Colors.grey[700])),
                  Text("MAGIC STORE", style: GoogleFonts.bebasNeue(fontSize: 72)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Divider(color: Colors.grey[400], thickness: 1),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text("Your cards:", style: TextStyle(fontSize: 20, color: Colors.grey[700])),
            ),
            Expanded(
              child: cards.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return CardWidget(
                    card: card,
                    onEdit: () => _showEditDialog(context, card, index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
