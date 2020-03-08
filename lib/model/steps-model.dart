import 'package:flutter/material.dart';

class StepModel {

  TextEditingController _controller;
  int _id;
  int _noteId;
  int _position;
  int _isDone;
  String _stepText;


  StepModel();

  StepModel.withId(this._id, this._noteId, this._position, this._isDone,
      this._stepText);

  StepModel.name(this._noteId, this._position, this._isDone,
      this._stepText);


  int get id => _id;

  set id(int value) {
    _id = value;
  }

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = new Map();
    map={
      "note_id" : _noteId,
      "step_text" : _stepText,
      "position" : _position,
      "is_done" : _isDone
    };

    if(_id!=null){
      map["id"]= _id;
    }

    return map;

  }

  StepModel fromMap(Map<String, dynamic> map) => new StepModel.withId(map["id"], map["note_id"], map["position"], map["is_done"], map["step_text"]);


  int get noteId => _noteId;

  set noteId(int value) {
    _noteId = value;
  }

  int get position => _position;

  set position(int value) {
    _position = value;
  }

  int get isDone => _isDone;

  set isDone(int value) {
    _isDone = value;
  }

  String get stepText => _stepText;

  set stepText(String value) {
    _stepText = value;
  }

  TextEditingController get controller => _controller;

  set controller(TextEditingController value) {
    _controller = value;
  }


}