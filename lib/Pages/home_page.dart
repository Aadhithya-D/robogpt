
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../Components/message_buble.dart';
import '../Controllers/home_page_controller.dart';

class HomePage extends StatelessWidget {
  final HomePageController controller = Get.put(HomePageController());

  HomePage({super.key});




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoboGPT'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() => AvatarGlow(
        animate: controller.isListening.value,
        glowColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          onPressed: controller.listen,
          child: Icon(controller.isListening.value ? Icons.mic : Icons.mic_none),
        ),
      )),
      body: Obx(()=> ListView.builder(
          itemCount: controller.chatHistory.length,
          itemBuilder: (context, index) {
            final message = controller.chatHistory[index];
            return MessageBubble(
              content: message['content']!,
              isUser: message['role'] == 'user',
            );
          },
        ),
      )
    );
  }
}