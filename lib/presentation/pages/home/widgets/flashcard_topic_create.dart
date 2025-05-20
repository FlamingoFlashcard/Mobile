import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_state.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_tag_create.dart';

class FlashcardTopicCreate extends StatefulWidget {
  const FlashcardTopicCreate({super.key});

  @override
  State<FlashcardTopicCreate> createState() => _FlashcardTopicCreateState();
}

class _FlashcardTopicCreateState extends State<FlashcardTopicCreate> {
  File? _selectedImage;
  String? _selectedTagId;
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

  void _createDeck() {
    if (_titleController.text.isEmpty || _selectedTagId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and select a tag')),
      );
      return;
    }

    final bloc = context.read<FlashcardBloc>();
    bloc.add(
      CreateDeckRequested(
        title: _titleController.text,
        description: 'Description here',
        tags: [_selectedTagId!],
        cardIds: [],
        imageFile: _selectedImage,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Create New Topic',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: CustomTheme.mainColor1,
        ),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: 300,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter title',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Tag',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: CustomTheme.mainColor1,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const FlashcardTagCreate(),
                      );
                    },
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                      foregroundColor: CustomTheme.mainColor1,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: CustomTheme.mainColor1),
                        const SizedBox(width: 8),
                        const Text("New Tag"),
                      ],
                    ),
                  ),
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
                    final tags = state.tags;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children:
                                tags.isEmpty
                                    ? [const Text('No tags available')]
                                    : tags.map((tag) {
                                      final isSelected =
                                          _selectedTagId == tag.id;
                                      return ChoiceChip(
                                        showCheckmark: false,
                                        label: Text(tag.name),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              _selectedTagId = tag.id;
                                            } else {
                                              _selectedTagId = null;
                                            }
                                          });
                                        },
                                        selectedColor: CustomTheme.mainColor3,
                                        backgroundColor: Colors.grey.shade200,
                                        labelStyle: TextStyle(
                                          color:
                                              isSelected
                                                  ? CustomTheme.mainColor1
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
                const Text(
                  'Choose your topic image',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: CustomTheme.mainColor1,
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
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
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: CustomTheme.primaryColor,
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          onPressed: _createDeck,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
