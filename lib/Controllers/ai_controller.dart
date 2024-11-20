import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robogpt/Models/chat_model.dart';
import 'package:get/get.dart';
import 'package:langchain/langchain.dart';
import 'package:robogpt/Services/chat_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class AiController extends GetxController{
  var isDark;
  var aiResponse = "".obs;
  var chatHistory = <ChatModel>[].obs;
  var humanHistory = <String>[].obs;
  static var memory = ConversationBufferMemory();
  var itemList = <String>[].obs;
  final stt.SpeechToText _speech = stt.SpeechToText();
  RxBool isListening = false.obs;
  RxString text = 'Press the button and start speaking'.obs;
  RxString errorMessage = ''.obs;
  RxBool isProcessing = false.obs;


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech recognition status: $status'),
        onError: (errorNotification) =>
            print('Speech recognition error: $errorNotification'),
      );
      if (available) {
        print('Speech recognition initialized successfully');
      } else {
        errorMessage.value = 'Speech recognition not available';
      }
    } catch (e) {
      errorMessage.value = 'Error initializing speech recognition: $e';
      print(errorMessage.value);
    }
  }

  void listen() async {
    if (!isListening.value) {
      try {
        if (await _speech.initialize()) {
          isListening.value = true;
          isProcessing.value = true;
          errorMessage.value = '';
          await _speech.listen(
            onResult: (result) {
              text.value = result.recognizedWords;
              if (result.finalResult) {
                isProcessing.value = false;
                Future.delayed(const Duration(seconds: 2), () {
                  if (!isProcessing.value) {
                    stopListening();
                  }
                });
              } else {
                isProcessing.value = true;
              }
            },
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 3),
            partialResults: true,
            onSoundLevelChange: (level) {
              print('Sound level: $level');
              isProcessing.value = true;
            },
            cancelOnError: true,
            listenMode: stt.ListenMode.confirmation,
          );
        }
      } catch (e) {
        stopListening();
        errorMessage.value = 'Error during speech recognition: $e';
        print(errorMessage.value);
      }
    } else {
      stopListening();
    }
  }

  void stopListening() async {
    isListening.value = false;
    isProcessing.value = false;
    _speech.stop();
    humanHistory.add(text.value);
    var newChat = await ChatService().getActions(text.value);
    var db = FirebaseFirestore.instance;
    List<String> actionArray = newChat.aiMessage.replaceAll('[', '').replaceAll('"]', '')
        .replaceAll(']', '').replaceAll('"', '')
        .split(', ');
    db.collection("ArmControl").doc("Control").update({"commands": actionArray});
    print(newChat.aiMessage);
    print(newChat.humanMessage);
    var newChat1 = await ChatService().chat(text.value, newChat.aiMessage);
    chatHistory.add(newChat1);
    db.collection("ArmControl").doc("Control").update({"commands": actionArray});
    print(chatHistory.length);
    print('Stopped listening');
  }
}