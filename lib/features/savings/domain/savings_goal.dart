class SavingsGoal {
  const SavingsGoal({required this.title, required this.targetAmount});

  final String title;
  final double targetAmount;

  Map<String, dynamic> toMap() => {
        'title': title,
        'targetAmount': targetAmount,
      };

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
    );
  }
}
