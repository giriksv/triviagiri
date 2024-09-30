import 'dart:ui';

import '../multi_player_model/MultiplayerQuizModel.dart';

class MultiplayerQuizController {
  final MultiplayerQuizModel model = MultiplayerQuizModel();

  Future<List<Map<String, dynamic>>> loadQuestions() async {
    return await model.fetchQuestionsFromCSV();
  }

  void submitAnswer({
    required String selectedAnswer,
    required String correctAnswer,
    required VoidCallback onCorrect,
    required VoidCallback onIncorrect,
  }) {
    if (selectedAnswer == correctAnswer) {
      onCorrect();
    } else {
      onIncorrect();
    }
  }

  Future<void> updateUserPoints(String userEmail) async {
    await model.updateUserPoints(userEmail);
  }

  Future<void> updateRoomPoints(String roomId, String userEmail) async {
    await model.updateRoomPoints(roomId, userEmail);
  }
}
