class GameCard {
  final String name;
  final String type;
  final int attack;
  final int defense;
  final String imagePath;

  GameCard({
    required this.name,
    required this.type,
    required this.attack,
    required this.defense,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'attack': attack,
      'defense': defense,
      'imagePath': imagePath,
    };
  }

  factory GameCard.fromJson(Map<String, dynamic> json) {
    return GameCard(
      name: json['name'],
      type: json['type'],
      attack: json['attack'],
      defense: json['defense'],
      imagePath: json['imagePath'],
    );
  }
}