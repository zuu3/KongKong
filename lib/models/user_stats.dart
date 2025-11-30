class UserStats {
  final int level;
  final int currentXp;
  final int requiredXp;

  const UserStats({
    required this.level,
    required this.currentXp,
    required this.requiredXp,
  });

  UserStats copyWith({
    int? level,
    int? currentXp,
    int? requiredXp,
  }) {
    return UserStats(
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      requiredXp: requiredXp ?? this.requiredXp,
    );
  }

  factory UserStats.initial() {
    return const UserStats(level: 1, currentXp: 0, requiredXp: 1000);
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'currentXp': currentXp,
      'requiredXp': requiredXp,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      level: json['level'] as int,
      currentXp: json['currentXp'] as int,
      requiredXp: json['requiredXp'] as int,
    );
  }
}
