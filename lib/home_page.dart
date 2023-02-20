import 'package:avatar_glow/avatar_glow.dart';
import 'package:chatbot/Models/chat_models.dart';
import 'package:chatbot/api_services.dart';
import 'package:chatbot/colors.dart';
import 'package:chatbot/three_dots.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SpeechToText speechToText = SpeechToText();

  var text = "Hold the button and start speaking";
  var isListening = false;
  bool _istyping = false;

  final List<ChatMessage> messages = [];

  var scrollController = ScrollController();

  scrollMethod() {
    // when we are chatting and the screen got full ..... then the screen will automatically get scrolled by this method.
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          endRadius: 75.0,
          animate: isListening,
          duration: const Duration(milliseconds: 2000),
          glowColor: bgColor,
          repeat: true,
          repeatPauseDuration: const Duration(milliseconds: 100),
          showTwoGlows: true,
          child: GestureDetector(
            onTapDown: (details) async {
              if (!isListening) {
                var available = await speechToText.initialize();
                if (available) {
                  setState(() {
                    isListening = true;
                    speechToText.listen(
                      onResult: (result) => {
                        setState(() {
                          text = result.recognizedWords;
                        })
                      },
                    );
                  });
                }
              }
            },
            onTapUp: (details) async {
              setState(() {
                isListening = false;
                // speechToText.stop();
              });
              speechToText.stop();

              messages.add(ChatMessage(
                  text: text,
                  type: ChatMessageType.user)); // this is the message we send

              _istyping = true;

              var msg = await ApiServices.sendMessage(text);
              setState(() {
                messages.add(ChatMessage(text: msg, type: ChatMessageType.bot));
                _istyping = false; // to show typing indicator
              });
            },
            child: CircleAvatar(
              backgroundColor: bgColor,
              radius: 35,
              child: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
              ),
            ),
          ),
        ),
        appBar: AppBar(
          leading: const Icon(
            Icons.sort_rounded,
            color: Colors.white,
          ),
          centerTitle: true,
          backgroundColor: bgColor,
          elevation: 0.0,
          title: const Text(
            ' ChatGpt ChatBot',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: TextColor,
            ),
          ),
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ),
            // margin: const EdgeInsets.only(bottom: 150),
            child: Column(
              children: [
                Text(
                  text,
                  style: TextStyle(
                      fontSize: 18,
                      color: isListening ? Colors.black87 : Colors.black54,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 15,
                ),
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: chatBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            var chat = messages[index];
                            return chatBubble(
                                chattext: chat.text, type: chat.type);
                          })),
                ),
                const SizedBox(
                  height: 5,
                ),
                if (_istyping) const ThreeDots(),
                Text(
                  "Made by - Himanshu",
                  // {with 💖}
                  style: TextStyle(
                      fontSize: 16,
                      color: isListening ? Colors.black87 : Colors.black54,
                      fontWeight: FontWeight.w400),
                ),
              ],
            )));
  }

  Widget chatBubble({required chattext, required ChatMessageType? type}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: bgColor,
          child: type == ChatMessageType.bot
              ? Image.asset('assets/gpt.png')
              : const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
                color: type == ChatMessageType.bot ? bgColor : Colors.white,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12))),
            child: Text(
              "$chattext",
              style: TextStyle(
                  color: type == ChatMessageType.bot ? TextColor : chatBgColor,
                  fontSize: 15,
                  fontWeight: type == ChatMessageType.bot
                      ? FontWeight.w600
                      : FontWeight.w400),
            ),
          ),
        ),
      ],
    );
  }
}
