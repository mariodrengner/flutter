class Clue {
  const Clue({
    required this.id,
    required this.title,
    this.category = 'Freestyle',
  });

  final String id;
  final String title;
  final String category;
}
