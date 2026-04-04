class MyanmarLanguageFilter {
  // Combined list: Unicode, Zawgyi, and Burglish
  static const List<String> _forbidden = [
    // --- Burmese Script ---
    'မအေလိုး', 'မေအလိုး', 'စောက်ရူး', 'ေစာက္ရူး',
    'လိုး', 'လိုးမ', 'ခွေးမသား', 'ေခြးမသား', 
    'ဖာသည်', 'ဖာသည္', 'စောက်ရမ်း', 'ေစာက္ရမ္း', 'စောက်ဖတ်',

    // --- Burglish (English Letters) ---
    'mayloe', 'maeloe', 'ngaloe', 'ngalo', 'sapat', 
    'soephat', 'lee', 'lell', 'kunma', 'hpather'
  ];

  static bool containsProfanity(String input) {
    if (input.isEmpty) return false;

    // 1. Lowercase and remove punctuation/spaces
    String processed = input.toLowerCase().replaceAll(RegExp(r'[.\s\-_၊။]'), '');

    // 2. Handle "Leetspeak" (e.g., m4y l0e -> may loe)
    processed = processed
        .replaceAll('0', 'o')
        .replaceAll('4', 'a')
        .replaceAll('3', 'e')
        .replaceAll('1', 'i')
        .replaceAll('!', 'i');

    // 3. Check against the list
    for (var word in _forbidden) {
      if (processed.contains(word)) {
        return true;
      }
    }
    return false;
  }
}
