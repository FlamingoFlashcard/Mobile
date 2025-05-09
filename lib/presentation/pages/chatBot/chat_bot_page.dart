import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/chatbot/bloc/chatbot_bloc.dart';
import 'package:lacquer/features/chatbot/bloc/chatbot_event.dart';
import 'package:lacquer/features/chatbot/bloc/chatbot_state.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isKeyboardVisible = false; //Biến để theo dõi trạng tái bàn phím
  bool _emptyConversation = true; // Biến để theo dõi trạng thái cuộc trò chuyện
  List<String> userMessage = [];
  List<String> botMessage = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _focusNode.addListener(() {
      setState(() {}); // rebuild khi focus thay đổi
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Lắng nghe thay đổi về bàn phím
  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = bottomInset > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    var title = _emptyConversation ? null : _buildHeader();
    final chatbotState = context.watch<ChatbotBloc>().state;

    var chatbotWidget = (switch (chatbotState) {
      ChatbotInitial() => _buildInitialChatbotWidget(),
      _ => _buildInConversationWidget(),
    });

    chatbotWidget = BlocListener<ChatbotBloc, ChatbotState>(
      listener: (context, state) {
        switch (state) {
          case ChatbotAskingInProgress():
            _conversationList.add(_buildUserMessage(userMessage.last));
            _conversationList.add(
              SizedBox(
                width: 30,
                height: 30,
                child: const CircularProgressIndicator(),
              ),
            );
            break;
          case ChatbotAskingSuccess():
            _conversationList.removeLast(); // Remove CircularProgressIndicator
            _conversationList.add(_buildBotMessage(state.response));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom(); // Cuộn xuống dưới cùng sau khi thêm tin nhắn
            });
            break;
          case ChatbotAskingFailure():
            _conversationList.removeLast(); // Remove CircularProgressIndicator
            _conversationList.add(_buildBotMessage(state.message));
            break;
          default:
            break;
        }
      },
      child: chatbotWidget,
    );

    return Scaffold(
      appBar: AppBar(backgroundColor: CustomTheme.white, title: title),
      backgroundColor: CustomTheme.white,
      resizeToAvoidBottomInset: true,
      body: chatbotWidget,
    );
  }

  //----------------------------- WIDGETS -----------------------------
  final List<Widget> _conversationList = [];

  Widget _buildInitialChatbotWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          _buildTitle(),
          _buildHeader(),
          const SizedBox(height: 20),
          //Search bar
          _buildSearchBar(context),
        ],
      ),
    );
  }

  Widget _buildInConversationWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _conversationList.length,
              itemBuilder: (context, index) {
                return _conversationList[index];
              },
            ),
          ),
          const SizedBox(height: 20),
          //Search bar
          _buildSearchBar(context),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Discover culture, cuisine and more with',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        fontFamily: GoogleFonts.lora().fontFamily,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Mr. Calligraphy',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.moonDance().fontFamily,
          ),
        ),
        const SizedBox(width: 10),
        Image(
          image: AssetImage('assets/images/inkwell.png'),
          width: 40,
          height: 40,
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final searchBarBottom =
        _isKeyboardVisible || _focusNode.hasFocus
            ? keyboardHeight // Khi focus, đẩy lên trên cùng
            : screenHeight * 0.6; // Khi không focus, nằm ở giữa/dưới
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: _emptyConversation ? searchBarBottom : 20,
      left: 20,
      right: 20,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: TextField(
          controller: controller,
          focusNode: _focusNode,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _onAsking(context, value.trim());
            }
          },
          decoration: InputDecoration(
            hintText: 'Ask me anything',
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return IconButton(
                  icon: Icon(
                    Icons.search,
                    color: value.text.isEmpty ? Colors.grey : Colors.black,
                  ),
                  onPressed:
                      value.text.isEmpty
                          ? null
                          : () => _onAsking(context, controller.text.trim()),
                );
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserMessage(String message) {
    return Text(
      message,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: GoogleFonts.lora().fontFamily,
        color: CustomTheme.primaryColor,
      ),
    );
  }

  Widget _buildBotMessage(String reply) {
    return Text(
      reply,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: GoogleFonts.lora().fontFamily,
        color: CustomTheme.black,
      ),
    );
  }

  //----------------------------- FUNCTIONS -----------------------------
  void _onAsking(BuildContext context, String question) {
    context.read<ChatbotBloc>().add(ChatbotEventAsking(prompt: question));
    userMessage.add(question);
    setState(() {
      _emptyConversation = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
