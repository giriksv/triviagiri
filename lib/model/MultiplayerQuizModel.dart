import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:csv/csv.dart';
import 'dart:convert';

class MultiplayerQuizModel {
  Future<List<Map<String, dynamic>>> fetchQuestionsFromCSV() async {
    String filePath = 'quizcsvfirestorage.csv'; // CSV file path in Firebase Storage

    try {
      final ref = FirebaseStorage.instance.ref().child(filePath);
      final String csvData = await ref.getData().then((bytes) => utf8.decode(bytes!));

      final List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);
      List<Map<String, dynamic>> questions = [];

      for (var row in csvTable) {
        questions.add({
          'question': row[0],
          'optionA': row[1],
          'optionB': row[2],
          'optionC': row[3],
          'optionD': row[4],
          'correctAnswer': row[5],
        });
      }
      questions.shuffle();
      return questions.take(5).toList();
    } catch (e) {
      print('Error fetching or parsing CSV: $e');
      return [];
    }
  }

  Future<void> updateUserPoints(String userEmail) async {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userEmail);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userDocRef);

        if (!userDoc.exists) {
          transaction.set(userDocRef, {
            'points': 5, // Start with 5 points as the initial value
            'email': userEmail,
          });
        } else {
          int currentPoints = (userDoc['points'] is int)
              ? userDoc['points']
              : int.tryParse(userDoc['points'].toString()) ?? 0;

          transaction.update(userDocRef, {'points': currentPoints + 5});
        }
      });
    } catch (error) {
      print("Error updating user points: $error");
    }
  }

  Future<void> updateRoomPoints(String roomId, String userEmail) async {
    final roomDocRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot roomDoc = await transaction.get(roomDocRef);

        if (roomDoc.exists) {
          List<dynamic> users = roomDoc['users'];
          bool userFound = false;

          for (int i = 0; i < users.length; i++) {
            if (users[i]['email'] == userEmail) {
              userFound = true;
              int currentPoints = (users[i]['roomPoints'] is int)
                  ? users[i]['roomPoints']
                  : int.tryParse(users[i]['roomPoints'].toString()) ?? 0;

              users[i]['roomPoints'] = currentPoints + 5;
              break;
            }
          }

          if (userFound) {
            transaction.update(roomDocRef, {'users': users});
          }
        }
      });
    } catch (error) {
      print("Error updating room points: $error");
    }
  }
}
