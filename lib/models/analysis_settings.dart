import 'dart:convert';

class AnalysisSettings {
  const AnalysisSettings({
    this.formWeight = 25,
    this.attackDefenseWeight = 20,
    this.homeAwayWeight = 15,
    this.tableWeight = 10,
    this.headToHeadWeight = 10,
    this.oddsValueWeight = 15,
    this.stabilityWeight = 5,
  });

  static const balanced = AnalysisSettings();
  static const conservative = AnalysisSettings(
    formWeight: 22,
    attackDefenseWeight: 18,
    homeAwayWeight: 12,
    tableWeight: 10,
    headToHeadWeight: 8,
    oddsValueWeight: 12,
    stabilityWeight: 18,
  );
  static const aggressive = AnalysisSettings(
    formWeight: 28,
    attackDefenseWeight: 22,
    homeAwayWeight: 14,
    tableWeight: 8,
    headToHeadWeight: 8,
    oddsValueWeight: 15,
    stabilityWeight: 5,
  );

  final double formWeight;
  final double attackDefenseWeight;
  final double homeAwayWeight;
  final double tableWeight;
  final double headToHeadWeight;
  final double oddsValueWeight;
  final double stabilityWeight;

  double get totalWeight =>
      formWeight +
      attackDefenseWeight +
      homeAwayWeight +
      tableWeight +
      headToHeadWeight +
      oddsValueWeight +
      stabilityWeight;

  AnalysisSettings copyWith({
    double? formWeight,
    double? attackDefenseWeight,
    double? homeAwayWeight,
    double? tableWeight,
    double? headToHeadWeight,
    double? oddsValueWeight,
    double? stabilityWeight,
  }) {
    return AnalysisSettings(
      formWeight: formWeight ?? this.formWeight,
      attackDefenseWeight: attackDefenseWeight ?? this.attackDefenseWeight,
      homeAwayWeight: homeAwayWeight ?? this.homeAwayWeight,
      tableWeight: tableWeight ?? this.tableWeight,
      headToHeadWeight: headToHeadWeight ?? this.headToHeadWeight,
      oddsValueWeight: oddsValueWeight ?? this.oddsValueWeight,
      stabilityWeight: stabilityWeight ?? this.stabilityWeight,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'formWeight': formWeight,
      'attackDefenseWeight': attackDefenseWeight,
      'homeAwayWeight': homeAwayWeight,
      'tableWeight': tableWeight,
      'headToHeadWeight': headToHeadWeight,
      'oddsValueWeight': oddsValueWeight,
      'stabilityWeight': stabilityWeight,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory AnalysisSettings.fromMap(Map<String, dynamic> map) {
    return AnalysisSettings(
      formWeight: (map['formWeight'] ?? 25).toDouble(),
      attackDefenseWeight: (map['attackDefenseWeight'] ?? 20).toDouble(),
      homeAwayWeight: (map['homeAwayWeight'] ?? 15).toDouble(),
      tableWeight: (map['tableWeight'] ?? 10).toDouble(),
      headToHeadWeight: (map['headToHeadWeight'] ?? 10).toDouble(),
      oddsValueWeight: (map['oddsValueWeight'] ?? 15).toDouble(),
      stabilityWeight: (map['stabilityWeight'] ?? 5).toDouble(),
    );
  }

  factory AnalysisSettings.fromJson(String source) {
    return AnalysisSettings.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisSettings &&
        other.formWeight == formWeight &&
        other.attackDefenseWeight == attackDefenseWeight &&
        other.homeAwayWeight == homeAwayWeight &&
        other.tableWeight == tableWeight &&
        other.headToHeadWeight == headToHeadWeight &&
        other.oddsValueWeight == oddsValueWeight &&
        other.stabilityWeight == stabilityWeight;
  }

  @override
  int get hashCode => Object.hash(
        formWeight,
        attackDefenseWeight,
        homeAwayWeight,
        tableWeight,
        headToHeadWeight,
        oddsValueWeight,
        stabilityWeight,
      );
}
