class GameCard {
  final String name;
  final String type;
  final int attack;
  final int defense;
  final String color;
  final String imageURL;

  GameCard({
    required this.name,
    required this.type,
    required this.attack,
    required this.defense,
    required this.color,
    required this.imageURL,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'attack': attack,
      'defense': defense,
      'color': color,
      'imageURL': imageURL,
    };
  }

  factory GameCard.fromJson(Map<String, dynamic> json) {
    return GameCard(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      attack: (json['attack'] ?? 0) as int,
      defense: (json['defense'] ?? 0) as int,
      color: json['color'] ?? '',
      imageURL: json['imageURL'] ?? '',
    );
  }
}