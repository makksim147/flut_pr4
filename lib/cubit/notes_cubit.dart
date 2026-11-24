import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/note.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesLoaded(const []));

  int _nextId = 0;

  void addNote(String text) {
    final trimmed = text.trim();

    if (trimmed.isEmpty) return;

    final currentNotes =
        List<Note>.from((state as NotesLoaded).notes);

    currentNotes.add(
      Note(
        id: _nextId++,
        text: trimmed,
      ),
    );

    emit(NotesLoaded(currentNotes));
  }

  void editNote(int id, String text) {
    final currentNotes =
        List<Note>.from((state as NotesLoaded).notes);

    final trimmed = text.trim();

    if (trimmed.isEmpty) return;

    for (int i = 0; i < currentNotes.length; i++) {
      if (currentNotes[i].id == id) {
        currentNotes[i] = Note(
          id: id,
          text: trimmed,
          isImportant: currentNotes[i].isImportant,
        );

        emit(NotesLoaded(currentNotes));
        return;
      }
    }
  }

  void deleteNote(int id) {
    final currentNotes =
        List<Note>.from((state as NotesLoaded).notes);

    currentNotes.removeWhere((note) => note.id == id);

    emit(NotesLoaded(currentNotes));
  }

  void markImportant(int id) {
    final currentNotes =
        List<Note>.from((state as NotesLoaded).notes);

    for (int i = 0; i < currentNotes.length; i++) {
      if (currentNotes[i].id == id) {
        currentNotes[i] = Note(
          id: id,
          text: currentNotes[i].text,
          isImportant: true,
        );

        emit(NotesLoaded(currentNotes));
        return;
      }
    }
  }

  void resetImportance(int id) {
    final currentNotes =
        List<Note>.from((state as NotesLoaded).notes);

    for (int i = 0; i < currentNotes.length; i++) {
      if (currentNotes[i].id == id) {
        currentNotes[i] = Note(
          id: id,
          text: currentNotes[i].text,
          isImportant: false,
        );

        emit(NotesLoaded(currentNotes));
        return;
      }
    }
  }
}