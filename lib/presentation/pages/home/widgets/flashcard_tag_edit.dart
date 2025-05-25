import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_state.dart';

class FlashcardTagEdit extends StatefulWidget {
  final String tagId;
  final String title;
  const FlashcardTagEdit({super.key, required this.tagId, required this.title});

  @override
  State<FlashcardTagEdit> createState() => _FlashcardTagEditState();
}

class _FlashcardTagEditState extends State<FlashcardTagEdit> {
  final TextEditingController _titleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Edit Your Tag',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: CustomTheme.mainColor1,
        ),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: 300,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter tag title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a tag title';
                    }
                    return null;
                  },
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
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
        BlocConsumer<FlashcardBloc, FlashcardState>(
          listener: (context, state) {
            if (state.updateTagStatus == FlashcardStatus.success) {
              setState(() {
                _errorMessage = null;
              });
              Navigator.of(context).pop();
            } else if (state.updateTagStatus == FlashcardStatus.failure) {
              setState(() {
                if (state.errorMessage?.contains("Tag already exists") ==
                    true) {
                  _errorMessage = "Tag already exists";
                } else {
                  _errorMessage =
                      state.errorMessage?.replaceFirst("Exception: ", "") ??
                      'Failed to update tag';
                }
              });
            }
          },
          builder: (context, state) {
            return TextButton(
              style: TextButton.styleFrom(
                foregroundColor: CustomTheme.primaryColor,
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child:
                  state.updateTagStatus == FlashcardStatus.loading
                      ? const CircularProgressIndicator(
                        color: CustomTheme.primaryColor,
                      )
                      : const Text('Update'),
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  setState(() {
                    _errorMessage = null;
                  });
                  context.read<FlashcardBloc>().add(
                    UpdateTagRequested(
                      tagId: widget.tagId,
                      title: _titleController.text,
                    ),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }
}
