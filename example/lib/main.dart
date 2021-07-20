import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chips Input',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // brightness: Brightness.dark,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _chipKey = GlobalKey<ChipsInputState>();
  @override
  Widget build(BuildContext context) {
    const mockResults = <AppProfile>[
      AppProfile('John Doe', 'jdoe@flutter.io',
          'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
      AppProfile('Paul', 'paul@google.com',
          'https://mbtskoudsalg.com/images/person-stock-image-png.png'),
      AppProfile('Fred', 'fred@google.com',
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
      AppProfile('Brian', 'brian@flutter.io',
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
      AppProfile('John', 'john@flutter.io',
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
      AppProfile('Thomas', 'thomas@flutter.io',
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
      AppProfile('Nelly', 'nelly@flutter.io',
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
      AppProfile('Marie', 'marie@flutter.io',
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
      AppProfile('Charlie', 'charlie@flutter.io',
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
      AppProfile('Diana', 'diana@flutter.io',
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
      AppProfile('Ernie', 'ernie@flutter.io',
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
      AppProfile('Gina', 'fred@flutter.io',
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Chips Input Example'),
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(),
              TextField(),
              ChipsInput(
                key: _chipKey,
                suggestionBoxMargin: 16.0,
                suggestionBoxPosition: SuggestionBoxPosition.bottom,
                suggestionBoxDecoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                suggestionTileSeperator: const Divider(
                  color: Colors.black,
                  endIndent: 2,
                  height: 1,
                  indent: 0,
                ),
                /*initialValue: [
                  AppProfile('John Doe', 'jdoe@flutter.io',
                      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
                ],*/
                // autofocus: true,
                // allowChipEditing: true,
                keyboardAppearance: Brightness.dark,
                textCapitalization: TextCapitalization.words,
                enabled: true,
                maxChips: 5,
                textStyle: const TextStyle(
                    height: 1.5, fontFamily: 'Roboto', fontSize: 16),
                decoration: const InputDecoration(
                  // prefixIcon: Icon(Icons.search),
                  // hintText: formControl.hint,
                  labelText: 'Select People',
                  // enabled: false,
                  // errorText: field.errorText,
                ),
                findSuggestions: (String query) {
                  // print("Query: '$query'");
                  if (query.isNotEmpty) {
                    var lowercaseQuery = query.toLowerCase();
                    return mockResults.where((profile) {
                      return profile.name
                              .toLowerCase()
                              .contains(query.toLowerCase()) ||
                          profile.email
                              .toLowerCase()
                              .contains(query.toLowerCase());
                    }).toList(growable: false)
                      ..sort((a, b) => a.name
                          .toLowerCase()
                          .indexOf(lowercaseQuery)
                          .compareTo(
                              b.name.toLowerCase().indexOf(lowercaseQuery)));
                  }
                  // return <AppProfile>[];
                  return mockResults;
                },
                onChanged: (data) {
                  // print(data);
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
                  return InkWell(
                    onTap: () => state.selectSuggestion(profile),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 12),
                          Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              profile.name,
                              overflow: TextOverflow.ellipsis,
                              // style: lessgoTheme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  // return ListTile(
                  //   key: ObjectKey(profile),
                  //   leading: CircleAvatar(
                  //     backgroundImage: NetworkImage(profile.imageUrl),
                  //   ),
                  //   title: Text(profile.name),
                  //   subtitle: Text(profile.email),
                  //   onTap: () => state.selectSuggestion(profile),
                  // );
                },
              ),
              // TextField(),
              /*ChipsInput(
                initialValue: [
                  AppProfile('John Doe', 'jdoe@flutter.io',
                      'https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX4057996.jpg'),
                ],
                enabled: true,
                maxChips: 10,
                textStyle: TextStyle(height: 1.5, fontFamily: "Roboto", fontSize: 16),
                decoration: InputDecoration(
                  // prefixIcon: Icon(Icons.search),
                  // hintText: formControl.hint,
                  labelText: "Select People",
                  // enabled: false,
                  // errorText: field.errorText,
                ),
                findSuggestions: (String query) {
                  if (query.length != 0) {
                    var lowercaseQuery = query.toLowerCase();
                    return mockResults.where((profile) {
                      return profile.name
                          .toLowerCase()
                          .contains(query.toLowerCase()) ||
                          profile.email
                              .toLowerCase()
                              .contains(query.toLowerCase());
                    }).toList(growable: false)
                      ..sort((a, b) => a.name
                          .toLowerCase()
                          .indexOf(lowercaseQuery)
                          .compareTo(
                          b.name.toLowerCase().indexOf(lowercaseQuery)));
                  } else {
                    return mockResults;
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
              ),*/
              RaisedButton(
                child: Text('Add Chip'),
                onPressed: () {
                  _chipKey.currentState.selectSuggestion(AppProfile(
                      'Gina',
                      'fred@flutter.io',
                      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'));
                },
              ),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class AppProfile {
  final String name;
  final String email;
  final String imageUrl;

  const AppProfile(this.name, this.email, this.imageUrl);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppProfile &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return name;
  }
}
