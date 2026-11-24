part of 'notes_cubit.dart';

@immutable
sealed class NotesState {}

final class NotesLoaded extends NotesState {
  final List<Note> notes;

  NotesLoaded(this.notes);
}