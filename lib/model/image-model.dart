

class ImageModel {

  String url;
  int elementId;

  String get _url => url;

  set _url(String value) {
    url = value;
  }

  int get _elementId => elementId;

  set _elementId(int value) {
    elementId = value;
  }

  ImageModel({this.url, this.elementId});

  ImageModel.withUrl({String url}){
    url = url;
  }

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = new Map();
    map = {
      "url":url
    };

    return map;

  }

  ImageModel fromMap(Map<String, dynamic> map){
    return new ImageModel.withUrl(url:map["url"]);
  }

}