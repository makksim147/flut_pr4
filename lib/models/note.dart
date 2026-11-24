class Note {
  final int id;
  final String text;
  final bool isImportant;

  const Note({
    required this.id,
    required this.text,
    this.isImportant = false,
  });
}