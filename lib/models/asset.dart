class Asset {
  final int id;
  final String title;
  final int minPrice;
  final String category;
  final DateTime? deadline; // 입찰 마감 시간

  const Asset({
    required this.id,
    required this.title,
    required this.minPrice,
    required this.category,
    this.deadline,
  });

  Asset copyWith({
    int? id,
    String? title,
    int? minPrice,
    String? category,
    DateTime? deadline,
  }) =>
      Asset(
        id: id ?? this.id,
        title: title ?? this.title,
        minPrice: minPrice ?? this.minPrice,
        category: category ?? this.category,
        deadline: deadline ?? this.deadline,
      );

  factory Asset.fromMap(Map<String, dynamic> map) => Asset(
    id: map['id'] as int,
    title: map['title'] as String,
    minPrice: map['minPrice'] as int,
    category: map['category'] as String,
    deadline: map['deadline'] != null ? DateTime.parse(map['deadline'] as String) : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'minPrice': minPrice,
    'category': category,
    'deadline': deadline?.toIso8601String(),
  };
}
