import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import '../model/single_player_quiz_model.dart';
import 'package:http/http.dart' as http;


class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<QuizModel>> fetchCsvFromStorage(String filename) async {
    try {
      final ref = _storage.ref().child(filename);
      final url = await ref.getDownloadURL();
      final response = await http.get(Uri.parse(url));
      final data = response.body;

      // Parse CSV and convert to QuizModel objects
      List<QuizModel> quizzes = _parseCsv(data);
      return quizzes;
    } catch (e) {
      print('Error fetching CSV from storage: $e');
      return [];
    }
  }

  List<QuizModel> _parseCsv(String csvData) {
    List<QuizModel> quizzes = [];
    List<String> rows = const LineSplitter().convert(csvData);
    for (var row in rows) {
      List<String> fields = row.split(',');
      if (fields.length >= 7) { // Ensure there are enough fields
        quizzes.add(QuizModel(
          question: fields[0],
          optionA: fields[1],
          optionB: fields[2],
          optionC: fields[3],
          optionD: fields[4],
          correctAnswer: fields[5],
          category: fields[6],
        ));
      }
    }
    return quizzes;
  }
}
