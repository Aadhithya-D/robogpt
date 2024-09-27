import 'package:get/get.dart';
import 'package:robogpt/Services/conversation_manager.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomePageController extends GetxController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  RxBool isListening = false.obs;
  RxString text = 'Press the button and start speaking'.obs;
  RxString robo_response = "".obs;
  RxString errorMessage = ''.obs;
  RxBool isProcessing = false.obs;
  RxList<Map<String,String>> chatHistory = [{"system":"Hello I am RoboGPT. How may I assist you?"}].obs;

  @override
  void onInit() {
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
    robo_response.value = await ConversationManager.generateResponse();
    chatHistory.value = ConversationManager.getChatHistory();
    print('Stopped listening');
  }
}
