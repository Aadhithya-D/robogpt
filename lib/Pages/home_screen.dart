import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:robogpt/Controllers/ai_controller.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';


import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Services/chat_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final chatController = TextEditingController();
  final AiController aiController = Get.put(AiController());

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        // ChatService().getActions("Wave goodbye");
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .background,
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .primary,
          elevation: 0,
          title: Text(
              "RoboGPT",
              style: GoogleFonts.ibmPlexMono(color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.w600)
          ),
          actions: [
            IconButton(
                onPressed: (){
                  aiController.chatHistory.removeRange(0, aiController.chatHistory.length);
                  aiController.humanHistory.removeRange(0, aiController.humanHistory.length);
                },
                icon: Icon(
                  Icons.clear_all,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .tertiary,
                ))
          ],
          centerTitle: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Obx(() => AvatarGlow(
          animate: aiController.isListening.value,
          glowColor: Theme.of(context).primaryColor,
          duration: const Duration(milliseconds: 2000),
          repeat: true,
          child: FloatingActionButton(
            onPressed: aiController.listen,
            child: Icon(aiController.isListening.value ? Icons.mic : Icons.mic_none),
          ),
        )),
        body: SafeArea(
          child: Obx(() {
            return Column(
              children: [
                const SizedBox(height: 5,),
                Expanded(child: _buildChatMessageList()),
                _buildPlaceHolder(),
                const SizedBox(height: 100,),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildChatMessageList() {
    // return SingleChildScrollView(child: Column());
    return Obx(() {
      if (aiController.humanHistory.isEmpty) {
        return Image.asset(
          "lib/images/undraw_chat_re_re1u.png",
          width: 250,
        );
      } else {
        return ListView.builder(

          itemBuilder: (BuildContext context, int index) {
            return _buildChatMessage(index);
          },
          itemCount: aiController.chatHistory.length,
        );
      }
    });
    //
  }

  Widget _buildPlaceHolder() {
    if (aiController.humanHistory.length > aiController.chatHistory.length) {
      return Column(
        children: [
          BubbleSpecialThree(
            text: aiController
                .humanHistory[aiController.humanHistory.length - 1],
            color: const Color(0xFF1B97F3),
            tail: true,
            textStyle: const TextStyle(
                color: Colors.white, fontSize: 16),
          ),
          const SizedBox(
            height: 5,
          ),
          BubbleNormalImage(
            id: 'id001',
            image: Image.asset(
              "lib/images/animation_lljc1k50_small.gif",
              height: 30,
            ),
            color: const Color(0xFFE8E8EE),
            tail: true,
            isSender: false,
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      );
    }
    else {
      return Container();
    }
  }

  Widget _buildChatMessage(int index) {
    // print(aiController.chatHistory[index].aiMessage);
    return Column(
      children: [
        BubbleSpecialThree(
          text: aiController.chatHistory[index].humanMessage,
          color: const Color(0xFF1B97F3),
          tail: true,
          textStyle: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        // Text("Human Message: ${}"),
        const SizedBox(
          height: 5,
        ),
        BubbleSpecialThree(
          text: aiController.chatHistory[index].aiMessage,
          color: const Color(0xFFE8E8EE),
          tail: true,
          isSender: false,
        ),
        const SizedBox(
          height: 5,
        ),
        // Text("AI Message: ${}"),
      ],
    );
  }
}
