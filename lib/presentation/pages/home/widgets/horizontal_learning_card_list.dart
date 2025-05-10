import 'package:flutter/widgets.dart';
import 'package:lacquer/presentation/utils/flip_card_list.dart';
import 'package:lacquer/presentation/pages/home/widgets/flip_card_component.dart';

class HorizontalLearningCardList extends StatefulWidget {
  final List<FlipCardModel> flashcardItems;

  const HorizontalLearningCardList({super.key, required this.flashcardItems});

  @override
  State<HorizontalLearningCardList> createState() =>
      _HorizontalLearningCardListState();
}

class _HorizontalLearningCardListState
    extends State<HorizontalLearningCardList> {
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
        SizedBox(height: 100),
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
                          imagePath: widget.flashcardItems[index].imagePath,
                          pronunciation:
                              widget.flashcardItems[index].pronunciation,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 16.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: List.generate(widget.flashcardItems.length, (index) {
        //       return Container(
        //         width: 12.0,
        //         height: 12.0,
        //         margin: const EdgeInsets.symmetric(horizontal: 4.0),
        //         decoration: BoxDecoration(
        //           shape: BoxShape.circle,
        //           color:
        //               _currentPage == index
        //                   ? CustomTheme.cinnabar
        //                   : Colors.grey.withAlpha((255 * 0.5).toInt()),
        //         ),
        //       );
        //     }),
        //   ),
        // ),
      ],
    );
  }
}
