import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../model/single_player_quiz_model.dart';
import '../services/local_db_service.dart';

class AllDBController {
  final LocalDatabaseService _dbService = LocalDatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if the user already exists in Firestore
  Future<bool> userExists(String email) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(email).get();
      return doc.exists;
    } catch (e) {
      print("Error checking user existence: $e");
      return false;
    }
  }

  // Insert or update user data
  Future<void> insertUserData(UserModel user) async {
    try {
      bool exists = await userExists(user.email);
      int pointsToInsert = exists ? (user.points ?? 0) : 50; // Insert 100 points if user doesn't exist

      await _firestore.collection('users').doc(user.email).set({
        'selectedCharacter': user.character,
        'email': user.email,
        'name': user.name, // Store the exact user name
        'points': FieldValue.increment(pointsToInsert), // Increment points for new users
        'categoryPoints': user.categoryPoints ?? {},
      }, SetOptions(merge: true));

      print("User data inserted/updated for: ${user.email}");
    } catch (e) {
      print("Error inserting user data: $e");
      rethrow; // Optionally rethrow to handle it upstream
    }
  }

  // Fetch quizzes by category from local database
  Future<List<QuizModel>> getQuizzesByCategory(String category) async {
    return await _dbService.getQuizzesByCategory(category);
  }

  // Add points for a specific category
  Future<void> addPoints(String email, int points, String category) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(email);

      await userDoc.set({
        'points': FieldValue.increment(points), // Increment total points
        'categoryPoints.$category': FieldValue.increment(points), // Increment points by category
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error adding points: $e");
      rethrow;
    }
  }

  // Clear and recreate local quiz database
  Future<void> clearAndCreateDb(List<QuizModel> quizzes) async {
    await _dbService.clearAndCreateDb(quizzes);
  }

  // Update user timestamp in Firestore
  Future<void> updateUserTimestamp(String email) async {
    try {
      await _firestore.collection('users').doc(email).update({
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating user timestamp: $e");
    }
  }

  // Get the current question index for a category
  Future<int> getCurrentQuestionIndex(String email, String category) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(email).get();
      if (userDoc.exists) {
        return (userDoc.get('${category}QuizId') ?? 0) as int;
      } else {
        return 0;
      }
    } catch (e) {
      print("Error getting current question index: $e");
      return 0;
    }
  }

  // Set the current question index for a category
  Future<void> setCurrentQuestionIndex(String email, String category, int index) async {
    try {
      await _firestore.collection('users').doc(email).set({
        '${category}QuizId': index,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error setting current question index: $e");
      rethrow;
    }
  }
}
