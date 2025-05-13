import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/chatbot/bloc/chatbot_bloc.dart';
import 'package:lacquer/features/chatbot/bloc/chatbot_event.dart';
import 'package:lacquer/features/chatbot/bloc/chatbot_state.dart';

class ChatBotPage extends StatefulWidget {
  final String userId;

  const ChatBotPage({super.key, required this.userId});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isKeyboardVisible = false; //Biến để theo dõi trạng tái bàn phím
  bool _emptyConversation = true; // Biến để theo dõi trạng thái cuộc trò chuyện
  final List<Widget> _conversationList = [];

  @override
  bool get wantKeepAlive => true; // Giữ lại trạng thái của widget khi chuyển đổi giữa các tab

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(() {
      setState(() {}); // rebuild khi focus thay đổi
    });
    context.read<ChatbotBloc>().add(
      ChatbotEventGetHistory(userId: widget.userId),
    );
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
    final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    final isVisible = bottomInset > 0.0;

    if (isVisible != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = isVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final title = _emptyConversation ? null : _buildAppBar();
    final chatbotState = context.watch<ChatbotBloc>().state;

    var chatbotWidget = (switch (chatbotState) {
      ChatbotInitial() => _buildInitialChatbotWidget(null),
      ChatbotFetchingFailure() => _buildInitialChatbotWidget(
        chatbotState.message,
      ),
      ChatbotFetchingInProgress() => _buildInitialChatbotWidget(null),
      _ => _buildInConversationWidget(),
    });

    chatbotWidget = BlocListener<ChatbotBloc, ChatbotState>(
      listener: (context, state) {
        switch (state) {
          case ChatbotFetchingSuccess():
            _conversationList.clear();
            _emptyConversation = false;
            for (var message in state.history) {
              if (message.role == 'user') {
                _conversationList.add(_buildUserMessage(message.parts[0].text));
              } else {
                _conversationList.add(_buildBotMessage(message.parts[0].text));
              }
            }
            break;
          case ChatbotAskingInProgress():
            _conversationList.add(_buildLoadingIndicator());
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
            break;
          case ChatbotAskingSuccess():
            _conversationList.removeLast(); // Remove CircularProgressIndicator
            _conversationList.add(_buildBotMessage(state.response));
            break;
          case ChatbotAskingFailure():
            _conversationList.removeLast(); // Remove CircularProgressIndicator
            _conversationList.add(_buildErrorMessage(state.message));
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
  Widget _buildInitialChatbotWidget(String? message) {
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
          Text(
            message ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              fontFamily: GoogleFonts.roboto().fontFamily,
              color: CustomTheme.black,
            ),
          ),
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
              controller: _scrollController,
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
        fontSize: 35,
        fontWeight: FontWeight.bold,
        fontFamily: GoogleFonts.lora().fontFamily,
        foreground:
            Paint()
              ..shader = LinearGradient(
                colors: <Color>[CustomTheme.chatbotprimary, CustomTheme.chatbotsecondary],
              ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
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

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: CustomTheme.white,
      centerTitle: true,
      title: _buildHeader(),
      leading: const SizedBox(),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _onDeleteHistory(context);
            }
          },
          itemBuilder:
              (BuildContext context) => [
                PopupMenuItem(value: 'delete', child: Text('Delete history')),
                PopupMenuItem(value: 'setting', child: Text('Settings')),
              ],
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
    return Align(
      alignment: Alignment.centerRight, // Luôn đẩy container sang bên phải
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
              0.8, // Giới hạn chiều rộng tối đa
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Bo góc
          gradient: LinearGradient(
                colors: <Color>[
                  CustomTheme.chatbotprimary,
                  CustomTheme.chatbotsecondary,
                ],
                begin: FractionalOffset(0.0, 1.0),
                end: FractionalOffset(1.0, 1.0),
                stops: <double>[0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
        ),
        child: Text(
          message,
          textAlign: TextAlign.justify, // Căn đều text bên trong
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.roboto().fontFamily,
            color: CustomTheme.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBotMessage(String reply) {
    return Align(
      alignment: Alignment.centerLeft, // Luôn đẩy container sang bên trái
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.only(bottom: 15),
        child: Text(
          reply,
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: GoogleFonts.lora().fontFamily,
            color: CustomTheme.black,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.only(bottom: 15),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
              0.8, // Giới hạn chiều rộng tối đa
        ),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                fontFamily: GoogleFonts.lora().fontFamily,
                color: CustomTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _onResendMessage,
              child: Icon(Icons.refresh, color: CustomTheme.black, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Image.asset('assets/icons/feather.gif', width: 100, height: 100),
    );
  }

  //----------------------------- FUNCTIONS -----------------------------
  void _onAsking(BuildContext context, String question) {
    context.read<ChatbotBloc>().add(
      ChatbotEventAsking(prompt: question, userId: widget.userId),
    );
    _conversationList.add(_buildUserMessage(question));
    setState(() {
      _emptyConversation = false;
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onDeleteHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to delete the history?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng dialog
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng dialog
                _deleteHistory();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteHistory() {
    context.read<ChatbotBloc>().add(
      ChatbotEventDeleteHistory(userId: widget.userId),
    );
    _conversationList.clear();
    _emptyConversation = true;
  }

  void _onResendMessage() {}
}
