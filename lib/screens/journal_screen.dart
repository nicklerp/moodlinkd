
import 'package:flutter/material.dart';

// The moods a user can assign to a journal entry.
enum JournalMood {
  sad,
  neutral,
  happy,
}

// A simple data model for journal entries.
class JournalEntry {
  final String title;
  final String content;
  final DateTime date;
  final JournalMood mood;

  const JournalEntry({
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
  });
}

IconData moodIcon(JournalMood mood) {
  switch (mood) {
    case JournalMood.sad:
      return Icons.sentiment_dissatisfied_outlined;
    case JournalMood.neutral:
      return Icons.sentiment_neutral_outlined;
    case JournalMood.happy:
      return Icons.sentiment_satisfied_alt_outlined;
  }
}

String moodLabel(JournalMood mood) {
  switch (mood) {
    case JournalMood.sad:
      return 'Sad';
    case JournalMood.neutral:
      return 'Neutral';
    case JournalMood.happy:
      return 'Happy';
  }
}

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final List<JournalEntry> _entries = [];

  // Opens the form for creating a journal entry.
  Future<void> _createEntry() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    DateTime selectedDate = DateTime.now();
    JournalMood selectedMood = JournalMood.neutral;

    final newEntry = await showModalBottomSheet<JournalEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, updateForm) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Journal Entry',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall,
                      ),
                      const SizedBox(height: 20),

                      // Title
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Date
                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          MaterialLocalizations.of(context)
                              .formatMediumDate(selectedDate),
                        ),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );

                          if (pickedDate != null &&
                              context.mounted) {
                            updateForm(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Journal content
                      TextFormField(
                        controller: contentController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Journal',
                          hintText: 'Write about your day...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please write an entry';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      const Text('How are you feeling?'),
                      const SizedBox(height: 12),

                      // Mood selection
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                        children: JournalMood.values.map((mood) {
                          final isSelected =
                              selectedMood == mood;

                          return ChoiceChip(
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  moodIcon(mood),
                                  size: 32,
                                ),
                                Text(moodLabel(mood)),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              updateForm(() {
                                selectedMood = mood;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Cancel and Save
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: () {
                              if (!formKey.currentState!
                                  .validate()) {
                                return;
                              }

                              final entry = JournalEntry(
                                title: titleController.text.trim(),
                                content: contentController
                                    .text.trim(),
                                date: selectedDate,
                                mood: selectedMood,
                              );

                              Navigator.pop(context, entry);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    contentController.dispose();

    if (newEntry != null && mounted) {
      setState(() {
        _entries.add(newEntry);
        _entries.sort(
          (a, b) => b.date.compareTo(a.date),
        );
      });
    }
  }

  // Displays a previously saved entry.
  void _viewEntry(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(entry.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MaterialLocalizations.of(context)
                      .formatMediumDate(entry.date),
                ),
                const SizedBox(height: 12),
                Icon(moodIcon(entry.mood), size: 36),
                const SizedBox(height: 12),
                Text(entry.content),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 12),

        // Large mood icon from the wireframe
        const Center(
          child: Icon(
            Icons.sentiment_satisfied_alt_outlined,
            size: 110,
          ),
        ),

        const SizedBox(height: 24),

        // Entries heading and add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Entries',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Create journal entry',
              onPressed: _createEntry,
            ),
          ],
        ),

        const Divider(),

        // Empty journal message
        if (_entries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                'No journal entries yet.\n'
                'Tap + to write your first entry!',
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Journal entry list
        for (final entry in _entries)
          Card(
            child: ListTile(
              leading: Icon(
                moodIcon(entry.mood),
                size: 32,
              ),
              title: Text(entry.title),
              subtitle: Text(
                MaterialLocalizations.of(context)
                    .formatMediumDate(entry.date),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _viewEntry(entry),
            ),
          ),
      ],
    );
  }
}