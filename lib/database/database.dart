import 'package:hive_flutter/hive_flutter.dart';

class FilesDatabase {


  List<dynamic> files = []; 

  final _myBox = Hive.box('myBox');

  
  void createInitialData() {
    files = [];
  }

  /// Loads the to-do list data from the Hive database.
  ///
  /// This method retrieves the data stored in the 'TODOLIST' key from the Hive box
  /// and assigns it to the [toDoList].
  void loadData() {
    files = _myBox.get("FILES");
  }

  void updateDatabase() {
    _myBox.put("FILES", files);
  }
}
