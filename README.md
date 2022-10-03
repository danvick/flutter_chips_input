# flutter_chips_input

Flutter library for building input fields with InputChips as input options.

[![Pub Version](https://img.shields.io/pub/v/flutter_chips_input?style=for-the-badge)](https://pub.dev/packages/flutter_chips_input)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/danvick/flutter_chips_input/CI?style=for-the-badge)](https://github.com/danvick/flutter_chips_input/actions?query=workflow%3ACI)
[![Codecov](https://img.shields.io/codecov/c/github/danvick/flutter_chips_input?style=for-the-badge)](https://codecov.io/gh/danvick/flutter_chips_input/)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/danvick/flutter_chips_input?style=for-the-badge)](https://www.codefactor.io/repository/github/danvick/flutter_chips_input)

[![GitHub](https://img.shields.io/github/license/danvick/flutter_chips_input?style=for-the-badge)](https://github.com/danvick/flutter_chips_input/blob/master/LICENSE)
[![OSS Lifecycle](https://img.shields.io/osslifecycle/danvick/flutter_chips_input?style=for-the-badge)](#support)
[![Gitter](https://img.shields.io/gitter/room/danvick/flutter_form_builder?style=for-the-badge)](https://gitter.im/flutter_form_builder/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Usage

### Installation

Follow installation instructions [here](https://pub.dev/packages/flutter_chips_input/install)

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

- [x] Ability to limit the number of chips
- [x] Overlay doesn't move when input height changes i.e. when chips wrap
- [ ] Create a `FormField` implementation (`ChipsInputField`) to be used within Flutter Form Widget

## Known Issues

- Deleting chips with keyboard on IOS makes app to crush (Flutter Issue with special characters used as replacement characters). Already reported [#1](https://github.com/danvick/flutter_chips_input/issues/1)
- For some reason Overlay floats above AppBar when scrolling
