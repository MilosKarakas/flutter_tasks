import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tasks/model/element-model.dart';
import 'package:flutter_tasks/model/steps-model.dart';
import 'package:flutter_tasks/list.dart';
import 'package:flutter_tasks/sql/database.dart';
import 'utils/funcs.dart';
import 'package:flutter_tasks/utils/const.dart';
import 'package:flutter_tasks/model/image-model.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'gallery.dart';

//todo dodati broj kraj ToDo npr 5/12 na glavni meni a i kad se otvori fino

TodoElement _todoElement;
List<String> pathsForImages = [];
List<StepModel> steps = [];
List<ImageModel> models = [];
int _type, _theme;
bool isHeader = true, _autoTypeChanging=true;
ListPageState _state;
bool firstTime = true;

class Details extends StatefulWidget {
  State createState() => DetailsState();

  Details(
      {@required TodoElement element,
      @required int type,
      @required int theme,
      @required ListPageState state,
      @required int position,
      @required bool auto}) {
    _todoElement = element;
    _type = type;
    _theme = theme;
    _state = state;
    _autoTypeChanging = auto;
    print("Mijenjanje kategorije je $auto");
  }
}

class DetailsState extends State<Details> {
  DBhelper localDatabase = DBhelper();
  ScrollController _controller = new ScrollController();
  TextEditingController _textController = new TextEditingController(),
      _stepsEditingTextController = new TextEditingController(),
      _detailsAddingTextContoller = new TextEditingController();
  bool automaticTypeChanging = _autoTypeChanging;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _stepsEditingTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if(automaticTypeChanging && _todoElement.type!=Constants.TYPE_NOTES && _todoElement.stepsCount>0 && _todoElement.manuallyMoved!=1) {

      //todo automatsko mijenjanje kategorije, dodati da automaticTypeChanging vuce is sharedPreferences ili hive npr

      if(_todoElement.stepsDone>0 && _todoElement.stepsDone<_todoElement.stepsCount)
        _todoElement.type = Constants.TYPE_DOING;
      else if(_todoElement.stepsCount>0 && _todoElement.stepsDone == _todoElement.stepsCount)
        _todoElement.type = Constants.TYPE_DONE;
      else
        _todoElement.type = Constants.TYPE_DO;

      updateElement(context, _todoElement);
      _type = _todoElement.type;

    }

    return new Scaffold(
          backgroundColor: (_theme == Constants.THEME_DEFAULT)
              ? backColor(_type)
              : mainBackColor(
              widget: Constants.WIDGET_LAYER_BOTTOM, theme: _theme),
          appBar: AppBar(
            iconTheme:
            IconThemeData(color: typeColor(type: _type, theme: _theme)),
            backgroundColor: (_theme == Constants.THEME_DEFAULT)
                ? Colors.white
                : mainBackColor(
                widget: Constants.WIDGET_LAYER_MIDDLE, theme: _theme),
            title:
            new Text(
              "Details",
              style: TextStyle(
                color: typeColor(type: _type, theme: _theme),
                fontSize: 16,
              ),
            ),
            actions: <Widget>[
              Builder(
                builder: (context) => MaterialButton(
                  child: /* Icon(Icons.info,
                        color: typeColor(type: _type, theme: _theme)), */Icon(Icons.delete, color: typeColor(type: _type, theme: _theme),),
                  onPressed: () {
                    Scaffold.of(context).showSnackBar(new SnackBar(
                      content: new Text("Are you sure?"),
                      action: new SnackBarAction(label: "YES", textColor: typeColor(type: _type, theme: _theme),onPressed: (){
                        deleteElement(context, _todoElement);
                        Navigator.pop(context);
                      }),
                      duration: new Duration(seconds: 3),
                    ));
                  }/*=> Scaffold.of(context).showSnackBar(SnackBar(
                      backgroundColor: typeColor(type: _type, theme: _theme),
                      content: new Text("Long press or double tap to edit"),
                      duration: Duration(seconds: 2),
                    )
                    ) */,
                ),
              ) //showing the snackbar
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.005),
              child: LinearProgressIndicator(
                backgroundColor: Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(typeColor(theme: _theme, type: _type)),
                value: (_todoElement.stepsCount!=0 && _todoElement.stepsDone!=0)?_todoElement.stepsDone.toDouble()/_todoElement.stepsCount.toDouble():0,
              ),
            ),
          ),
          body: ListView(controller: _controller, children: <Widget>[

            Padding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Card(
                    child: new Padding(
                      padding: EdgeInsets.all(4),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Header",
                                    style: TextStyle(
                                      fontSize: 10,
                                      //fontWeight: FontWeight.w400,
                                      fontWeight: FontWeight.bold,
                                      color: typeColor(theme: _theme, type: _type),
                                    ),
                                  ),
                                  GestureDetector(
                                      child: new Icon(Icons.mode_edit, color: typeColor(theme: _theme, type: _type), size: 16,),
                                      onTap: (){
                                        print("edit header");
                                        //dodati logiku kojoom ce se ovdje otvarati stranica za novu bilješku ali sa popunjenim poljima za uredjivanje i pocetnim za HEADER
                                      }
                                  )
                                ],
                              )
                          ),
                          GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: ParsedText(
                                text: _todoElement.header,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 24,
                                    color: (_theme == Constants.THEME_DEFAULT)
                                        ? Colors.black
                                        : Colors.white,
                                    fontWeight: FontWeight.w400),
                                parse: <MatchText>[
                                  MatchText(
                                    type: ParsedType.URL,
                                      style: new TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: typeColor(type: _type, theme: _theme)
                                      ),
                                      onTap: (url){
                                          if(!url.toString().startsWith("http://") && !url.toString().startsWith("https://"))
                                        launch("http://"+url);
                                        else
                                          launch(url);
                                      }
                                  )
                                ],
                              ),
                            ),
                            onDoubleTap: () {
                              isHeader = true;
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: _editHeaderAlert);
                            },
                            onLongPress: () {
                              isHeader = true;
                              showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: /*_editHeaderAlert*/ (BuildContext
                                  context) {
                                    return AlertDialog(
                                        backgroundColor: (_theme ==
                                            Constants.THEME_DEFAULT)
                                            ? Colors.white
                                            : mainBackColor(
                                            widget: Constants.WIDGET_LAYER_MIDDLE,
                                            theme: _theme),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(32.00),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 16.00, horizontal: 8.0),
                                        titlePadding: EdgeInsets.all(0.0),
                                        content: SingleChildScrollView(
                                          child: new Text(
                                            _todoElement.header,
                                            style: new TextStyle(
                                              color:
                                              (_theme == Constants.THEME_DEFAULT)
                                                  ? Colors.black
                                                  : Colors.white,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14.00,
                                            ),
                                          ),
                                          scrollDirection: Axis.vertical,
                                        ));
                                  });
                            },
                          ),
                          (_todoElement.details != "")
                              ? Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Details",
                                    style: TextStyle(
                                      fontSize: 10,
                                      //fontWeight: FontWeight.w400,
                                      fontWeight: FontWeight.bold,
                                      color: typeColor(theme: _theme, type: _type),
                                    ),
                                  ),
                                  GestureDetector(
                                      child: new Icon(Icons.mode_edit, color: typeColor(theme: _theme, type: _type), size: 16,),
                                      onTap: (){
                                        print("edit details");
                                        //dodati logiku kojoom ce se ovdje otvarati stranica za novu bilješku ali sa popunjenim poljima za uredjivanje i pocetnim za HEADER
                                      }
                                  )
                                ],
                              )
                          )
                              : new Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    "Add details ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        //fontWeight: FontWeight.w300,
                                        fontWeight: FontWeight.bold,
                                        color:
                                        (_theme == Constants.THEME_DEFAULT)
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                  InkWell(
                                    child: Icon(
                                      Icons.add,
                                      color:
                                      typeColor(type: _type, theme: _theme),
                                    ),
                                    onTap: () => showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: (_theme ==
                                                Constants.THEME_DEFAULT)
                                                ? Colors.white
                                                : mainBackColor(
                                                widget: Constants
                                                    .WIDGET_LAYER_BOTTOM,
                                                theme: _theme),
                                            titlePadding: EdgeInsets.all(0),
                                            title: Container(
                                              height: 50.00,
                                              width: 300.00,
                                              decoration: BoxDecoration(
                                                color: typeColor(
                                                    type: _type, theme: _theme),
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                    Radius.circular(32),
                                                    topRight:
                                                    Radius.circular(32)),
                                              ),
                                              child: Align(
                                                alignment:
                                                FractionalOffset.center,
                                                child: Text(
                                                  "Details",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18),
                                                ),
                                              ),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(32.00)),
                                            ),
                                            content: TextField(
                                              controller:
                                              _detailsAddingTextContoller,
                                              maxLines: 12,
                                              autofocus: true,
                                              decoration: InputDecoration(
                                                hintText: "Enter the details",
                                                border: InputBorder.none,
                                                fillColor: mainBackColor(
                                                    widget: Constants
                                                        .WIDGET_LAYER_MIDDLE,
                                                    theme: _theme),
                                                filled: true,
                                              ),
                                              style: new TextStyle(
                                                  color: (_theme ==
                                                      Constants
                                                          .THEME_DEFAULT)
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                            actions: <Widget>[
                                              MaterialButton(
                                                child: new Text("Confirm",
                                                    style: new TextStyle(
                                                        color: typeColor(
                                                            type: _type,
                                                            theme: _theme),
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight.bold)),
                                                onPressed: () {
                                                  _todoElement.details =
                                                      _detailsAddingTextContoller
                                                          .text;
                                                  _todoElement.edited =
                                                      DateTime.now();
                                                  updateElement(
                                                      context, _todoElement);
                                                  _detailsAddingTextContoller
                                                      .text = "";
                                                  Navigator.of(context).pop();
                                                  setState(() {});
                                                },
                                              ),
                                              MaterialButton(
                                                child: new Text("Cancel",
                                                    style: new TextStyle(
                                                        color: typeColor(
                                                            type: _type,
                                                            theme: _theme),
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight.bold)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        }),
                                  ),
                                ]),
                          ),
                          GestureDetector(
                            onLongPress: () {
                              isHeader = false;
                              showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: /*_editHeaderAlert*/ (BuildContext
                                  context) {
                                    return AlertDialog(
                                        backgroundColor: (_theme ==
                                            Constants.THEME_DEFAULT)
                                            ? Colors.white
                                            : mainBackColor(
                                            widget: Constants.WIDGET_LAYER_MIDDLE,
                                            theme: _theme),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(32.00),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 16.00, horizontal: 8.0),
                                        titlePadding: EdgeInsets.all(0.0),
                                        content: SingleChildScrollView(
                                          child: new ParsedText(
                                            text: _todoElement.details,
                                            style: new TextStyle(
                                              color:
                                              (_theme == Constants.THEME_DEFAULT)
                                                  ? Colors.black
                                                  : Colors.white,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14.00,
                                            ),
                                            parse: <MatchText>[
                                              MatchText(
                                                  type: ParsedType.URL,
                                                  style: new TextStyle(
                                                      fontStyle: FontStyle.italic,
                                                      color: typeColor(type: _type, theme: _theme)
                                                  ),
                                                  onTap: (url){
                                                    if(!url.toString().startsWith("http://") && !url.toString().startsWith("https://"))
                                                      launch("http://"+url);
                                                    else
                                                      launch(url);
                                                  }
                                              )
                                            ],
                                          ),
                                          scrollDirection: Axis.vertical,
                                        ));
                                  });
                            },
                            onDoubleTap: () {
                              isHeader = false;
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: _editHeaderAlert);
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: ParsedText(
                                text: _todoElement.details,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                    color: (_theme == Constants.THEME_DEFAULT)
                                        ? Colors.black
                                        : Colors.white),
                                parse: <MatchText>[
                                  MatchText(
                                    type: ParsedType.URL,
                                      style: new TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: typeColor(type: _type, theme: _theme)
                                      ),
                                      onTap: (url){
                                        if(!url.toString().startsWith("http://") && !url.toString().startsWith("https://"))
                                          launch("http://"+url);
                                        else
                                          launch(url);
                                      }
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    elevation: 5,
                    color: mainBackColor(widget: Constants.WIDGET_LAYER_MIDDLE, theme: _theme),
                  ),
                  new Card(
                    elevation: 5,
                    child: new Padding(
                      padding: EdgeInsets.all(6),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          (_todoElement.stepsCount != 0 || _todoElement.stepsCount==0)
                              ? Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Steps " + ((_todoElement.stepsCount>0)?" (${_todoElement.stepsDone}/${_todoElement.stepsCount})":""),
                                    style: TextStyle(
                                      fontSize: 12,
                                      //fontWeight: FontWeight.w400,
                                      fontWeight: FontWeight.bold,
                                      color: typeColor(theme: _theme, type: _type),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: (_theme == Constants.THEME_DEFAULT)
                                                  ? Colors.white
                                                  : mainBackColor(
                                                  widget: Constants.WIDGET_LAYER_BOTTOM,
                                                  theme: _theme),
                                              titlePadding: EdgeInsets.all(0),
                                              title: Container(
                                                height: 50.00,
                                                width: 300.00,
                                                decoration: BoxDecoration(
                                                  color: typeColor(type: _type, theme: _theme),
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(32),
                                                      topRight: Radius.circular(32)),
                                                ),
                                                child: Align(
                                                  alignment: FractionalOffset.center,
                                                  child: Text(
                                                    "Adding step",
                                                    style:
                                                    TextStyle(color: Colors.white, fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(32.00)),
                                              ),
                                              content: SingleChildScrollView(
                                                  scrollDirection: Axis.vertical,
                                                  child: Container(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        Text(
                                                          "Step text",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                              (_theme == Constants.THEME_DEFAULT)
                                                                  ? Colors.black
                                                                  : typeColor(
                                                                  type: _type,
                                                                  theme: _theme)),
                                                          textAlign: TextAlign.start,
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.symmetric(vertical: 2),
                                                          child: TextField(
                                                            cursorColor:
                                                            typeColor(type: _type, theme: _theme),
                                                            controller: _textController,
                                                            autofocus: true,
                                                            decoration: InputDecoration(
                                                              hintText: "Enter the step",
                                                              border: InputBorder.none,
                                                              fillColor: mainBackColor(
                                                                  widget:
                                                                  Constants.WIDGET_LAYER_MIDDLE,
                                                                  theme: _theme),
                                                              filled: true,
                                                            ),
                                                            style: new TextStyle(
                                                                color: (_theme ==
                                                                    Constants.THEME_DEFAULT)
                                                                    ? Colors.black
                                                                    : Colors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w300),
                                                            maxLines: 12,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )),
                                              actions: <Widget>[
                                                FlatButton(
                                                  textColor: typeColor(theme: _theme, type: _type),
                                                  child: Text(
                                                    "Confirm",
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                  onPressed: () {
                                                    StepModel step = StepModel.name(
                                                        _todoElement.id,
                                                        _todoElement.stepsCount + 1,
                                                        0,
                                                        _textController.text.toString());
                                                    steps.add(step);
                                                    insertStep(context, step);
                                                    _textController.text = "";
                                                    _controller
                                                        .jumpTo(_controller.position.maxScrollExtent);
                                                    Navigator.of(context).pop();
                                                    setState(() {});
                                                  },
                                                ),
                                                FlatButton(
                                                  onPressed: () {
                                                    _textController.text = "";
                                                    Navigator.of(context).pop();
                                                    setState(() {});
                                                  },
                                                  child: Text(
                                                    "Cancel",
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                  textColor: typeColor(theme: _theme, type: _type),
                                                )
                                              ],
                                            );
                                          });
                                      Timer(
                                          Duration(milliseconds: 750),
                                              () => _controller
                                              .jumpTo(_controller.position.maxScrollExtent));
                                    },
                                    child: Icon(
                                      Icons.add,
                                      color: typeColor(type: _type, theme: _theme),
                                    ),
                                  )
                                ],
                              )
                          )
                              : Padding(
                            padding: EdgeInsets.all(0),
                          ),
                          FutureBuilder(
                            future: getStepsForNote(_todoElement.id),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<StepModel>> snapshot) {

                              if (snapshot.hasData) {
                                steps = snapshot.data;
                              }

                              return new Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Column(
                                  children: _getStepsFromModel(steps, context),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    color: mainBackColor(widget: Constants.WIDGET_LAYER_MIDDLE, theme: _theme),
                  ),
                  new Card(
                    elevation: 5,
                    child: new Padding(
                      padding: EdgeInsets.all(4),
                      child: new Column(
                        children: <Widget>[
                          new Padding(
                              padding: EdgeInsets.all(4),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Text(
                                    "Images",
                                    style: TextStyle(
                                        fontSize: 14,
                                        //fontWeight: FontWeight.w300,
                                        fontWeight: FontWeight.bold,
                                        color: typeColor(type: _type, theme: _theme)),
                                  ),
                                  new GestureDetector(
                                    child: Container(
                                      margin: new EdgeInsets.only(right: 5),
                                      child: new Center(child: new Icon(Icons.add, color: typeColor(theme: _theme, type: _type),),),
                                      color: Colors.transparent,
                                    ),
                                    onTap: () {
                                      getImage(context);
                                    },
                                  ),
                                ],

                              )
                          ),
                          FutureBuilder(
                              future: getImagesForNote(_todoElement.id),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<String>> snapshot) {
                                List<String> paths = [];

                                if (snapshot.hasData) {
                                  paths = snapshot.data;
                                  print("Snapshot has data");
                                }

                                List<Widget> widgets = [];
                                if (paths.length != 0)
                                  widgets.addAll(_getImagesFromModel(paths, context));

                                widgets = widgets.reversed.toList();
                                pathsForImages = paths.reversed.toList();

                                models = [];
                                int i=0;
                                for(String imagePath in pathsForImages) {
                                  models.add(new ImageModel(
                                      url: imagePath, elementId:i));
                                  i++;
                                }

                                print("Number of widgets: ${widgets.length}");

                                return new Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: new Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                        width: (pathsForImages.isEmpty)?0:MediaQuery.of(context).size.width * 0.88,
                                        height: (pathsForImages.isEmpty)?0:MediaQuery.of(context).size.width * 0.18,
                                        child: new ListView(
                                          scrollDirection: Axis.horizontal,
                                          physics: PageScrollPhysics(),
                                          children: _getImagesFromModel(pathsForImages, context),
                                        )
                                    ),
                                  ),
                                );
                              }
                          )
                        ],
                      ),
                    ),
                    color: mainBackColor(widget: Constants.WIDGET_LAYER_MIDDLE, theme: _theme),
                  )
                ],
              ),
              padding: EdgeInsets.all(4),
            ),
          ]),
          bottomNavigationBar: (_type != Constants.TYPE_NOTES)
              ? new Theme(
            child: new BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                    icon: _changeCategoryFirstWidget(
                        type: _type,
                        element: _todoElement,
                        state: _state,
                        context: context),
                    title: Padding(padding: EdgeInsets.all(0))),
                BottomNavigationBarItem(
                    icon: _changeCategorySecondWidget(
                        type: _type,
                        element: _todoElement,
                        state: _state,
                        context: context),
                    title: Padding(padding: EdgeInsets.all(0)))
              ],
              type: BottomNavigationBarType.fixed,
            ),
            data: theme.copyWith(
              canvasColor: (_theme == Constants.THEME_DEFAULT)
                  ? Colors.white
                  : mainBackColor(
                  widget: Constants.WIDGET_LAYER_MIDDLE,
                  theme: _theme),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          )
              : null,
        );

  }

  List<dynamic> images(List<String> paths){

    List<FileImage> images = [];
    for(String path in paths)
      images.add(new FileImage(new File(path)));

    return images;

  }

  Future getImage(BuildContext context) async {

    List<Asset> images = await MultiImagePicker.pickImages(maxImages: 10, enableCamera: true, materialOptions: new MaterialOptions(actionBarColor: "#000000", statusBarColor: "#000000"));
    List<File> imageFiles = [];
    if(images.length>0)
      for(Asset asset in images) {
        String path = await asset.filePath;
        imageFiles.add(new File(path));
        insertImage( context, new ImageModel(url: path, elementId: _todoElement.id));
      }

    setState(() {
      print("Resetting state");
    });
  }

  AlertDialog _editHeaderAlert(BuildContext context) {
    final theme = Theme.of(context);

    TextEditingController inputController = new TextEditingController();
    inputController.text =
        isHeader ? _todoElement.header : _todoElement.details;

    return AlertDialog(
      backgroundColor:
          mainBackColor(widget: Constants.WIDGET_LAYER_BOTTOM, theme: _theme),
      titlePadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(5),
      title: Container(
        padding: EdgeInsets.all(4),
        decoration: new BoxDecoration(
          color: typeColor(type: _type, theme: _theme),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.00),
              topRight: Radius.circular(32.00)),
        ),
        child: new Align(
          alignment: FractionalOffset.center,
          child: new Text(
            isHeader ? "Title" : "Details",
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32.00)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Theme(
                data: theme.copyWith(
                    primaryColor: typeColor(type: _type, theme: _theme)),
                child: TextField(
                  controller: inputController,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.white
                        : mainBackColor(
                            widget: Constants.WIDGET_LAYER_MIDDLE,
                            theme: _theme),
                    hintText: isHeader ? "Enter new title" : "Enter details",
                    labelStyle: theme.textTheme.caption
                        .copyWith(color: theme.primaryColor),
                  ),
                  maxLines: isHeader ? 2 : 8,
                  style: TextStyle(
                    fontSize: 14,
                    color: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.black
                        : Colors.white,
                  ),
                )),
            new Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    child: Text(
                      "Save",
                      style: TextStyle(
                          color: typeColor(type: _type, theme: _theme),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (isHeader)
                        _todoElement.header = inputController.text;
                      else if (!isHeader)
                        _todoElement.details = inputController.text;

                      _todoElement.edited = DateTime.now();
                      updateElement(context, _todoElement);
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                    elevation: 6,
                  ),
                  MaterialButton(
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          color: typeColor(type: _type, theme: _theme),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    elevation: 6,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  //widget funcs
  Widget _changeCategoryFirstWidget(
      {int type,
      TodoElement element,
      ListPageState state,
      BuildContext context}) {
    switch (type) {
      case Constants.TYPE_DO:
        return new InkWell(
          child: Icon(
            Icons.assignment_returned,
            color: typeColor(type: Constants.TYPE_DOING, theme: _theme),
            size: 24,
          ),
          onTap: () {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.white
                        : mainBackColor(
                            widget: Constants.WIDGET_LAYER_MIDDLE,
                            theme: _theme),
                    content: Container(
                      child: Text(
                        "You are about to start doing this task.",
                        style: new TextStyle(
                            color: (_theme == Constants.THEME_DEFAULT)
                                ? Colors.black
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: new Text("Confirm",
                            style: new TextStyle(
                                color: typeColor(
                                    type: Constants.TYPE_DOING, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          element.type = Constants.TYPE_DOING;
                          element.edited = DateTime.now();
                          element.manuallyMoved = 1;
                          updateElement(context, element);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          state.setState(() {});
                        },
                      ),
                      MaterialButton(
                        child: new Text("Cancel",
                            style: new TextStyle(
                                color: typeColor(
                                    type: Constants.TYPE_DOING, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          },
        );
      case Constants.TYPE_DOING:
        return new InkWell(
          child: Icon(
            Icons.assignment_late,
            color: typeColor(type: Constants.TYPE_DO, theme: _theme),
            size: 24,
          ),
          onTap: () {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.white
                        : mainBackColor(
                            widget: Constants.WIDGET_LAYER_MIDDLE,
                            theme: _theme),
                    content: Container(
                      child: Text(
                        "You are about to stop doing this task.",
                        style: new TextStyle(
                            color: (_theme == Constants.THEME_DEFAULT)
                                ? Colors.black
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: new Text("Confirm",
                            style: new TextStyle(
                                color: typeColor(
                                    type: Constants.TYPE_DO, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          element.type = Constants.TYPE_DO;
                          element.edited = DateTime.now();
                          element.manuallyMoved = 1;
                          updateElement(context, element);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          state.setState(() {});
                        },
                      ),
                      MaterialButton(
                        child: new Text("Cancel",
                            style: new TextStyle(
                                color: typeColor(
                                    type: Constants.TYPE_DO, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          },
        );
      case Constants.TYPE_DONE:
        return new InkWell(
          child: Icon(
            Icons.assignment_late,
            color: typeColor(type: Constants.TYPE_DO, theme: _theme),
            size: 24,
          ),
          onTap: () {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.white
                        : mainBackColor(
                            widget: Constants.WIDGET_LAYER_MIDDLE,
                            theme: _theme),
                    content: Container(
                      child: Text(
                        "You are going put this task to DO list.",
                        style: new TextStyle(
                            color: (_theme == Constants.THEME_DEFAULT)
                                ? Colors.black
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: new Text("Confirm",
                            style: new TextStyle(
                                color: typeColor(
                                    type: Constants.TYPE_DO, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          element.type = Constants.TYPE_DO;
                          element.edited = DateTime.now();
                          element.manuallyMoved = 1;
                          updateElement(context, element);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          state.setState(() {});
                        },
                      ),
                      MaterialButton(
                        child: new Text("Cancel",
                            style: new TextStyle(
                                color: typeColor(
                                    type: Constants.TYPE_DO, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          },
        );
      default:
        return new Padding(
          padding: EdgeInsets.all(0),
        );
        break;
    }
  }

  Widget _changeCategorySecondWidget(
      {int type,
      TodoElement element,
      ListPageState state,
      BuildContext context}) {
    switch (type) {
      case Constants.TYPE_DO:
        return new InkWell(
          child: Icon(
            Icons.assignment_turned_in,
            color: typeColor(type: Constants.TYPE_DONE, theme: _theme),
            size: 24,
          ),
          onTap: () {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.white
                        : mainBackColor(
                            widget: Constants.WIDGET_LAYER_MIDDLE,
                            theme: _theme),
                    content: Container(
                      child: Text(
                        "You have done this task.",
                        style: new TextStyle(
                            color: (_theme == Constants.THEME_DEFAULT)
                                ? Colors.black
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: new Text("Confirm",
                            style: new TextStyle(
                                color: typeColor(
                                    type: Constants.TYPE_DONE, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          element.type = Constants.TYPE_DONE;
                          element.edited = DateTime.now();
                          element.manuallyMoved = 1;
                          updateElement(context, element);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          state.setState(() {});
                        },
                      ),
                      MaterialButton(
                        child: new Text("Cancel",
                            style: new TextStyle(
                                color: typeColor(
                                    type: Constants.TYPE_DONE, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          },
        );
      case Constants.TYPE_DOING:
        return new InkWell(
          child: Icon(
            Icons.assignment_turned_in,
            color: typeColor(type: Constants.TYPE_DONE, theme: _theme),
            size: 24,
          ),
          onTap: () {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.white
                        : mainBackColor(
                            widget: Constants.WIDGET_LAYER_MIDDLE,
                            theme: _theme),
                    content: Container(
                      child: Text(
                        "You have done this task.",
                        style: new TextStyle(
                            color: (_theme == Constants.THEME_DEFAULT)
                                ? Colors.black
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: new Text("Confirm",
                            style: new TextStyle(
                                color: typeColor(
                                    type: Constants.TYPE_DONE, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          element.type = Constants.TYPE_DONE;
                          element.edited = DateTime.now();
                          element.manuallyMoved = 1;
                          updateElement(context, element);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          state.setState(() {});
                        },
                      ),
                      MaterialButton(
                        child: new Text("Cancel",
                            style: new TextStyle(
                                color: typeColor(
                                    type: Constants.TYPE_DONE, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          },
        );
      case Constants.TYPE_DONE:
        return new InkWell(
          child: Icon(
            Icons.assignment_returned,
            color: typeColor(type: Constants.TYPE_DOING, theme: _theme),
            size: 24,
          ),
          onTap: () {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.white
                        : mainBackColor(
                            widget: Constants.WIDGET_LAYER_MIDDLE,
                            theme: _theme),
                    content: Container(
                      child: Text(
                        "You are about to start doing this task again.",
                        style: new TextStyle(
                            color: (_theme == Constants.THEME_DEFAULT)
                                ? Colors.black
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: new Text("Confirm",
                            style: new TextStyle(
                                color: typeColor(
                                    type: Constants.TYPE_DOING, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          element.type = Constants.TYPE_DOING;
                          element.edited = DateTime.now();
                          element.manuallyMoved = 1;
                          updateElement(context, element);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          state.setState(() {});
                        },
                      ),
                      MaterialButton(
                        child: new Text("Cancel",
                            style: new TextStyle(
                                color: typeColor(
                                    type: Constants.TYPE_DOING, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          },
        );
      default:
        return new Padding(
          padding: EdgeInsets.all(0),
        );
        break;
    }
  }

  Future<List<String>> getImagesForNote(int noteId) async {
    return await localDatabase.getImagesForTodoElement(noteId);
  }

  List<Widget> _getImagesFromModel(
      List<String> imagePaths, BuildContext context) {
    print(
        "Entering creation of widgets. Image paths length : ${imagePaths.length}");

    List<Widget> widgets = [];
    int i = 0;
    for (String path in imagePaths) {
      widgets.add(_getImageWidgetFromModel(context, path,i));
      print("Adding to widget list $i je i");
      i++;
    }
    return widgets;
  }

  //todo generisanje widgeta pojedinacne slike
  Widget _getImageWidgetFromModel(BuildContext context, String imagePath, int index) {
    print("Returning model for image file");

    //todo rijesiti izgled carousela da izgleda to lijepo i to

    return new Hero(
      child: GestureDetector(
          child: new Container(
            decoration: BoxDecoration(
              color: (_theme==Constants.THEME_DEFAULT)?Colors.grey[100]:backColor(Constants.WIDGET_LAYER_HIGH),
              borderRadius: new BorderRadius.all(Radius.circular(6)),
            ),
            margin: new EdgeInsets.all(2),
            child: new ClipRRect(
              borderRadius: new BorderRadius.all(Radius.circular(6)),
              child: new FadeInImage(
                image: new FileImage(new File(imagePath)),
                placeholder: loadingGif(type: _type), //todo napraviti ovaj loader da bude lijep i minimalisticki
                fit: BoxFit.fill,
              ),
            ),
            width: MediaQuery.of(context).size.width * 0.22,
            height: MediaQuery.of(context).size.width * 0.18,
          ),
          onTap: () {
            Navigator.push(context, new MaterialPageRoute(
                builder: (context)=>new Gallery(initial:index, paths: pathsForImages, models: models,type: _todoElement.type, theme: _theme)
            ));
          }),
      tag: imagePath,
    );
  }

  Future<List<StepModel>> getStepsForNote(int noteId) async {
    return await localDatabase.getStepsByElementId(noteId);
  }

  List<Widget> _getStepsFromModel(List<StepModel> steps, BuildContext context) {
    List<Widget> widgets = new List();

    for (StepModel model in steps) {
      widgets.add(_getStepWidgetFromModel(context, model));
    }

    return widgets;
  }

  Widget _getStepWidgetFromModel(BuildContext context, StepModel model) {
    final theme = Theme.of(context);
    model.controller = new TextEditingController(text: model.stepText);

    return new Row(
      children: <Widget>[
        Text(
          "${model.position}",
          style: new TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w200,
              color: (_theme == Constants.THEME_DEFAULT)
                  ? Colors.black
                  : Colors.white),
        ),
        Checkbox(
          value: (model.isDone == 1),
          onChanged: (bool newValue) {
            model.isDone = newValue ? 1 : 0;
            updateStep(context, model, false);
            setState(() {
            });
          },
          checkColor: typeColor(type: _type, theme: _theme),
          activeColor: (_theme == Constants.THEME_DEFAULT)
              ? backColor(_type)
              : mainBackColor(
                  widget: Constants.WIDGET_LAYER_MIDDLE, theme: _theme),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: Align(
            child: InkWell(
              child: ParsedText(
                text: model.stepText,
                style: new TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                  color: (_theme == Constants.THEME_DEFAULT)
                      ? Colors.black
                      : Colors.white,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                parse: <MatchText>[
                  MatchText(
                      type: ParsedType.URL,
                      style: new TextStyle(
                        fontStyle: FontStyle.italic,
                        color: typeColor(type: _type, theme: _theme),
                      ),
                    onTap: (url) {
                      if(!url.toString().startsWith("http://") && !url.toString().startsWith("https://"))
                        launch("http://"+url);
                      else
                        launch(url);
                    },
                  )
                ],
              ),
              onLongPress: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: (_theme == Constants.THEME_DEFAULT)
                          ? Colors.white
                          : mainBackColor(
                          widget: Constants.WIDGET_LAYER_BOTTOM, theme: _theme),
                      titlePadding: EdgeInsets.all(0),
                      title: Container(
                        decoration: new BoxDecoration(
                          color: typeColor(type: _type, theme: _theme),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(32.00),
                              topLeft: Radius.circular(32.00)),
                        ),
                        child: Center(
                          child: Text(
                            "\nEdit step\n",
                            style: new TextStyle(
                                color: Colors.white, // prethodno je u dark modu bila crna
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.00)),
                      ),
                      content: Theme(
                          data: theme.copyWith(
                              primaryColor: typeColor(type: _type, theme: _theme)),
                          child: TextField(
                            autofocus: true,
                            controller: model.controller,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: (_theme == Constants.THEME_DEFAULT)
                                  ? Colors.white
                                  : mainBackColor(
                                  widget: Constants.WIDGET_LAYER_MIDDLE,
                                  theme: _theme),
                              labelStyle: theme.textTheme.caption
                                  .copyWith(color: theme.primaryColor),
                            ),
                            maxLines: 4,
                            style: TextStyle(
                              fontSize: 14,
                              color: (_theme == Constants.THEME_DEFAULT)
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          )),
                      actions: <Widget>[
                        MaterialButton(
                          child: new Text("Confirm",
                              style: new TextStyle(
                                  color: typeColor(type: _type, theme: _theme),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          onPressed: () {
                            model.stepText = model.controller.text;
                            updateStep(context, model, true);
                            setState(() {});
                            Navigator.of(context).pop();
                          },
                        ),
                        MaterialButton(
                          child: new Text("Cancel",
                              style: new TextStyle(
                                  color: typeColor(type: _type, theme: _theme),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  }),
            ),
            alignment: Alignment.centerLeft,
          )
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: InkWell(
              child: Icon(
                Icons.backspace,
                color: typeColor(type: _type, theme: _theme),
                size: 16,
              ),
              onTap: () {
                removeStep(model);
                setState(() {});
              },
            ),
          ),
        )
      ],
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
    );

  }

  //database funcs
  void removeStep(StepModel step) async {
    if (step.isDone == 1) {
      await localDatabase.decrementStepsDoneCount(_todoElement);
      _todoElement.stepsDone--;
    }
    _todoElement.stepsCount--;
    await localDatabase.refreshStepsPositions(step.position, _todoElement.id);
    await localDatabase.deleteStep(step);
    await localDatabase.decrementStepCount(_todoElement);
  }

  void refreshDone(int isDone, bool isEdit) async {
    if (!isEdit) {
      if (isDone == 1) {
        localDatabase.incrementStepsDoneCount(_todoElement);
        _todoElement.stepsDone++;
      } else {
        localDatabase.decrementStepsDoneCount(_todoElement);
        _todoElement.stepsDone--;
      }
    }
  }

  void insertImage(BuildContext context, ImageModel model) async {
    localDatabase.insertElementImage(model);
  }

  void updateImage(BuildContext context, ImageModel model) async {
    localDatabase.updateElementImage(model);
  }

  void deleteImage(BuildContext context, ImageModel model) async {
    localDatabase.removeElementImage(model);
  }

  void updateElement(BuildContext context, TodoElement element) async {
    localDatabase.updateElement(element);
  }

  void deleteElement(BuildContext context, TodoElement element) async {
    localDatabase.deleteElement(element);
  }

  void updateStep(BuildContext context, StepModel step, bool isEdit) async {
    refreshDone(step.isDone, isEdit);
    await localDatabase.updateStep(step);
  }

  void insertStep(BuildContext context, StepModel step) async {
    _todoElement.stepsCount++;
    await localDatabase.insertStep(step);
    await localDatabase.incrementStepCount(_todoElement);
  }
}

class GalleryTransitionPageRoute<T> extends MaterialPageRoute<T>{
  GalleryTransitionPageRoute({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {

      return new FadeTransition(opacity: animation, child: child,);

  }
}
