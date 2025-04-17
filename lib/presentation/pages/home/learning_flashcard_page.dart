import 'package:flutter/material.dart';
import 'package:lacquer/presentation/utils/flip_card_list.dart';
import 'package:lacquer/presentation/widgets/flip_card_component.dart';
import 'package:lacquer/config/theme.dart';

class LearningFlashcardPage extends StatelessWidget {
  final List<FlipCardModel> items;
  const LearningFlashcardPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.lightbeige,
      body: Stack(
        children: [
          CustomAppBar(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [HorizontalCardList(flashcardItems: items)],
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: CustomTheme.cinnabar,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 100),
      child: const Text(
        'Learning Flashcards',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class HorizontalCardList extends StatefulWidget {
  final List<FlipCardModel> flashcardItems;

  const HorizontalCardList({super.key, required this.flashcardItems});

  @override
  State<HorizontalCardList> createState() => _HorizontalCardListState();
}

class _HorizontalCardListState extends State<HorizontalCardList> {
  late final PageController controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    controller = PageController(viewportFraction: 0.8, initialPage: 0);
    controller.addListener(_updatePage);
  }

  @override
  void dispose() {
    controller.removeListener(_updatePage);
    controller.dispose();
    super.dispose();
  }

  void _updatePage() {
    if (controller.page == null) return;
    final newPage = controller.page!.round();
    if (newPage != _currentPage) {
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 600,
          child: PageView.builder(
            controller: controller,
            itemCount: widget.flashcardItems.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  double scale = 1.0;
                  if (controller.hasClients &&
                      controller.position.haveDimensions) {
                    double page =
                        controller.page ?? controller.initialPage.toDouble();
                    scale = (1 - (page - index).abs() * 0.2).clamp(0.85, 1.0);
                  } else {
                    scale = index == controller.initialPage ? 1.0 : 0.85;
                  }

                  return Center(
                    child: Transform.scale(
                      scale: scale,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: FlipCardComp(
                          frontText: widget.flashcardItems[index].frontText,
                          backText: widget.flashcardItems[index].backText,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.flashcardItems.length, (index) {
              return Container(
                width: 12.0,
                height: 12.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentPage == index
                          ? CustomTheme.cinnabar
                          : Colors.grey.withAlpha((255 * 0.5).toInt()),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
