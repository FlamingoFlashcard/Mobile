import 'package:flutter/material.dart';

// Data model for dictionary words
class DictionaryWord {
  final String english;
  final String vietnamese;
  final String pronunciation;
  final String category;

  DictionaryWord({
    required this.english,
    required this.vietnamese,
    required this.pronunciation,
    required this.category,
  });
}

// Data model for topic categories
class TopicCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<DictionaryWord> words;

  TopicCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.words,
  });
}

// Main widget for dictionary topics
class DictionaryTopicWidget extends StatefulWidget {
  final Function(String) onWordSearch;
  final bool isEngToVie;

  const DictionaryTopicWidget({
    super.key,
    required this.onWordSearch,
    this.isEngToVie = true, // Default to English-to-Vietnamese
  });

  @override
  State<DictionaryTopicWidget> createState() => _DictionaryTopicWidgetState();
}

class _DictionaryTopicWidgetState extends State<DictionaryTopicWidget> {
  int? selectedCategoryIndex;

  // Sample dictionary data organized by topics
  final Map<String, TopicCategory> topicsEng = {
    'food': TopicCategory(
      name: 'Food & Drinks',
      icon: Icons.restaurant,
      color: Colors.orange,
      words: [
        DictionaryWord(
          english: 'Apple',
          vietnamese: 'Quả táo',
          pronunciation: '/ˈæpəl/',
          category: 'Food',
        ),
        DictionaryWord(
          english: 'Rice',
          vietnamese: 'Cơm/Gạo',
          pronunciation: '/raɪs/',
          category: 'Food',
        ),
        DictionaryWord(
          english: 'Coffee',
          vietnamese: 'Cà phê',
          pronunciation: '/ˈkɔːfi/',
          category: 'Drinks',
        ),
        DictionaryWord(
          english: 'Water',
          vietnamese: 'Nước',
          pronunciation: '/ˈwɔːtər/',
          category: 'Drinks',
        ),
      ],
    ),
    'family': TopicCategory(
      name: 'Family',
      icon: Icons.family_restroom,
      color: Colors.pink,
      words: [
        DictionaryWord(
          english: 'Mother',
          vietnamese: 'Mẹ',
          pronunciation: '/ˈmʌðər/',
          category: 'Family',
        ),
        DictionaryWord(
          english: 'Father',
          vietnamese: 'Bố/Cha',
          pronunciation: '/ˈfɑːðər/',
          category: 'Family',
        ),
        DictionaryWord(
          english: 'Sister',
          vietnamese: 'Chị/Em gái',
          pronunciation: '/ˈsɪstər/',
          category: 'Family',
        ),
        DictionaryWord(
          english: 'Brother',
          vietnamese: 'Anh/Em trai',
          pronunciation: '/ˈbrʌðər/',
          category: 'Family',
        ),
      ],
    ),
    'colors': TopicCategory(
      name: 'Colors',
      icon: Icons.palette,
      color: Colors.purple,
      words: [
        DictionaryWord(
          english: 'Red',
          vietnamese: 'Màu đỏ',
          pronunciation: '/red/',
          category: 'Colors',
        ),
        DictionaryWord(
          english: 'Blue',
          vietnamese: 'Màu xanh dương',
          pronunciation: '/bluː/',
          category: 'Colors',
        ),
        DictionaryWord(
          english: 'Green',
          vietnamese: 'Màu xanh lá',
          pronunciation: '/ɡriːn/',
          category: 'Colors',
        ),
        DictionaryWord(
          english: 'Yellow',
          vietnamese: 'Màu vàng',
          pronunciation: '/ˈjeloʊ/',
          category: 'Colors',
        ),
      ],
    ),
    'animals': TopicCategory(
      name: 'Animals',
      icon: Icons.pets,
      color: Colors.green,
      words: [
        DictionaryWord(
          english: 'Dog',
          vietnamese: 'Con chó',
          pronunciation: '/dɔːɡ/',
          category: 'Animals',
        ),
        DictionaryWord(
          english: 'Cat',
          vietnamese: 'Con mèo',
          pronunciation: '/kæt/',
          category: 'Animals',
        ),
        DictionaryWord(
          english: 'Bird',
          vietnamese: 'Con chim',
          pronunciation: '/bɜːrd/',
          category: 'Animals',
        ),
        DictionaryWord(
          english: 'Fish',
          vietnamese: 'Con cá',
          pronunciation: '/fɪʃ/',
          category: 'Animals',
        ),
      ],
    ),
    'transportation': TopicCategory(
      name: 'Transportation',
      icon: Icons.directions_car,
      color: Colors.blue,
      words: [
        DictionaryWord(
          english: 'Car',
          vietnamese: 'Xe hơi/Ô tô',
          pronunciation: '/kɑːr/',
          category: 'Transportation',
        ),
        DictionaryWord(
          english: 'Bicycle',
          vietnamese: 'Xe đạp',
          pronunciation: '/ˈbaɪsɪkəl/',
          category: 'Transportation',
        ),
        DictionaryWord(
          english: 'Bus',
          vietnamese: 'Xe buýt',
          pronunciation: '/bʌs/',
          category: 'Transportation',
        ),
        DictionaryWord(
          english: 'Airplane',
          vietnamese: 'Máy bay',
          pronunciation: '/ˈerpleɪn/',
          category: 'Transportation',
        ),
      ],
    ),
    'weather': TopicCategory(
      name: 'Weather',
      icon: Icons.wb_sunny,
      color: Colors.amber,
      words: [
        DictionaryWord(
          english: 'Sunny',
          vietnamese: 'Nắng',
          pronunciation: '/ˈsʌni/',
          category: 'Weather',
        ),
        DictionaryWord(
          english: 'Rain',
          vietnamese: 'Mưa',
          pronunciation: '/reɪn/',
          category: 'Weather',
        ),
        DictionaryWord(
          english: 'Cloud',
          vietnamese: 'Đám mây',
          pronunciation: '/klaʊd/',
          category: 'Weather',
        ),
        DictionaryWord(
          english: 'Wind',
          vietnamese: 'Gió',
          pronunciation: '/wɪnd/',
          category: 'Weather',
        ),
      ],
    ),
  };

  // Vietnamese topics with Vietnamese names
  final Map<String, TopicCategory> topicsVie = {
    'food': TopicCategory(
      name: 'Thức ăn & Đồ uống',
      icon: Icons.restaurant,
      color: Colors.orange,
      words: [
        DictionaryWord(
          english: 'Apple',
          vietnamese: 'Quả táo',
          pronunciation: '/ˈæpəl/',
          category: 'Thức ăn',
        ),
        DictionaryWord(
          english: 'Rice',
          vietnamese: 'Cơm/Gạo',
          pronunciation: '/raɪs/',
          category: 'Thức ăn',
        ),
        DictionaryWord(
          english: 'Coffee',
          vietnamese: 'Cà phê',
          pronunciation: '/ˈkɔːfi/',
          category: 'Đồ uống',
        ),
        DictionaryWord(
          english: 'Water',
          vietnamese: 'Nước',
          pronunciation: '/ˈwɔːtər/',
          category: 'Đồ uống',
        ),
      ],
    ),
    'family': TopicCategory(
      name: 'Gia đình',
      icon: Icons.family_restroom,
      color: Colors.pink,
      words: [
        DictionaryWord(
          english: 'Mother',
          vietnamese: 'Mẹ',
          pronunciation: '/ˈmʌðər/',
          category: 'Gia đình',
        ),
        DictionaryWord(
          english: 'Father',
          vietnamese: 'Bố/Cha',
          pronunciation: '/ˈfɑːðər/',
          category: 'Gia đình',
        ),
        DictionaryWord(
          english: 'Sister',
          vietnamese: 'Chị/Em gái',
          pronunciation: '/ˈsɪstər/',
          category: 'Gia đình',
        ),
        DictionaryWord(
          english: 'Brother',
          vietnamese: 'Anh/Em trai',
          pronunciation: '/ˈbrʌðər/',
          category: 'Gia đình',
        ),
      ],
    ),
    'colors': TopicCategory(
      name: 'Màu sắc',
      icon: Icons.palette,
      color: Colors.purple,
      words: [
        DictionaryWord(
          english: 'Red',
          vietnamese: 'Màu đỏ',
          pronunciation: '/red/',
          category: 'Màu sắc',
        ),
        DictionaryWord(
          english: 'Blue',
          vietnamese: 'Màu xanh dương',
          pronunciation: '/bluː/',
          category: 'Màu sắc',
        ),
        DictionaryWord(
          english: 'Green',
          vietnamese: 'Màu xanh lá',
          pronunciation: '/ɡriːn/',
          category: 'Màu sắc',
        ),
        DictionaryWord(
          english: 'Yellow',
          vietnamese: 'Màu vàng',
          pronunciation: '/ˈjeloʊ/',
          category: 'Màu sắc',
        ),
      ],
    ),
    'animals': TopicCategory(
      name: 'Động vật',
      icon: Icons.pets,
      color: Colors.green,
      words: [
        DictionaryWord(
          english: 'Dog',
          vietnamese: 'Con chó',
          pronunciation: '/dɔːɡ/',
          category: 'Động vật',
        ),
        DictionaryWord(
          english: 'Cat',
          vietnamese: 'Con mèo',
          pronunciation: '/kæt/',
          category: 'Động vật',
        ),
        DictionaryWord(
          english: 'Bird',
          vietnamese: 'Con chim',
          pronunciation: '/bɜːrd/',
          category: 'Động vật',
        ),
        DictionaryWord(
          english: 'Fish',
          vietnamese: 'Con cá',
          pronunciation: '/fɪʃ/',
          category: 'Động vật',
        ),
      ],
    ),
    'transportation': TopicCategory(
      name: 'Phương tiện giao thông',
      icon: Icons.directions_car,
      color: Colors.blue,
      words: [
        DictionaryWord(
          english: 'Car',
          vietnamese: 'Xe hơi/Ô tô',
          pronunciation: '/kɑːr/',
          category: 'Phương tiện',
        ),
        DictionaryWord(
          english: 'Bicycle',
          vietnamese: 'Xe đạp',
          pronunciation: '/ˈbaɪsɪkəl/',
          category: 'Phương tiện',
        ),
        DictionaryWord(
          english: 'Bus',
          vietnamese: 'Xe buýt',
          pronunciation: '/bʌs/',
          category: 'Phương tiện',
        ),
        DictionaryWord(
          english: 'Airplane',
          vietnamese: 'Máy bay',
          pronunciation: '/ˈerpleɪn/',
          category: 'Phương tiện',
        ),
      ],
    ),
    'weather': TopicCategory(
      name: 'Thời tiết',
      icon: Icons.wb_sunny,
      color: Colors.amber,
      words: [
        DictionaryWord(
          english: 'Sunny',
          vietnamese: 'Nắng',
          pronunciation: '/ˈsʌni/',
          category: 'Thời tiết',
        ),
        DictionaryWord(
          english: 'Rain',
          vietnamese: 'Mưa',
          pronunciation: '/reɪn/',
          category: 'Thời tiết',
        ),
        DictionaryWord(
          english: 'Cloud',
          vietnamese: 'Đám mây',
          pronunciation: '/klaʊd/',
          category: 'Thời tiết',
        ),
        DictionaryWord(
          english: 'Wind',
          vietnamese: 'Gió',
          pronunciation: '/wɪnd/',
          category: 'Thời tiết',
        ),
      ],
    ),
  };

  List<TopicCategory> get topics {
    final topicMap = widget.isEngToVie ? topicsEng : topicsVie;
    return topicMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedCategoryIndex != null) ...[
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: topics[selectedCategoryIndex!].color.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.isEngToVie
                          ? 'Words in ${topics[selectedCategoryIndex!].name}'
                          : 'Từ vựng trong ${topics[selectedCategoryIndex!].name}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: topics[selectedCategoryIndex!].color,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: topics[selectedCategoryIndex!].words.length,
                      itemBuilder: (context, wordIndex) {
                        final word =
                            topics[selectedCategoryIndex!].words[wordIndex];
                        return WordCard(
                          word: word,
                          isEngToVie: widget.isEngToVie,
                          onTap:
                              () => widget.onWordSearch(
                                widget.isEngToVie
                                    ? word.english
                                    : word.vietnamese,
                              ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              final isSelected = selectedCategoryIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategoryIndex = isSelected ? null : index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? topic.color.withValues(alpha: 0.2)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? topic.color : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(topic.icon, size: 40, color: topic.color),
                      const SizedBox(height: 8),
                      Text(
                        topic.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? topic.color : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.isEngToVie
                            ? '${topic.words.length} words'
                            : '${topic.words.length} từ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Individual word card widget
class WordCard extends StatelessWidget {
  final DictionaryWord word;
  final bool isEngToVie;
  final VoidCallback onTap;

  const WordCard({
    super.key,
    required this.word,
    required this.isEngToVie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine primary and secondary text based on dictionary direction
    final String primaryText = isEngToVie ? word.english : word.vietnamese;
    final String secondaryText = isEngToVie ? word.vietnamese : word.english;
    final String displayChar =
        isEngToVie
            ? word.english[0].toUpperCase()
            : word.vietnamese[0].toUpperCase();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withValues(alpha: 0.1),
          child: Text(
            displayChar,
            style: const TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                primaryText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isEngToVie) ...[
              const SizedBox(width: 8),
              Text(
                word.pronunciation,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          secondaryText,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        trailing: const Icon(Icons.search, color: Colors.indigo),
      ),
    );
  }
}
