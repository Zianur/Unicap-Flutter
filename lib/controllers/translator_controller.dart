import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:translator_plus/translator_plus.dart';

class TranslatorController with ChangeNotifier {

  TranslatorController();

  String _selectedLanguage = 'es';
  String _inputText = '';
  String _translatedText = '';
  bool _isTranslating = false;
  final TextEditingController inputController = TextEditingController();


  final Map<String, String> _supportedLanguages = {
    'af': 'Afrikaans',
    'sq': 'Albanian',
    'am': 'Amharic',
    'ar': 'Arabic',
    'hy': 'Armenian',
    'az': 'Azerbaijani',
    'eu': 'Basque',
    'be': 'Belarusian',
    'bn': 'Bengali',
    'bs': 'Bosnian',
    'bg': 'Bulgarian',
    'ca': 'Catalan',
    'ceb': 'Cebuano',
    'ny': 'Chichewa',
    'zh-cn': 'Chinese (Simplified)',
    'zh-tw': 'Chinese (Traditional)',
    'co': 'Corsican',
    'hr': 'Croatian',
    'cs': 'Czech',
    'da': 'Danish',
    'nl': 'Dutch',
    'en': 'English',
    'eo': 'Esperanto',
    'et': 'Estonian',
    'tl': 'Filipino',
    'fi': 'Finnish',
    'fr': 'French',
    'fy': 'Frisian',
    'gl': 'Galician',
    'ka': 'Georgian',
    'de': 'German',
    'el': 'Greek',
    'gu': 'Gujarati',
    'ht': 'Haitian Creole',
    'ha': 'Hausa',
    'haw': 'Hawaiian',
    'he': 'Hebrew',
    'hi': 'Hindi',
    'hmn': 'Hmong',
    'hu': 'Hungarian',
    'is': 'Icelandic',
    'ig': 'Igbo',
    'id': 'Indonesian',
    'ga': 'Irish',
    'it': 'Italian',
    'ja': 'Japanese',
    'jw': 'Javanese',
    'kn': 'Kannada',
    'kk': 'Kazakh',
    'km': 'Khmer',
    'ko': 'Korean',
    'ku': 'Kurdish (Kurmanji)',
    'ky': 'Kyrgyz',
    'lo': 'Lao',
    'la': 'Latin',
    'lv': 'Latvian',
    'lt': 'Lithuanian',
    'lb': 'Luxembourgish',
    'mk': 'Macedonian',
    'mg': 'Malagasy',
    'ms': 'Malay',
    'ml': 'Malayalam',
    'mt': 'Maltese',
    'mi': 'Maori',
    'mr': 'Marathi',
    'mn': 'Mongolian',
    'my': 'Myanmar (Burmese)',
    'ne': 'Nepali',
    'no': 'Norwegian',
    'ps': 'Pashto',
    'fa': 'Persian',
    'pl': 'Polish',
    'pt': 'Portuguese',
    'pa': 'Punjabi',
    'ro': 'Romanian',
    'ru': 'Russian',
    'sm': 'Samoan',
    'gd': 'Scots Gaelic',
    'sr': 'Serbian',
    'st': 'Sesotho',
    'sn': 'Shona',
    'sd': 'Sindhi',
    'si': 'Sinhala',
    'sk': 'Slovak',
    'sl': 'Slovenian',
    'so': 'Somali',
    'es': 'Spanish',
    'su': 'Sundanese',
    'sw': 'Swahili',
    'sv': 'Swedish',
    'tg': 'Tajik',
    'ta': 'Tamil',
    'te': 'Telugu',
    'th': 'Thai',
    'tr': 'Turkish',
    'uk': 'Ukrainian',
    'ur': 'Urdu',
    'uz': 'Uzbek',
    'vi': 'Vietnamese',
    'cy': 'Welsh',
    'xh': 'Xhosa',
    'yi': 'Yiddish',
    'yo': 'Yoruba',
    'zu': 'Zulu',
  };

  String get selectedLanguage => _selectedLanguage;
  String get inputText => _inputText;
  String get translatedText => _translatedText;
  bool get isTranslating => _isTranslating;
  Map<String, String> get supportedLanguages => _supportedLanguages;

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }


  void setInputText(String text, {bool isNotify = true}) {
    _inputText = text;
    if(isNotify){
      notifyListeners();
    }
  }

  void setSelectedLanguage(String languageCode) {
    _selectedLanguage = languageCode;
    notifyListeners();
  }

  Future<void> translate() async {
    if (_inputText.trim().isEmpty) return;

    _isTranslating = true;
    notifyListeners();

    try {
      final translator = GoogleTranslator();

      // Perform translation
      final translation = await translator.translate(
        _inputText,
        to: _selectedLanguage,
      );

      _translatedText = translation.text;
    } catch (e) {
      _translatedText = 'Translation failed: $e';
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }


  void copyToClipboard(BuildContext context, String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  void clearText({bool isNotify = true}) {
    inputController.clear();
    _inputText = '';
    _translatedText = '';
    if(isNotify){
      notifyListeners();
    }
  }
}