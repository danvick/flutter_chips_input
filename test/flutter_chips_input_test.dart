import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';

void main() {
  const allContacts = [
    'John Doe',
    'Jane Doe',
    'John Smith',
    'Jane Smith',
  ];

  testWidgets('ChipsInput', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChipsInput<String>(
            initialValue: allContacts.sublist(1, 3),
            maxChips: 3,
            findSuggestions: (String query) => query.isNotEmpty
                ? allContacts
                    .where((_) => _.toLowerCase().contains(query.toLowerCase()))
                    .toList()
                : const [],
            onChanged: (contacts) {
              debugPrint(contacts.toString());
            },
            chipBuilder: (context, state, contact) {
              return InputChip(
                key: ValueKey(contact),
                label: Text(contact),
                onDeleted: () => state.deleteChip(contact),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            },
            suggestionBuilder: (context, state, contact) {
              return ListTile(
                key: ValueKey(contact),
                title: Text(contact),
                onTap: () => state.selectSuggestion(contact),
              );
            },
          ),
        ),
      ),
    );
  });
}
