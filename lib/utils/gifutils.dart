// gifutils.dart
class CharacterUtils {
  // A map of character to their respective GIFs
  static final Map<String, String> characterGifs = {
    'Boy': 'assets/gif/boy.gif',
    'Girl': 'assets/gif/girl.gif',
    'Robo': 'assets/gif/robo.gif',
    'Tiger': 'assets/gif/tiger.gif',
  };

  // Function to get GIF path for a given character
  static String? getCharacterGif(String character) {
    return characterGifs[character] ?? null; // Return null if not found
  }
}
