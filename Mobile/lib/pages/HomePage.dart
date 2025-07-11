import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:polibaproject/utils/CardWidget.dart';
import '../utils/GameCard.dart';
import '../utils/MagicCardAPI.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final List<String> colors = ["All", "Red", "Blue", "White", "Green", "Black"];
  String selectedColor = "All";
  List<GameCard> allCards = [];
  List<GameCard> filteredCards = [];
  String searchBarText = "";
  String? pendingBluetoothColor;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    loadCards();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  Future<void> loadCards() async {
    final file = await _getLocalFile();
    if (!(await file.exists())) {
      final assetData = await rootBundle.loadString('lib/assets/storage.json');
      await file.writeAsString(assetData);
    }
    final jsonString = await file.readAsString();
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        allCards = jsonList.map((e) => GameCard.fromJson(e)).toList();
        applyFilters();
      });
    } catch (e) {
      print("Error parsing cards: $e");
    }
  }

  Future<void> saveCards() async {
    final file = await _getLocalFile();
    final jsonString = jsonEncode(allCards.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/assets.json');
  }

  void applyFilters() {
    setState(() {
      filteredCards = allCards.where((card) {
        final colorOk = (selectedColor == "All") || (card.color.toLowerCase() == selectedColor.toLowerCase());
        final nameOk = searchBarText.isEmpty || card.name.toLowerCase().contains(searchBarText.toLowerCase());
        return colorOk && nameOk;
      }).toList();
    });
  }

  void showDeleteDialog(BuildContext context, int index) {
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
                setState(() {
                  allCards.removeAt(index);
                  applyFilters();
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

  void showInsertDialog(BuildContext context, {String? preSelectedColor}) {
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
                        setState(() {
                          allCards.add(newCard);
                          applyFilters();
                        });
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

  void showEditDialog(BuildContext context, GameCard card, int index) {
    final nameController = TextEditingController(text: card.name);
    final typeController = TextEditingController(text: card.type);
    final atkController = TextEditingController(text: card.attack.toString());
    final defController = TextEditingController(text: card.defense.toString());
    String colorSelected = card.color;

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
                        setState(() {
                          allCards[index] = GameCard(
                            name: nameController.text,
                            type: typeController.text,
                            attack: int.tryParse(atkController.text) ?? card.attack,
                            defense: int.tryParse(defController.text) ?? card.defense,
                            color: colorSelected,
                            imageURL: card.imageURL,
                          );
                          applyFilters();
                        });
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

  void showBluetoothPendingCardDialog(String color) {
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
                setState(() {
                  pendingBluetoothColor = null;
                });
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
                  setState(() {
                    allCards.add(newCard);
                    pendingBluetoothColor = null;
                  });
                  saveCards();
                  applyFilters();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void onBluetoothColorReceived(String colorReceived) {
    setState(() {
      pendingBluetoothColor = colorReceived;
    });
  }

  Widget buildColorFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: colors.map((color) {
          final isSelected = color == selectedColor;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(
                color,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.amber,
              backgroundColor: Colors.grey[300],
              onSelected: (_) {
                setState(() {
                  selectedColor = color;
                  applyFilters();
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by name...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: const Icon(Icons.search, color: Colors.amber),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
        onChanged: (value) {
          searchBarText = value;
          applyFilters();
        },
      ),
    );
  }

  Widget buildPendingBluetoothAlert() {
    if (pendingBluetoothColor == null) return const SizedBox.shrink();
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
            onPressed: () {
              showBluetoothPendingCardDialog(pendingBluetoothColor!);
            },
          ),
        ],
      ),
    );
  }

  Widget buildCardList() {
    if (filteredCards.isEmpty) {
      return Center(
        child: Text(
          "No cards found.",
          style: GoogleFonts.robotoMono(fontSize: 20, color: Colors.grey[600]),
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
          animation: _controller,
          builder: (_, child) => FadeTransition(
            opacity: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
            child: child,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7.0),
            child: CardWidget(
              card: card,
              onEdit: () => showEditDialog(context, card, idxInAll),
              onDelete: () => showDeleteDialog(context, idxInAll),
            ),
          ),
        );
      },
    );
  }

  Widget buildBluetoothTestButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.bluetooth),
        label: const Text('Simulate Bluetooth Color'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () {
          onBluetoothColorReceived("Red"); // Replace with your Bluetooth color event
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        toolbarHeight: 85,
        elevation: 8,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, color: Colors.amber, size: 38),
            const SizedBox(width: 10),
            Text(
              "Magic Inventory",
              style: GoogleFonts.bebasNeue(fontSize: 32, letterSpacing: 1, color: Colors.amber[200]),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            buildColorFilters(),
            buildSearchBar(),
            buildPendingBluetoothAlert(),
            buildBluetoothTestButton(),
            Expanded(
              child: buildCardList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber[700],
        icon: const Icon(Icons.add),
        label: const Text("Add card"),
        onPressed: () {
          showInsertDialog(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}