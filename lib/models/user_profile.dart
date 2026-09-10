class UserProfile {
  final String name;
  final int xp;

  UserProfile({
    required this.name,
    required this.xp,
  });

  int get level {
    if (xp < 250) return 1;
    if (xp < 500) return 2;
    if (xp < 1000) return 3;
    if (xp < 2000) return 4;
    if (xp < 4000) return 5;
    return 6;
  }

  int get xpRequiredForNextLevel {
    final lvl = level;
    if (lvl == 1) return 250;
    if (lvl == 2) return 500;
    if (lvl == 3) return 1000;
    if (lvl == 4) return 2000;
    if (lvl == 5) return 4000;
    return 4000;
  }

  int get xpForCurrentLevel {
    final lvl = level;
    if (lvl == 1) return xp;
    if (lvl == 2) return xp - 250;
    if (lvl == 3) return xp - 500;
    if (lvl == 4) return xp - 1000;
    if (lvl == 5) return xp - 2000;
    return xp - 4000;
  }

  int get xpRangeForCurrentLevel {
    final lvl = level;
    if (lvl == 1) return 250;
    if (lvl == 2) return 250;
    if (lvl == 3) return 500;
    if (lvl == 4) return 1000;
    if (lvl == 5) return 2000;
    return 1;
  }

  double get levelProgress {
    if (level >= 6) return 1.0;
    // Show progress within the current level's bracket
    final progress = xpForCurrentLevel / xpRangeForCurrentLevel;
    return progress > 1.0 ? 1.0 : (progress < 0.0 ? 0.0 : progress);
  }

  UserProfile copyWith({
    String? name,
    int? xp,
  }) {
    return UserProfile(
      name: name ?? this.name,
      xp: xp ?? this.xp,
    );
  }
}
