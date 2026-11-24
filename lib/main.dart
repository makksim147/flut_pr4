import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/notes_cubit.dart';
import 'models/note.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Практос заметок",
      home: BlocProvider(
        create: (_) => NotesCubit(),
        child: const NotesWidget(),
      ),
    );
  }
}

class NotesWidget extends StatefulWidget {
  const NotesWidget({super.key});

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  final TextEditingController _controller =
      TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void showNote(Note note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Просмотр заметки"),
          content: SingleChildScrollView(
            child: Text(note.text),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Закрыть"),
            ),
          ],
        );
      },
    );
  }

  Future<void> editNote(Note note) async {
    final cubit = context.read<NotesCubit>();

    String text = note.text;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Редактирование заметки"),
          content: TextFormField(
            initialValue: note.text,
            maxLines: 5,
            onChanged: (value) {
              text = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, text);
              },
              child: const Text("Сохранить"),
            ),
          ],
        );
      },
    );

    if (result != null && !cubit.isClosed) {
      cubit.editNote(note.id, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(
        232, 232, 232, 1,
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: BlocBuilder<NotesCubit, NotesState>(
            builder: (context, state) {
              final notes =
                  state is NotesLoaded ? state.notes : <Note>[];

              return Column(
                
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: "Введите текст заметки!",
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<NotesCubit>().addNote(
                                  _controller.text,
                                );

                            _controller.clear();
                          },
                          child: const Text("Сохранить"),
                        ),
                      ],
                    ),
                  ),
                  const Text("Список ваших заметок"),
                  SizedBox(
                    height: 400,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];

                        return Dismissible(
                          key: ValueKey(note.id),

                          direction: DismissDirection.horizontal,

                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(15),
                            child: const Icon(
                              Icons.star_border,
                              color: Colors.white,
                            ),
                          ),

                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.all(15),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),

                          confirmDismiss: (direction) async {
                            if (direction ==
                                DismissDirection.startToEnd) {
                              context
                                  .read<NotesCubit>()
                                  .resetImportance(note.id);

                              return false;
                            }

                            return direction ==
                                DismissDirection.endToStart;
                          },

                          onDismissed: (direction) {
                            context
                                .read<NotesCubit>()
                                .deleteNote(note.id);
                          },

                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,

                            onTap: () {
                              showNote(note);
                            },

                            onDoubleTap: () {
                              context
                                  .read<NotesCubit>()
                                  .markImportant(note.id);
                            },

                            onLongPress: () {
                              editNote(note);
                            },

                            child: ListTile(
                              tileColor: note.isImportant
                                  ? Colors.yellow.shade200
                                  : Colors.transparent,

                              title: Row(
                                children: [
                                  Flexible(
                                    child: SizedBox(
                                      width: 200,
                                      child: Text(
                                        note.text,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),

                                  if (note.isImportant)
                                    const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                    ),

                                  ElevatedButton(
                                    onPressed: () {
                                      context
                                          .read<NotesCubit>()
                                          .deleteNote(note.id);
                                    },
                                    child: const Text("Удалить"),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      editNote(note);
                                    },
                                    child: const Text("Изменить"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}