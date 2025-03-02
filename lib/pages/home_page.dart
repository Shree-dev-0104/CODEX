import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vs_code_app/components/my_drawer.dart';
import 'package:vs_code_app/database/database.dart';
import 'code_editor_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    //  If this is the first time creating an app, Then create default data
    if (_mybox.get("FILES") == null) {
      db.createInitialData();
    } else {
      // there already exists data
      db.loadData();
    }
    super.initState();
  }

  // REFERENCE THE HIVE BOX
  final _mybox = Hive.box('myBox');
  FilesDatabase db = FilesDatabase();

  TextEditingController fileName = TextEditingController();
  // Function to create a new file
  void _createNewFile() {
    showDialog(
      context: context,
      builder: (context) {
        return KeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                if (fileName.text.endsWith('.py') ||
                    fileName.text.endsWith('.java') || fileName.text.endsWith('.c')) {
                  Navigator.pop(context);
                  db.files.add({
                    "filename": fileName.text,
                    "content": ""
                  }); // Add new file
                  db.updateDatabase();
                  _openEditor(fileName.text);
                  fileName.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "Only filename of extention .py, .java, .c is possible")));
                }
              }
            }
          },
          child: AlertDialog(
            content: TextField(
              cursorColor: Theme.of(context).colorScheme.inversePrimary,
              controller: fileName,
              decoration: InputDecoration(
                  hintText: "Enter file name",
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  )),
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              MaterialButton(
                onPressed: () {
                  if (fileName.text.endsWith('.py') ||
                      fileName.text.endsWith('.java') || fileName.text.endsWith('.c')) {
                    Navigator.pop(context);
                    db.files.add({
                      "filename": fileName.text,
                      "content": ""
                    }); // Add new file
                    db.updateDatabase();
                    _openEditor(fileName.text);
                    fileName.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "Only filename of extention .py, .java, .c is possible")));
                  }
                },
                child: const Text("Save"),
              )
            ],
          ),
        );
      },
    );
  }

  // delete function
  void delete(int index) {
    db.files.removeAt(index);
    db.updateDatabase(); // ✅ Save changes to Hive
    setState(() {});
  }

  // Open editor for a specific file
  void _openEditor(String fileName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CodeEditorScreen(fileName: fileName),
      ),
    ).then((_) => setState(() {})); // Refresh home screen when returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("Your Files"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: db.files.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 300.0, right: 300.0, top: 25),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              tileColor: Theme.of(context).colorScheme.primary,
              leading: Text((index + 1).toString()),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                db.files[index]["filename"]!,
                style: const TextStyle(fontSize: 24),
              ),
              onTap: () => _openEditor(db.files[index]["filename"]!),
              trailing: IconButton(
                  onPressed: () {
                    // ADD a delete function
                    delete(index);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  )),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Create new file",
        onPressed: _createNewFile,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
