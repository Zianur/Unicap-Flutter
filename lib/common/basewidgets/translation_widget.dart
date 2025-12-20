import 'package:flutter/material.dart';
import 'package:flutter_searchable_dropdown/flutter_searchable_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/controllers/translator_controller.dart';

class TranslationWidget extends StatelessWidget {
  const TranslationWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<TranslatorController>(
        builder: (context, translatorProvider, __) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Language Selection
              _buildLanguageSelector(translatorProvider),
              SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Translation Input Area
                      _buildInputSection(context, translatorProvider),
                      SizedBox(height: 20),

                      // Translate Button
                      _buildTranslateButton(translatorProvider),
                      SizedBox(height: 20),

                      // Translation Output Area
                      _buildOutputSection(context, translatorProvider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildLanguageSelector(TranslatorController provider) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.translate, color: Colors.blue, size: 22),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    'Translate to',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),

                  SearchableDropdown<String>(
                    value: provider.selectedLanguage,
                    items: provider.supportedLanguages.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    hint: Text('Select language'),
                    searchHint: "Search language",
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    underline: SizedBox(), // Hides underline
                    onChanged: (value) {
                      if (value != null) {
                        provider.setSelectedLanguage(value);
                      }
                    },
                    dialogBox: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context, TranslatorController provider) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.text_fields, color: Colors.green, size: 20),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Input Text',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.green.shade800,
                    ),
                  ),
                  Spacer(),
                  if (provider.inputText.isNotEmpty)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.content_copy, size: 20),
                          onPressed: () => provider.copyToClipboard(
                            context,
                            provider.inputText,
                          ),
                          tooltip: 'Copy text',
                          color: Colors.green,
                        ),
                        IconButton(
                          icon: Icon(Icons.clear, size: 20),
                          onPressed: provider.clearText,
                          tooltip: 'Clear text',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Text Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 80),
                child: TextField(
                  controller: provider.inputController,
                  onChanged: provider.setInputText,
                  maxLines: null,
                  minLines: 3,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Enter text in any language...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslateButton(TranslatorController provider) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton(
          onPressed: provider.isTranslating || provider.inputText.isEmpty
              ? null
              : provider.translate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            disabledBackgroundColor: Colors.grey[400],
          ),
          child: provider.isTranslating
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Translating...',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.translate, size: 22),
              SizedBox(width: 10),
              Text(
                'TRANSLATE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutputSection(BuildContext context, TranslatorController provider) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.translate, color: Colors.purple, size: 20),
                  ),
                  SizedBox(width: 10),

                  Text(
                    'Translated Text',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.purple.shade800,
                    ),
                  ),
                  Spacer(),

                  if (provider.translatedText.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.content_copy, size: 20),
                      onPressed: () => provider.copyToClipboard(
                        context,
                        provider.translatedText,
                      ),
                      tooltip: 'Copy translation',
                      color: Colors.purple,
                    ),
                ],
              ),
            ),

            // Translation Output
            Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 80),
                child: SingleChildScrollView(
                  child: provider.translatedText.isNotEmpty
                      ? Text(
                    provider.translatedText,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  )
                      : Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.translate,
                          size: 40,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Translation will appear here',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}