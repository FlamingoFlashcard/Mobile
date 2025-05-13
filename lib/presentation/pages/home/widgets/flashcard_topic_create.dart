import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_state.dart';

class FlashcardTopicCreate extends StatefulWidget {
  const FlashcardTopicCreate({super.key});

  @override
  State<FlashcardTopicCreate> createState() => _FlashcardTopicCreateState();
}

class _FlashcardTopicCreateState extends State<FlashcardTopicCreate> {
  File? _selectedImage;
  String? _selectedTag;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FlashcardBloc>().add(const LoadTagsRequested());
  }

  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Create New Topic',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter title',
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Tag',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            BlocBuilder<FlashcardBloc, FlashcardState>(
              builder: (context, state) {
                if (state.status == FlashcardStatus.loading) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  );
                } else if (state.status == FlashcardStatus.failure) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Failed to load tags: ${state.errorMessage ?? 'Unknown error'}',
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<FlashcardBloc>().add(
                              const LoadTagsRequested(),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                final tags = state.tags.map((tag) => tag.name).toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children:
                            tags.isEmpty
                                ? [const Text('No tags available')]
                                : tags.map((tag) {
                                  final isSelected = _selectedTag == tag;
                                  return ChoiceChip(
                                    label: Text(tag),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedTag = tag;
                                        } else {
                                          _selectedTag = null;
                                        }
                                      });
                                    },
                                    selectedColor: CustomTheme.cinnabar
                                        .withOpacity(0.2),
                                    backgroundColor: Colors.grey.shade200,
                                    labelStyle: TextStyle(
                                      color:
                                          isSelected
                                              ? CustomTheme.cinnabar
                                              : Colors.black,
                                    ),
                                  );
                                }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CustomTheme.cinnabar),
                ),
                child:
                    _selectedImage == null
                        ? const Center(
                          child: Text(
                            'Tap to add topic image',
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
