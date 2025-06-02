import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_confirm_delete.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_topic_edit.dart';

class FlashcardOptionDialog extends StatefulWidget {
  final String id;
  final String title;
  final List<String> tags;
  final String imagePath;
  const FlashcardOptionDialog({
    super.key,
    required this.id,
    required this.title,
    required this.tags,
    required this.imagePath,
  });

  @override
  State<FlashcardOptionDialog> createState() => _FlashcardOptionDialogState();
}

class _FlashcardOptionDialogState extends State<FlashcardOptionDialog> {
  int selectedIndex = -1;
  late final List<Map<String, dynamic>> options;

  @override
  void initState() {
    super.initState();

    options = [
      {
        "icon": FontAwesomeIcons.play,
        "title": "Explore",
        "subtitle": "10 new cards",
        "action": () {
          context.go(RouteName.learn(widget.id));
        },
      },
      {
        "icon": FontAwesomeIcons.rotateRight,
        "title": "Revise",
        "subtitle": "Repeat 10 cards",
        "action": () {
          print("Revise clicked");
        },
      },
      {
        "icon": FontAwesomeIcons.question,
        "title": "Multi-choice Questions",
        "subtitle": "",
        "action": () {
          print("Multi-choice Questions clicked");
        },
      },
      {
        "icon": FontAwesomeIcons.penToSquare,
        "title": "Fill In Game",
        "subtitle": "",
        "action": () {
          print("Fill In Game clicked");
        },
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 52, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose your mode",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ...List.generate(options.length, (index) {
                final item = options[index];
                final isSelected = selectedIndex == index;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isSelected
                            ? CustomTheme.cinnabar
                            : Colors.grey.shade300,
                    child: Icon(
                      item["icon"],
                      size: 20,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  title: Text(item["title"]),
                  subtitle:
                      item["subtitle"] != "" ? Text(item["subtitle"]) : null,
                  tileColor: isSelected ? CustomTheme.lightbeige : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    Navigator.pop(context);
                    final action = options[index]["action"];
                    if (action is Function) {
                      action();
                    }
                  },
                );
              }),

              const Divider(),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(
                      FontAwesomeIcons.pen,
                      size: 20,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder:
                            (context) => FlashcardTopicEdit(
                              id: widget.id,
                              title: widget.title,
                              tags: widget.tags,
                              imagePath: widget.imagePath,
                            ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      FontAwesomeIcons.listUl,
                      size: 20,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(RouteName.edit(widget.id));
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      FontAwesomeIcons.trashCan,
                      size: 20,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder:
                            (context) => FlashcardConfirmDelete(
                              id: widget.id,
                              title: widget.title,
                            ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
