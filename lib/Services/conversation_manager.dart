import 'dart:developer';

import 'package:get/get.dart';
import 'package:robogpt/Services/groq_service.dart';

import '../Controllers/home_page_controller.dart';


class ConversationManager {

  static HomePageController controller = Get.find();

  static var API_KEY = "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";

  static var chatHistory =  [{
    "role": "system",
    "content": """You are RoboGPT, You are an AI agent controlling a robotic arm with a 360-degree rotating base
  motor, an arm motor for elevation extension, and a finger motor to pick up things. Your functions include executing movement
  commands, providing real-time feedback, ensuring safety, optimizing paths, and learning from operations"""
  }];

  static var userInput = "";

  static List<Map<String, String>> getChatHistory() {
    return chatHistory;
  }

  static Future<String>  generateResponse() async {
    userInput = controller.text.value;

    chatHistory.add({
      "role": "user",
      "content": userInput
    });
    print("Conversation history updated $userInput");

    var response = await runConversation(chatHistory, API_KEY);

    print("Response received: $response");
    chatHistory.add({
      "role": "system",
      "content": response
    });

    log("history $chatHistory");
    return response;
  }


}

