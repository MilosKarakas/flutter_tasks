import 'package:flutter_tasks/model/element-model.dart';
import 'package:flutter_tasks/model/steps-model.dart';
import 'package:path/path.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_tasks/model/image-model.dart';

class DBhelper {

  static DBhelper _databaseHelper;
  static Database _database;

  final String databaseName = "notes.db";

  //tabela zadataka i biljeski
  final String tableName = "notes";
  final String colId = "id";
  final String colHeader = "header";
  final String colDetails = "details";
  final String colCreated = "created";
  final String colEdited=  "edited";
  final String colType = "type";
  final String colStepsCount = "steps_count";
  final String colStepsDone = "steps_done";
  final String colManuallyMoved = "manually_moved";

  //tabela koraka
  final String tableStepsName = "steps";
  final String colStepsId = "id";
  final String colStepsNoteId = "note_id";
  final String colStepsTaskText = "step_text";
  final String colStepsPosition = "position";
  final String colStepsIsDone = "is_done";

  //tabela tema
  final String tableThemeName = "theme";
  final String colThemeId = "id";
  final String colThemeValue = "value";

  //tabela slika
  final String tableImagesName = "images";
  final String colImagesId = "id";
  final String colImageUrl = "url";
  final String colImageElementId = "elementId";

  DBhelper._createInstance();

  factory DBhelper(){

    if(_databaseHelper==null)
      _databaseHelper = DBhelper._createInstance();

    return _databaseHelper;
  }

  Future<Database> initializeDatabase() async {

    io.Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path,databaseName);
    var notes = await openDatabase(path, version: 1, onCreate: _createDb);

    return notes;
  }

  Future<Database> get database async{

    if(_database==null)
      _database = await initializeDatabase();

    return _database;
  }

  _createDb(Database database, int databaseId) async {

    await database.execute("CREATE TABLE $tableName ($colId INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$colHeader TEXT,"
        "$colDetails TEXT,"
        "$colType INTEGER,"
        "$colCreated INTEGER,"
        "$colEdited INTEGER,"
        "$colStepsCount INTEGER,"
        "$colStepsDone INTEGER,"
        "$colManuallyMoved INTEGER)");

    await database.execute("CREATE TABLE $tableStepsName ($colStepsId INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$colStepsNoteId INTEGER,"
        "$colStepsTaskText TEXT,"
        "$colStepsPosition INTEGER,"
        "$colStepsIsDone INTEGER)");

    await database.execute("CREATE TABLE $tableThemeName ($colThemeId INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$colThemeValue INTEGER)");

    await database.execute("CREATE TABLE $tableImagesName ($colImagesId INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$colImageUrl TEXT, $colImageElementId INTEGER)");

  }

  Future<List<String>> getImagesForTodoElement(int elementId) async{

    List<String> urls = [];
    Database database = await this.database;
    var result = await database.rawQuery("SELECT $colImageUrl FROM $tableImagesName WHERE $colImageElementId=$elementId");
    dynamic rez;

    for(Map<String, dynamic> map in result) {
      rez = map["$colImageUrl"];
      urls.add(rez);
    }

    print("Retrieving images for id=$elementId , there are ${urls.length}.");

    return urls;

  }

  void insertElementImage(ImageModel imageModel) async{

    Database database = await this.database;
    await database.rawInsert("INSERT INTO $tableImagesName ("
        "$colImageUrl, $colImageElementId) VALUES ('${imageModel.url}',"
        "${imageModel.elementId})");

    print("Image ${imageModel.url} for ${imageModel.elementId} added.");

  }

  void removeElementImage(ImageModel imageModel) async{

    Database database = await this.database;
    await database.rawDelete("DELETE FROM $tableImagesName WHERE $colImageElementId=${imageModel.elementId}");

  }

  void removeElementImageByUrl(ImageModel imageModel) async{

    Database database = await this.database;
    await database.rawDelete("DELETE FROM $tableImagesName WHERE $colImageUrl='${imageModel.url}'");

  }

  void updateElementImage(ImageModel imageModel) async{

    Database database = await this.database;
    await database.rawUpdate("UPDATE $tableImagesName SET ("
        "$colImageUrl='${imageModel.url})' WHERE $colImageElementId=${imageModel.elementId}");

  }

  Future<dynamic> getTheme() async{

    Database database = await this.database;
    var result = await database.rawQuery("SELECT $colThemeValue FROM $tableThemeName ORDER BY $colThemeValue LIMIT 1");
    dynamic rez;

    for(Map<String, dynamic> map in result)
      rez = map["$colThemeValue"];

    return rez;

  }

  void setTheme(int theme) async{

    Database database = await this.database;
    database.rawUpdate("UPDATE $tableThemeName SET "
        "$colThemeValue=$theme");

    print("set db func theme to $theme");

  }

  void initializeTheme() async{

    Database database = await this.database;
    database.rawInsert("INSERT INTO $tableThemeName ("
        "$colThemeValue) VALUES (1)");

    setTheme(1);

  }

  Future<List<Map<String,dynamic>>> getSteps({final int id}) async{

    Database database = await this.database;
    var result = database.rawQuery("SELECT * FROM $tableStepsName WHERE $colStepsNoteId = $id ORDER BY $colStepsPosition ASC");

    return result;

  }

  Future<List<Map<String,dynamic>>> getElements() async{

    Database database = await this.database;
    var result = database.rawQuery("SELECT * FROM $tableName ORDER BY $colEdited ASC");

    return result;

  }

  Future<int> insertStep(final StepModel step) async{

    Database database = await this.database;
    var result = database.rawInsert("INSERT INTO $tableStepsName ("
        "$colStepsNoteId, $colStepsTaskText, $colStepsPosition, $colStepsIsDone) VALUES ( "
        "${step.noteId}, \'${step.stepText}\', ${step.position}, ${step.isDone})");

    return result;

  }

  Future<int> insertElement(final TodoElement element) async{

    Database database = await this.database;
    var result = database.rawInsert("INSERT INTO $tableName ("
        "$colHeader, $colDetails, $colType, $colCreated, $colEdited, $colStepsCount, $colStepsDone, $colManuallyMoved) VALUES ( "
        "\'${element.header}\', \'${element.details}\', ${element.type}, ${element.timestamp.millisecondsSinceEpoch}, ${element.edited.millisecondsSinceEpoch}, ${element.stepsCount}, ${element.stepsDone}, ${element.manuallyMoved})");

    return result;

  }

  Future<int> updateStep(final StepModel step) async{

    Database database = await this.database;
    var result = database.rawUpdate("UPDATE $tableStepsName SET "
        "$colStepsNoteId=${step.noteId}, "
        "$colStepsTaskText=\'${step.stepText}\', "
        "$colStepsPosition=${step.position}, "
        "$colStepsIsDone=${step.isDone} WHERE $colStepsId=${step.id}");

    return result;

  }

  Future<int> updateElement(final TodoElement element) async{

    Database database = await this.database;
    var result = database.rawUpdate("UPDATE $tableName SET "
        "$colHeader=\'${element.header}\', "
        "$colDetails=\'${element.details}\', "
        "$colType=${element.type}, "
        "$colCreated=${element.timestamp.millisecondsSinceEpoch}, "
        "$colEdited=${element.edited.millisecondsSinceEpoch},"
        "$colStepsCount=${element.stepsCount},"
        "$colStepsDone=${element.stepsDone},"
        "$colManuallyMoved=${element.manuallyMoved} WHERE $colId=${element.id}");

    return result;

  }

  Future<int> deleteStep(final StepModel step) async{

    Database database = await this.database;
    var result = database.rawDelete("DELETE FROM $tableStepsName WHERE $colStepsId=${step.id}");

    return result;

  }

  Future<int> deleteElement(final TodoElement element) async{

    Database database = await this.database;
    var result = database.rawDelete("DELETE FROM $tableName WHERE $colId=${element.id}");

    return result;

  }

  Future<List<Map<String, dynamic>>> getStepsMapByElementId(final int noteId) async{

    Database database = await this.database;
    var result = database.rawQuery("SELECT * FROM $tableStepsName WHERE $colStepsNoteId=$noteId ORDER BY $colStepsPosition ASC");

    return result;

  }

  Future<List<StepModel>> getStepsByElementId(final int noteId) async{

    List<StepModel> steps = new List();
    List<Map<String, dynamic>> maps = await getStepsMapByElementId(noteId);

    for(Map<String, dynamic> map in maps){
      steps.add(new StepModel().fromMap(map));
    }

    return steps;

  }

  Future<List<Map<String, dynamic>>> getElementsMapByType(final int type) async{

    Database database = await this.database;
    var result = database.rawQuery("SELECT * FROM $tableName WHERE $colType=$type ORDER BY $colEdited DESC");

    return result;

  }

  Future<List<TodoElement>> getElementsByType(final int type)async{

    List<TodoElement> elements = List();
    List<Map<String, dynamic>> maps = await getElementsMapByType(type);

    for(Map<String, dynamic> map in maps){
      elements.add(new TodoElement().fromMap(map));
    }

    return elements;

  }

  Future<List<Map<String, dynamic>>> getMostImportantElementsMapByType(final int type) async{

    Database database = await this.database;
    var result = database.rawQuery("SELECT * FROM $tableName WHERE $colType=$type ORDER BY $colEdited DESC LIMIT 1");

    return result;

  }

  Future<List<TodoElement>> getMostImportantElementsByType(final int type) async{

    List<TodoElement> elements = [];
    List<Map<String, dynamic>> maps = await getMostImportantElementsMapByType(type);

    for(Map<String, dynamic> map in maps){
      elements.add(new TodoElement().fromMap(map));
    }

    return elements;

  }

  Future<List<Map<String, dynamic>>> getMostImportantNotesMapByType(final int type) async{

    Database database = await this.database;
    var result = database.rawQuery("SELECT * FROM $tableName WHERE $colType=$type ORDER BY $colEdited DESC LIMIT 5");

    return result;

  }

  Future<List<TodoElement>> getMostImportantNotesByType(final int type) async{

    List<TodoElement> elements = [];
    List<Map<String, dynamic>> maps = await getMostImportantNotesMapByType(type);

    for(Map<String, dynamic> map in maps){
      elements.add(new TodoElement().fromMap(map));
    }

    return elements;

  }

  refreshStepsPositions(final int position,final  int id) async{

    Database database = await this.database;
    database.rawUpdate("UPDATE $tableStepsName SET $colStepsPosition = $colStepsPosition-1 WHERE $colStepsPosition>=$position AND $colStepsNoteId=$id");

  }

  incrementStepCount(final TodoElement element) async{

    Database database = await this.database;
    database.rawUpdate("UPDATE $tableName SET $colStepsCount=$colStepsCount+1 WHERE $colId=${element.id}");

  }

  decrementStepCount(final TodoElement element) async{

    Database database = await this.database;
    database.rawUpdate("UPDATE $tableName SET $colStepsCount=$colStepsCount-1 WHERE $colId=${element.id}");

  }

  incrementStepsDoneCount(final TodoElement element) async{

    Database database = await this.database;
    database.rawUpdate("UPDATE $tableName SET $colStepsDone=$colStepsDone+1 WHERE $colId=${element.id}");

  }

  decrementStepsDoneCount(final TodoElement element) async{

    Database database = await this.database;
    database.rawUpdate("UPDATE $tableName SET $colStepsDone=$colStepsDone-1 WHERE $colId=${element.id}");

  }

}