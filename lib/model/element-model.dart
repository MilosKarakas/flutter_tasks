
class TodoElement {

  int _type = 0;
  String _header = '';
  String _details = '';
  DateTime _timestamp;
  DateTime _edited;
  int _id;
  int _stepsCount;
  int _stepsDone;
  int _manuallyMoved = 0;

  TodoElement();

  TodoElement.name(this._type, this._details, this._header, this._timestamp, this._edited, this._stepsCount, this._stepsDone, this._manuallyMoved);

  TodoElement.withId(this._id, this._type, this._details, this._header, this._timestamp, this._edited, this._stepsDone, this._stepsCount, this._manuallyMoved);

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = new Map();
    map = {
      "type":_type,
      "header":_header,
      "details":_details,
      "created":_timestamp.millisecondsSinceEpoch,
      "edited":_edited.millisecondsSinceEpoch,
      "steps_count" : _stepsCount,
      "steps_done" : _stepsDone,
      "manually_moved" : _manuallyMoved,
    };

    if(_id!=null)
      map["id"]=_id;

    return map;

  }

  TodoElement fromMap(Map<String, dynamic> map) =>
  new TodoElement.withId(map["id"], map["type"], map["details"], map["header"], DateTime.fromMillisecondsSinceEpoch(map["created"]), DateTime.fromMillisecondsSinceEpoch(map["edited"]), map["steps_done"], map["steps_count"], map["manually_moved"]);

  int get type => _type;

  set type(int value) {
    _type = value;
  }

  String get header => _header;

  DateTime get timestamp => _timestamp;

  set timestamp(DateTime value) {
    _timestamp = value;
  }

  String get details => _details;

  set details(String value) {
    _details = value;
  }

  set header(String value) {
    _header = value;
  }

  DateTime get edited => _edited;

  set edited(DateTime value) {
    _edited = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  int get stepsDone => _stepsDone;

  set stepsDone(int value) {
    _stepsDone = value;
  }

  int get stepsCount => _stepsCount;

  set stepsCount(int value) {
    _stepsCount = value;
  }

  int get manuallyMoved => _manuallyMoved;

  set manuallyMoved(int value) {
    _manuallyMoved = value;
  }


}