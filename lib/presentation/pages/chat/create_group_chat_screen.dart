import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/chat/bloc/chat_bloc.dart';
import '../../../features/chat/bloc/chat_event.dart';
import '../../../features/chat/bloc/chat_state.dart';
import '../../../features/auth/data/constants.dart';
import '../friends/friends_page.dart';

class CreateGroupChatScreen extends StatefulWidget {
  const CreateGroupChatScreen({super.key});

  @override
  State<CreateGroupChatScreen> createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  File? _avatarImage;
  List<String> _selectedFriends = [];
  bool _isLoading = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString(AuthDataConstants.userIdKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFCF6),
        elevation: 0,
        title: const Text(
          'Create Group Chat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is ChatCreatingChat) {
                setState(() => _isLoading = true);
              } else if (state is ChatGroupChatCreated) {
                setState(() => _isLoading = false);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Group chat created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ChatCreateChatError) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return TextButton(
                onPressed: _isLoading ? null : _createGroupChat,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Create',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group avatar
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: _avatarImage != null
                      ? ClipOval(
                          child: Image.file(
                            _avatarImage!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Tap to add group photo',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            // Group name
            const Text(
              'Group Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter group name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.group),
              ),
            ),
            const SizedBox(height: 16),
            // Group description
            const Text(
              'Description (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter group description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),
            // Selected friends
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Participants',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _selectFriends,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Friends'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA31D1D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedFriends.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedFriends.length} friends selected',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _selectedFriends.map((friendId) {
                        return Chip(
                          label: Text(friendId), // In a real app, you'd show friend names
                          onDeleted: () {
                            setState(() {
                              _selectedFriends.remove(friendId);
                            });
                          },
                          deleteIcon: const Icon(Icons.close, size: 18),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add friends to create a group chat',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 70,
    );
    
    if (image != null) {
      setState(() {
        _avatarImage = File(image.path);
      });
    }
  }

  void _selectFriends() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FriendsPage(
          selectMode: true,
          multiSelect: true,
        ),
      ),
    ).then((selectedFriendIds) {
      if (selectedFriendIds != null && selectedFriendIds is List<String>) {
        setState(() {
          _selectedFriends = selectedFriendIds;
        });
      }
    });
  }

  void _createGroupChat() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one friend'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current user. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<ChatBloc>().add(
      ChatEventCreateGroupChat(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        admin: currentUserId!,
        participants: [..._selectedFriends, currentUserId!],
        avatar: _avatarImage,
      ),
    );
  }
} 