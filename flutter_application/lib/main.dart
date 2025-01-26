import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api.dart';

int totalCount = 0;
var structureDict = {};

void main() => runApp(const MyApp());

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

//Clipper for Super Ellipse
class SuperellipseClipper extends CustomClipper<Path> {
  final double n;

  SuperellipseClipper({required this.n});
  
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;
    Path path = Path();

    for (double t = 0; t <= 2 * pi; t += 0.01) {
      double x = pow(cos(t).abs(), 2 / n) * (width / 2) * (cos(t) >= 0 ? 1: -1);
      double y = pow(sin(t).abs(), 2 / n) * height / 2 * (sin(t) >= 0 ? 1: -1);
      if(t == 0){
        path.moveTo(width / 2 + x, height / 2 + y);
      } else {
        path.lineTo(width / 2 + x, height / 2 + y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

//Initial Page
class SelectPage extends StatelessWidget {
  const SelectPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 80),
          //Title
          ClipPath(
            clipper: SuperellipseClipper(n: 6.0),
            child: Container(
              
              width: MediaQuery.of(context).size.width * 0.6,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.cyanAccent, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                  text: 'Very Cool Name',
                  style: TextStyle(
                    fontSize: 72,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '  v0.1',
                        style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ]
                ),
              )
            ),
          ),
          //Title End

          SizedBox(height: 40),

          //"Import Image" Button
          GestureDetector(
            onTap: appState.addNewItem,
            child: ClipPath(
              clipper: SuperellipseClipper(n: 4.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.cyan, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child:Text(
                  'Import',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  )
                )
              ),
            ),
          ),
          //"Import Image" Button End
          SizedBox(height: 10),
          //"Start Test" Button
          GestureDetector(
            onTap: (){
              if(appState.items.isNotEmpty){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TestPage()),
                );
              }
            },
            child: ClipPath(
              clipper: SuperellipseClipper(n: 4.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.cyan, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child:Text(
                  'Analyse',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  )
                )
              ),
            ),
          ),

          
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     IconButton.filledTonal(
          //       //icon: Icon(Icons.add),
          //       icon:Text("Import Photo"),
          //       onPressed: appState.addNewItem),
          //     ElevatedButton(
          //       onPressed: () {
          //         if (appState.items.isNotEmpty) {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(builder: (context) => const TestPage()),
          //           );
          //         }
          //       },
          //       child: Text('Run'),
          //     )
          //   ]
          // ),

          //Divider(),

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
  bool checkVisibiity = false;
  List<IconData> checkIcon = [Icons.clear, Icons.clear];
  List<Color> checkColor = [Colors.red, Colors.red];
  

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
                Visibility(
                  visible: checkVisibiity,
                  child: Icon(
                    checkIcon[0],
                    color: checkColor[0],
                    ),
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
                Visibility(
                  visible: checkVisibiity,
                  child: Icon(
                    checkIcon[1],
                    color: checkColor[1],
                    ),
                ),

                ElevatedButton(onPressed: () {
                  setState(() {
                    if (dropdownValue[currentItem][0] == answer['Shot Type']) {
                      checkIcon[0] = Icons.check;
                      checkColor[0] = Colors.green;
                    } else {
                      // dropdownValue[currentItem][0] = answer['Shot Type']!;
                      checkIcon[0] = Icons.clear;
                      checkColor[0] = Colors.red;
                    }
                    if (dropdownValue[currentItem][1] == answer['Shot Angle and Position']) {
                      checkIcon[1] = Icons.check;
                      checkColor[1] = Colors.green;
                    } else {
                      // dropdownValue[currentItem][1] = answer['Shot Angle and Position']!;
                      checkIcon[1] = Icons.clear;
                      checkColor[1] = Colors.red;
                    }
                    checkVisibiity = true;
                  });
                }, child: Text('Check')),

                ElevatedButton(onPressed: () {
                  setState(() {
                    if (currentItem != 0) {
                    currentItem -= 1;
                    checkVisibiity = false;
                    checkIcon = [Icons.clear, Icons.clear];
                    checkColor = [Colors.red, Colors.red];
                    }
                  });
                },
                child: Text('Previous')), 
                

                ElevatedButton(onPressed: () {
                  setState(() {
                    if (currentItem != appState.items.length - 1) {
                    currentItem += 1;
                    checkVisibiity = false;
                    checkIcon = [Icons.clear, Icons.clear];
                    checkColor = [Colors.red, Colors.red];
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
