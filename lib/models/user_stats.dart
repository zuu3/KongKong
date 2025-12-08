class UserStats {
  final int level;
  final int currentXp;
  final int requiredXp;
  final int totalBids;
  final int wins;

  const UserStats({
    required this.level,
    required this.currentXp,
    required this.requiredXp,
    this.totalBids = 0,
    this.wins = 0,
  });

  UserStats copyWith({int? level, int? currentXp, int? requiredXp, int? totalBids, int? wins}) {
    return UserStats(
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      requiredXp: requiredXp ?? this.requiredXp,
      totalBids: totalBids ?? this.totalBids,
      wins: wins ?? this.wins,
    );
  }

  factory UserStats.initial() {
    return const UserStats(level: 1, currentXp: 0, requiredXp: 1000, totalBids: 0, wins: 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'currentXp': currentXp,
      'requiredXp': requiredXp,
      'totalBids': totalBids,
      'wins': wins,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      level: json['level'] as int,
      currentXp: json['currentXp'] as int,
      requiredXp: json['requiredXp'] as int,
      totalBids: json['totalBids'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
    );
  }
}
