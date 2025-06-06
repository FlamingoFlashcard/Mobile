import 'package:flutter/material.dart';
import 'package:lacquer/presentation/pages/home/widgets/message/message_convo.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _messageScreenState();
}

// ignore: camel_case_types
class _messageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message'),
      ),
      body: Column(
        children: [
          MessageConvo(
            avatarPath: 'assets/images/avatar.jpg',
            name: 'John Doe',
            recentMessage: 'Hello, how are you?',
            time: '12:00',
            isRead: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}