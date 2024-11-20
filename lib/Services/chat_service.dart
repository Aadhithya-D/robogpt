import 'package:robogpt/Models/chat_model.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../Controllers/ai_controller.dart';


class ChatService {
  final AiController aiController = Get.put(AiController());


  Future<ChatModel> chat(String humanMessage, String actionList) async {

    var prompt = """You are RoboGPT. You are a robotic arm. 
    Start the response with a message like "Sure, I will do it". Write a response to the given human task specifying the actions the arm has to perform.
    DONOT USE MARKDOWN CODE.
    Action List: $actionList
    Human Task: $humanMessage""";


    final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: "AIzaSyDyCwPE3Xn9oAyqbYc9U9uU3N8MvYop7fw");

    var response = await model.generateContent([Content.text(prompt)]);
    ChatModel newChat = ChatModel(humanMessage: humanMessage, aiMessage: response.text?.trim() ?? "", timeStamp: DateTime.now().millisecondsSinceEpoch);
    return newChat;
  }


  Future<ChatModel> getActions(String humanMessage) async {
    final schema = Schema.array(
        description: 'List of actions',
        items: Schema.string());

    var prompt = """You are an expert at forming a list of sequences of movements for a robotic arm FORM A LIST OF ACTIONS FOR THE ROBOTIC ARM FROM THE TASK PROVIDED AND THE BELOW ACTIONS
    ACTIONS_FOR_ARM = ["up", "down", "left", "right", "front", "back", "pick", "drop", "reset"]
    // THESE ARE THE ONLY ACTIONS THAT THE ARM IS CAPABLE OF PERFORMING. DOT NOT SUGGEST ANY OTHER ACTION.
    Task: $humanMessage""";


    final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: "AIzaSyDyCwPE3Xn9oAyqbYc9U9uU3N8MvYop7fw",
        generationConfig: GenerationConfig(
            responseMimeType: 'application/json', responseSchema: schema));

    var response = await model.generateContent([Content.text(prompt)]);

    ChatModel newChat = ChatModel(humanMessage: humanMessage, aiMessage: response.text ?? "", timeStamp: DateTime.now().millisecondsSinceEpoch);
    return newChat;
  }
}
