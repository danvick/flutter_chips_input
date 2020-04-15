# flutter_chips_input

Flutter library for building input fields with InputChips as input options.

## Usage

### Installation
Follow installation instructions [here](https://pub.dartlang.org/packages/flutter_chips_input#-installing-tab-)

### Import
```dart
import 'package:flutter_chips_input/flutter_chips_input.dart';
```

### Example
#### ChipsInput
```dart
ChipsInput(
    initialValue: [
        AppProfile('John Doe', 'jdoe@flutter.io', 'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg')
    ],
    decoration: InputDecoration(
        labelText: "Select People",
    ),
    maxChips: 3,
    findSuggestions: (String query) {
        if (query.length != 0) {
            var lowercaseQuery = query.toLowerCase();
            return mockResults.where((profile) {
                return profile.name.toLowerCase().contains(query.toLowerCase()) || profile.email.toLowerCase().contains(query.toLowerCase());
            }).toList(growable: false)
                ..sort((a, b) => a.name
                    .toLowerCase()
                    .indexOf(lowercaseQuery)
                    .compareTo(b.name.toLowerCase().indexOf(lowercaseQuery)));
        } else {
            return const <AppProfile>[];
        }
    },
    onChanged: (data) {
        print(data);
    },
    chipBuilder: (context, state, profile) {
        return InputChip(
            key: ObjectKey(profile),
            label: Text(profile.name),
            avatar: CircleAvatar(
                backgroundImage: NetworkImage(profile.imageUrl),
            ),
            onDeleted: () => state.deleteChip(profile),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
    },
    suggestionBuilder: (context, state, profile) {
        return ListTile(
            key: ObjectKey(profile),
            leading: CircleAvatar(
                backgroundImage: NetworkImage(profile.imageUrl),
            ),
            title: Text(profile.name),
            subtitle: Text(profile.email),
            onTap: () => state.selectSuggestion(profile),
        );
    },
)
```

## To-do list
- [X] Ability to limit the number of chips
- [X] Overlay doesn't move when input height changes i.e. when chips wrap
- [ ] Create a `FormField` implementation (`ChipsInputField`) to be used within Flutter Form Widget 

## Known Issues
* Deleting chips with keyboard on IOS makes app to crush (Flutter Issue with special characters used as replacement characters). Already reported [#1](https://github.com/danvick/flutter_chips_input/issues/1)
* For some reason Overlay floats above AppBar when scrolling
