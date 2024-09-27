import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;


const String MODEL = 'llama3-groq-70b-8192-tool-use-preview';
const String API_URL = 'https://api.groq.com/openai/v1/chat/completions';

String controlBaseMotor(String direction, int speed) {
  print("Moving base motor $direction at speed $speed");
  return "Moving base motor $direction at speed $speed";
}

String controlArmMotor(String direction, int speed) {
  print("Moving arm motor $direction at speed $speed");
  return "Moving arm motor $direction at speed $speed";
}

String controlFingerMotor(String action) {
  print("Performing finger motor action: $action");
  return "Performing finger motor action: $action";
}


Future<String> runConversation(List<Map<String, String>> messages, String apiKey) async {
  // Available tools and functions mapping

  var tools = [
    {
      "type": "function",
      "function": {
        "name": "control_base_motor",
        "description": "Control the base motor of the robotic arm with 360-degree rotation",
        "parameters": {
          "type": "object",
          "properties": {
            "direction": {"type": "string", "enum": ["left", "right"], "description": "Direction of movement"},
            "speed": {"type": "integer", "description": "Speed of movement"}
          },
          "required": ["direction", "speed"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "control_arm_motor",
        "description": "Control the arm motor of the robotic arm for elevation/extension",
        "parameters": {
          "type": "object",
          "properties": {
            "direction": {"type": "string", "enum": ["up", "down"], "description": "Direction of movement"},
            "speed": {"type": "integer", "description": "Speed of movement"}
          },
          "required": ["direction", "speed"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "control_finger_motor",
        "description": "Control the finger motor to pick up or release objects",
        "parameters": {
          "type": "object",
          "properties": {
            "action": {"type": "string", "enum": ["pick", "release"], "description": "Action to perform"}
          },
          "required": ["action"]
        }
      }
    }
  ];

  // Make initial API call to Groq's chat API
  log("making first api call");
  var response = await http.post(
    Uri.parse(API_URL),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'model': MODEL,
      'messages': messages,
      'tools': tools,
      'tool_choice': 'auto',
      'max_tokens': 4096
    }),
  );

  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    var responseMessage = responseBody['choices'][0]['message'];
    log("First response $responseMessage");
    var toolCalls = responseMessage['tool_calls'];

    // Process tool calls if any
    if (toolCalls != null) {
      var availableFunctions = {
        "control_base_motor": controlBaseMotor,
        "control_arm_motor": controlArmMotor,
        "control_finger_motor": controlFingerMotor,
      };

      for (var toolCall in toolCalls) {
        var functionName = toolCall['function']['name'];
        var functionToCall = availableFunctions[functionName];
        var functionArgs = jsonDecode(toolCall['function']['arguments']);

        // Execute the function and capture the result
        var functionResponse;
        if (functionName != "control_finger_motor"){
          functionResponse = functionToCall!(functionArgs['direction'], functionArgs['speed']);
        } else {
          functionResponse = functionToCall!(functionArgs['action']);
        }


        // Add the function response to messages
        // messages.add({
        //   'tool_call_id': toolCall['id'],
        //   'role': 'tool',
        //   'name': functionName,
        //   'content': functionResponse,
        // });
      }

      // Make a second API call with updated messages
      log("making second api call");

      var secondResponse = await http.post(
        Uri.parse(API_URL),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': MODEL,
          'messages': messages
        }),
      );

      if (secondResponse.statusCode == 200) {
        var secondResponseBody = jsonDecode(secondResponse.body);
        return secondResponseBody['choices'][0]['message']['content'];
      } else {
        throw Exception('Error processing second API response: ${secondResponse.statusCode}');
      }
    }

    var secondResponse = responseMessage["content"];

    log("Second response: $secondResponse");

    return responseMessage['content'];
  } else {
    throw Exception('Error processing initial API response: ${response.statusCode}');
  }
}

