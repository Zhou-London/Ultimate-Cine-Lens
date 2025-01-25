import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api.dart';

int totalCount = 0;
var structureDict = {};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Video Analyse Test',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
          useMaterial3: true,
        ),
        home: SelectPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final List<Map<String, dynamic>> items = [];
  final ImagePicker imagePicker = ImagePicker();

  void addNewItem() async {
    final imageFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null){
      final currentTime = DateTime.now().toLocal().toString().substring(0, 16);
      items.add({
      'scene': 1,
      'action': items.length + 1,
      'time': currentTime,
      'image': imageFile.path, // Path
      });

      var result = await transferImage(imageFile.path);
      // var structure = {
      //   'scene': result['scene'],
      //   'action': result['action'],
      //   'description': result['description'],
      //   'dramaticAction': {
      //       'gesture': result['dramaticAction']['Gesture'],
      //       'facialExpression': result['dramaticAction']['FacialExpression'],
      //       'movement': result['dramaticAction']['Movement'],
      //       'costume': result['dramaticAction']['Costume'],
      //   },
      //   'filming': {
      //       'shotType': result['filming']['shotType'],
      //       'shotAngleAndPosition': result['filming']['shotAngleAndPosition'],
      //       'cameraMovement': result['filming']['cameraMovement'],
      //   },
      //   'editing': {
      //       'transition': result['editing']['Transition']
      //   }
      // };
      structureDict[imageFile.path] = result;
      
      // structureDict[imageFile.path] = transferImage(imageFile.path);
    }
    totalCount += 1;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case 0:
        page = SelectPage();
        break;
      case 1:
        page = TestPage();
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return page;
  }
}

class SelectPage extends StatelessWidget {
  const SelectPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Select Image'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  if (appState.items.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TestPage()),
                    );
                  }
                },
                child: Text('Start Test'),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: appState.addNewItem)
            ]
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: appState.items.length,
              itemBuilder: (context, index) {
                final item = appState.items[index];
                if (item['image'] != null){
                  return ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => ImageViewPage(imageFile: item['image']))
                        );
                      },

                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(item['image'])),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    title: Text('Scene ${item['scene']} Action ${item['action']}'),
                    subtitle: Text('Time: ${item['time']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => InformationPage(imageFile: item['image']))
                          );
                        },
                        icon: Icon(Icons.info)),
                      ]
                    )
                  );
                } else {
                  return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey,
                    child: Center(child: Icon(Icons.image)),
                  ),
                  title: Text('Scene ${item['scene']} Action ${item['action']}'),
                  subtitle: Text('Time: ${item['time']}'),
                );
                }
              },
            )
          )
        ],
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int currentItem = 0;
  List<String> characters = ['a', 'b', 'c'];
  List<String> shotType = ['Extreme Long Shot', 'Long Shot', 'Full Shot', 'Medium Long Shot', 'Medium Shot', 'Medium Close-Up', 'Close-Up', 'Chocker', 'Extreme Close-Up', 'No'];
  List<String> shotAngleAndPosition = ['Low Angle', 'Eye Level', 'High Angle', 'Tilt', 'Over-the-Sholder Shot', 'Top Shot', 'No'];
  List<List<String>> dropdownValue = [];
  var answer = {'Shot Type': 'No', 'Shot Angle and Position': 'No'};

  @override
  void initState(){
    for (int i = 0; i < totalCount; i++){
      dropdownValue.add(['No', 'No']);
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    var textStyle = theme.textTheme.bodyMedium;
    String imagePath = appState.items[currentItem]['image'];
    Map currentStructure = structureDict[imagePath];
    answer['Shot Type'] = currentStructure['filming']['shotType'];
    answer['Shot Angle and Position'] = currentStructure['filming']['shotAngleAndPosition'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Test page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.file(
              File(appState.items[currentItem]['image']),
              fit: BoxFit.contain,
              height: MediaQuery.of(context).size.height * 0.8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Shot Type: ', style: textStyle),
                DropdownButton(
                  value: dropdownValue[currentItem][0],
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue[currentItem][0] = value!;
                      // print(dropdownValue);
                    });
                  },
                  items: shotType.map((String value){
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value, style: textStyle),
                    );
                  }).toList(),
                ),

                Text(' Shot Angle and Position: ', style: textStyle),
                DropdownButton(
                  value: dropdownValue[currentItem][1],
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue[currentItem][1] = value!;
                      // print(dropdownValue);
                    });
                  },
                  items: shotAngleAndPosition.map((String value){
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value, style: textStyle),
                    );
                  }).toList(), 
                ),

                ElevatedButton(onPressed: () {
                  setState(() {
                    if (dropdownValue[currentItem][0] == answer['Shot Type']) {
                    } else {
                      dropdownValue[currentItem][0] = answer['Shot Type']!;
                    }
                    if (dropdownValue[currentItem][1] == answer['Shot Angle and Position']) {
                    } else {
                      dropdownValue[currentItem][1] = answer['Shot Angle and Position']!;
                    }
                  });
                }, child: Text('Check')),

                ElevatedButton(onPressed: () {
                  setState(() {
                    if (currentItem != 0) {
                    currentItem -= 1;
                    }
                  });
                },
                child: Text('Previous')), 
                

                ElevatedButton(onPressed: () {
                  setState(() {
                    if (currentItem != appState.items.length - 1) {
                    currentItem += 1;
                    }
                  });
                }, 
                child: Text('Next'))
              ],
            )
          ]
        ),
      ),
    );
  }
}

class ImageViewPage extends StatelessWidget {
  final String imageFile;

  const ImageViewPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.file(File(imageFile)),
          )
        ),
      )
    );
  }
}

class InformationPage extends StatelessWidget {
  final String imageFile;

  const InformationPage({super.key, required this.imageFile});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          }, 
          icon: Icon(Icons.arrow_back_ios_new)),
        title: Text('Information'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Text(structureDict[imageFile].toString()),
    );
  }
}
