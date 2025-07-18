import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import '../widgets/CardListWidget.dart';
import '../dialogs/CardDialogs.dart';

import '../utils/GameCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final List<String> colors = ["All", "Red", "Blue", "White", "Green", "Black", "Other"];
  String selectedColor = "All";
  List<GameCard> allCards = [];
  List<GameCard> filteredCards = [];
  String searchBarText = "";
  String? pendingBluetoothColor;
  late AnimationController _controller;

  bool isConnected = false;
  StreamSubscription<BluetoothData>? _subscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  final FlutterBluetoothClassic _bluetooth = FlutterBluetoothClassic();
  final String esp32MacAddress = "48:E7:29:89:3F:32";

  @override
  void initState() {
    super.initState();
    loadCards();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    requestPermissions();
    connection();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
  }

  Future<void> connection() async {
    try {
      if (!await _bluetooth.isBluetoothEnabled()) {
        await _bluetooth.enableBluetooth();
      }
      bool connected = await _bluetooth.connect(esp32MacAddress);
      if (!connected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connessione Bluetooth fallita.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      _subscription?.cancel();
      _subscription = _bluetooth.onDataReceived.listen((BluetoothData data) {
        onBluetoothColorReceived(data.asString());
      });
      _connectionSubscription?.cancel();
      _connectionSubscription = _bluetooth.onConnectionChanged.listen((connection) {
        setState(() {
          isConnected = connection.isConnected;
        });
      });
    } catch (e) {
      print(e);
    }
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
    return buildPendingBluetoothAlertWidget(
      context: context,
      pendingBluetoothColor: pendingBluetoothColor!,
      onInsert: () => showBluetoothPendingCardDialog(
        context,
        color: pendingBluetoothColor!,
        allCards: allCards,
        applyFilters: applyFilters,
        saveCards: saveCards,
        setPendingBluetoothColor: (v) {
          setState(() {
            pendingBluetoothColor = v;
          });
        },
        bluetooth: _bluetooth,
      ),
    );
  }

  Widget buildBluetoothConnectionButton() {
    if (isConnected) return const SizedBox.shrink();
    return buildBluetoothConnectionButtonWidget(
      context: context,
      onConnect: connection,
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
            buildBluetoothConnectionButton(),
            Expanded(
              child: CardListWidget(
                filteredCards: filteredCards,
                allCards: allCards,
                controller: _controller,
                onEdit: (card, idx) => showEditDialog(
                  context,
                  card: card,
                  index: idx,
                  allCards: allCards,
                  applyFilters: applyFilters,
                  saveCards: saveCards,
                ),
                onDelete: (idx) => showDeleteDialog(
                  context,
                  index: idx,
                  allCards: allCards,
                  applyFilters: applyFilters,
                  saveCards: saveCards,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber[700],
        icon: const Icon(Icons.add),
        label: const Text("Add card"),
        onPressed: () {
          showInsertDialog(
            context,
            allCards: allCards,
            applyFilters: applyFilters,
            saveCards: saveCards,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription?.cancel();
    _connectionSubscription?.cancel();
    _bluetooth.dispose();
    super.dispose();
  }
}