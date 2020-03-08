import 'package:flutter/material.dart';
import 'package:flutter_tasks/details.dart';
import 'package:flutter_tasks/sql/database.dart';
import 'package:flutter_tasks/model/element-model.dart';
import 'package:flutter_tasks/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/funcs.dart';

List<TodoElement> elements = new List();
Future<List<TodoElement>> els;
int _type, _theme;
bool _autochangingtype=true;
String _title;

class ListPage extends StatefulWidget {
  ListPageState createState(){
    return ListPageState(elements);
  }

  ListPage(
      {@required int type,
      @required String title,
      @required Future el,
      @required int theme}) {
    _type = type;
    _title = title;
    els = el;
    _theme = theme;
  }

}

class ListPageState extends State<ListPage> {
  DBhelper localDatabase = DBhelper();

  TextEditingController _headerController;
  TextEditingController _detailsController;
  List<TodoElement> todos = new List();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  ListPageState(List<TodoElement> elements) {
    this.todos = elements;
  }

  getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _theme = sharedPreferences.getInt(Constants.SHARED_THEME);
  }

  getAutoChangingType() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _autochangingtype = await sharedPreferences.getBool(Constants.SHARED_AUTO_TYPE_CHANGING);
  }

  @override
  void initState() {
    super.initState();
    _headerController = new TextEditingController();
    _detailsController = new TextEditingController();
    getAutoChangingType();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            _title,
            style: TextStyle(
              color: typeColor(type: _type, theme: _theme),
              fontSize: 16,
            ),
          ),
          backgroundColor:
          mainBackColor(widget: Constants.WIDGET_LAYER_MIDDLE, theme: _theme),
          iconTheme: IconThemeData(color: typeColor(type: _type, theme: _theme)),
        ),
        body: FutureBuilder(
            future: getTypedElements(_type),
            builder: (BuildContext context,
                AsyncSnapshot<List<TodoElement>> snapshot) {
              if (!snapshot.hasData)
                return Container(
                  child: Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation(
                            typeColor(type: _type, theme: _theme)),
                      )
                  ),
                );

              List<TodoElement> content = snapshot.data;

              if(content.length>0)
              return new GridView.count(
                children: getElementsFromModel(content, context, this),
                crossAxisCount: 2,
              );
              else
                return new Center(
                  child: Text(
                    _getNoDataMessage(),
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        color: typeColor(theme: _theme, type: _type),
                        fontWeight: FontWeight.bold,
                        fontSize: 24.00,
                    ),
                  ),
                );
            }),
        backgroundColor: (_theme == Constants.THEME_DEFAULT)
            ? backColor(_type)
            : mainBackColor(widget: Constants.WIDGET_LAYER_BOTTOM, theme: _theme),
        floatingActionButton: (_type != Constants.TYPE_DO &&
            _type != Constants.TYPE_NOTES)
            ? null
            : FloatingActionButton(
          onPressed: () =>
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: mainBackColor(
                          widget: Constants.WIDGET_LAYER_BOTTOM, theme: _theme),
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
                            "Adding element",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.00)),
                      ),
                      content: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "Headline",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: (_theme == Constants.THEME_DEFAULT)
                                      ? Colors.black
                                      : typeColor(type: _type, theme: _theme)),
                              textAlign: TextAlign.start,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              child: TextField(
                                cursorColor:
                                typeColor(type: _type, theme: _theme),
                                controller: _headerController,
                                onTap:(){ _headerController.selection=TextSelection.collapsed(offset: _headerController.text.length);},
                                onChanged: (text){ _headerController.selection=TextSelection.collapsed(offset: _headerController.text.length);},
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: "Enter task/note headline",
                                  border: InputBorder.none,
                                  fillColor: mainBackColor(
                                      widget: Constants.WIDGET_LAYER_MIDDLE,
                                      theme: _theme),
                                  filled: true,
                                ),
                                style: new TextStyle(
                                    color: (_theme == Constants.THEME_DEFAULT)
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300),
                                maxLines: 2,
                              ),
                            ),
                            Text(
                              "Details",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: (_theme == Constants.THEME_DEFAULT)
                                      ? Colors.black
                                      : typeColor(type: _type, theme: _theme)),
                              textAlign: TextAlign.start,
                            ),
                            Container(
                              child: TextField(
                                cursorColor:
                                typeColor(type: _type, theme: _theme),
                                controller: _detailsController,
                                decoration: InputDecoration(
                                  hintText: "Enter task/note",
                                  border: InputBorder.none,
                                  fillColor: (_theme == Constants.THEME_DEFAULT)
                                      ? Colors.white
                                      : mainBackColor(
                                      widget: Constants.WIDGET_LAYER_MIDDLE,
                                      theme: _theme),
                                  filled: true,
                                ),
                                style: new TextStyle(
                                    color: (_theme == Constants.THEME_DEFAULT)
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300),
                                maxLines: 4,
                              ),
                              margin: EdgeInsets.only(top: 6),
                            )
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          textColor: typeColor(theme: _theme, type: _type),
                          child: Text(
                            "Confirm",
                            style: TextStyle(fontSize: 18),
                          ),
                          onPressed: () {
                            if (_headerController.text != "") {
                              TodoElement element = new TodoElement.name(
                                  _type,
                                  _detailsController.text.toString(),
                                  _headerController.text.toString(),
                                  DateTime.now(),
                                  DateTime.now(),
                                  0,
                                  0,
                                  0);
                              todos.add(element);
                              insertElement(context, element);
                              _detailsController.text = "";
                              _headerController.text = "";
                              Navigator.of(context).pop();
                              setState(() {});
                            }
                            else {

                              //todo namjestiti da se prikazuje u istom nivou gdje je i alertdialog a ne iza njega

                              this._scaffoldKey.currentState.showSnackBar(new SnackBar(
                                content: new Text(
                                  "You must at least add a title",
                                ),
                                backgroundColor: typeColor(type: _type, theme: _theme),
                                duration: Duration(seconds: 2),
                              )
                              );
                            }
                          }
                        ),
                        FlatButton(
                          onPressed: () {
                            _detailsController.text = "";
                            _headerController.text = "";
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
                  }),
          backgroundColor: mainBackColor(
              widget: Constants.WIDGET_LAYER_HIGH, theme: _theme),
          child: Icon(
            Icons.add,
            color: typeColor(type: _type, theme: _theme),
          ),
          elevation: 6,
        ),
      ),
    );

  }

  List<Widget> getElementsFromModel(List<TodoElement> elements,
      BuildContext context, ListPageState state) {
    List<Widget> buttons = new List();

    for (TodoElement element in elements)
      buttons.add(_widgetFromModel(element, context, state));

    return buttons;
  }

  Widget _widgetFromModel(TodoElement element, BuildContext context,
      ListPageState state) {
    return InkWell(
      onTap: () {
        openDetailsScreen(element, state);
      },
      child: Card(
        color:
        mainBackColor(widget: Constants.WIDGET_LAYER_MIDDLE, theme: _theme),
        elevation: 1.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 40.00 / 12.00,
              child: Material(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.00),
                    topRight: Radius.circular(10.00)),
                color: typeColor(type: _type, theme: _theme),
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Container(
                    child: Align(
                      alignment: FractionalOffset.center,
                      child: Text(
                        element.header,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            fontFamily: 'Rock Salt'),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            new Padding(
                padding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        element.details,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w200,
                            color: (_theme == Constants.THEME_DEFAULT)
                                ? Colors.black
                                : Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      ),
                      width: double.maxFinite,
                      height: 70,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 6),
                    ),
                    Align(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Created at: ",
                                  style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w300,
                                      color: (_theme == Constants.THEME_DEFAULT)
                                          ? Colors.black
                                          : typeColor(
                                          type: _type, theme: _theme)),
                                ),
                                Text(
                                  "Edited at: ",
                                  style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w300,
                                      color: (_theme == Constants.THEME_DEFAULT)
                                          ? Colors.black
                                          : typeColor(
                                          type: _type, theme: _theme)),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(dateTimeFormat(element.timestamp),
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300,
                                        color:
                                        (_theme == Constants.THEME_DEFAULT)
                                            ? Colors.black
                                            : Colors.white)
                                ),
                         /*       _changeCategoryFirstWidget(type: _type,
                                    state: state,
                                    context: context,
                                    element: element), */
                                InkWell(
                                  child: Icon(
                                    Icons.delete,
                                    color: (_theme == Constants.THEME_DEFAULT
                                        ? Colors.black
                                        : Colors.white
                                    ),
                                    size: 18,
                                  ),
                                  onTap: () {
                                    showDialog(barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(20),
                                            ),
                                            backgroundColor: (_theme ==
                                                Constants.THEME_DEFAULT)
                                                ? Colors.white
                                                : mainBackColor(
                                                widget: Constants
                                                    .WIDGET_LAYER_MIDDLE,
                                                theme: _theme),
                                            content: Container(
                                              child: Text(
                                                "Are you sure you want to delete this record?",
                                                style: new TextStyle(
                                                    color: (_theme ==
                                                        Constants.THEME_DEFAULT)
                                                        ? Colors.black
                                                        : typeColor(type: _type,
                                                        theme: _theme),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600
                                                ),
                                              ),
                                            ),
                                            actions: <Widget>[
                                              MaterialButton(
                                                child: new Text(
                                                    "Confirm",
                                                    style: new TextStyle(
                                                        color: typeColor(
                                                            type: _type,
                                                            theme: _theme),
                                                        fontSize: 16,
                                                        fontWeight: FontWeight
                                                            .bold
                                                    )
                                                ),
                                                onPressed: () {
                                                  deleteElement(
                                                      context, element);
                                                  state.setState(() {});
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              MaterialButton(
                                                child: new Text(
                                                    "Cancel",
                                                    style: new TextStyle(
                                                        color: typeColor(
                                                            type: _type,
                                                            theme: _theme),
                                                        fontSize: 16,
                                                        fontWeight: FontWeight
                                                            .bold
                                                    )
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        });
                                  },
                                ),
                                /*_changeCategorySecondWidget(type: _type,
                                    state: state,
                                    context: context,
                                    element: element),
                                */Text(dateTimeFormat(element.edited),
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300,
                                        color:
                                        (_theme == Constants.THEME_DEFAULT)
                                            ? Colors.black
                                            : Colors.white)
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  dynamic openDetailsScreen(TodoElement element, ListPageState state) async {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) =>
                Details(
                    element: element,
                    type: element.type,
                    theme: _theme,
                    state: state,
                    position: 1,
                    auto: _autochangingtype
                )));
  }

  String dateTimeFormat(DateTime dateTime) {
    return dateTime.day.toString() +
        "." +
        dateTime.month.toString() +
        "." +
        dateTime.year.toString() +
        ".";
  }

  Future<List<TodoElement>> getTypedElements(int type) async {
    return await localDatabase.getElementsByType(type);
  }

  void insertElement(BuildContext context, TodoElement element) async {
    await localDatabase.insertElement(element);
  }

  void updateElement(BuildContext context, TodoElement element) async {
    await localDatabase.updateElement(element);
  }

  void deleteElement(BuildContext context, TodoElement element) async {
    await localDatabase.deleteElement(element);
  }

  Widget _changeCategoryFirstWidget(
      {int type, TodoElement element, ListPageState state, BuildContext context}) {
    switch (type) {
      case Constants.TYPE_DO:
        return new InkWell(
          child: Icon(
            Icons.assignment_returned,
            color: typeColor(type: Constants.TYPE_DOING, theme: _theme),
            size: 16,
          ),
          onTap: () {
            showDialog(barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.white
                        : mainBackColor(
                        widget: Constants.WIDGET_LAYER_MIDDLE, theme: _theme),
                    content: Container(
                      child: Text(
                        "You are about to start doing this task.",
                        style: new TextStyle(
                            color: (_theme == Constants.THEME_DEFAULT) ? Colors
                                .black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: new Text(
                            "Confirm",
                            style: new TextStyle(
                                color: typeColor(type: Constants.TYPE_DOING, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        onPressed: () {
                          element.type = Constants.TYPE_DOING;
                          updateElement(context, element);
                          state.setState(() {});
                          Navigator.of(context).pop();
                        },
                      ),
                      MaterialButton(
                        child: new Text(
                            "Cancel",
                            style: new TextStyle(
                                color: typeColor(type: Constants.TYPE_DOING, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
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
            size: 16,
          ),
          onTap: () {
            showDialog(barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.white
                        : mainBackColor(
                        widget: Constants.WIDGET_LAYER_MIDDLE, theme: _theme),
                    content: Container(
                      child: Text(
                        "You are about to stop doing this task.",
                        style: new TextStyle(
                            color: (_theme == Constants.THEME_DEFAULT) ? Colors
                                .black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: new Text(
                            "Confirm",
                            style: new TextStyle(
                                color: typeColor(type: Constants.TYPE_DO, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        onPressed: () {
                          element.type = Constants.TYPE_DO;
                          updateElement(context, element);
                          state.setState(() {});
                          Navigator.of(context).pop();
                        },
                      ),
                      MaterialButton(
                        child: new Text(
                            "Cancel",
                            style: new TextStyle(
                                color: typeColor(type: Constants.TYPE_DO, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
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
            size: 16,
          ),
          onTap: () {
            showDialog(barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.white
                        : mainBackColor(
                        widget: Constants.WIDGET_LAYER_MIDDLE, theme: _theme),
                    content: Container(
                      child: Text(
                        "You are going put this task to DO list.",
                        style: new TextStyle(
                            color: (_theme == Constants.THEME_DEFAULT) ? Colors
                                .black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: new Text(
                            "Confirm",
                            style: new TextStyle(
                                color: typeColor(type: Constants.TYPE_DO, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        onPressed: () {
                          element.type = Constants.TYPE_DO;
                          updateElement(context, element);
                          state.setState(() {});
                          Navigator.of(context).pop();
                        },
                      ),
                      MaterialButton(
                        child: new Text(
                            "Cancel",
                            style: new TextStyle(
                                color: typeColor(type: Constants.TYPE_DO, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
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
      {int type, TodoElement element, ListPageState state, BuildContext context}) {
    switch (type) {
      case Constants.TYPE_DO:
        return new InkWell(
          child: Icon(
            Icons.assignment_turned_in,
            color: typeColor(type: Constants.TYPE_DONE, theme: _theme),
            size: 16,
          ),
          onTap: () {
            showDialog(barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.white
                        : mainBackColor(
                        widget: Constants.WIDGET_LAYER_MIDDLE, theme: _theme),
                    content: Container(
                      child: Text(
                        "You have done this task.",
                        style: new TextStyle(
                            color: (_theme == Constants.THEME_DEFAULT) ? Colors
                                .black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: new Text(
                            "Confirm",
                            style: new TextStyle(
                                color: typeColor(type: Constants.TYPE_DONE, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        onPressed: () {
                          element.type = Constants.TYPE_DONE;
                          updateElement(context, element);
                          state.setState(() {});
                          Navigator.of(context).pop();
                        },
                      ),
                      MaterialButton(
                        child: new Text(
                            "Cancel",
                            style: new TextStyle(
                                color: typeColor(type: Constants.TYPE_DONE, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
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
            size: 16,
          ),
          onTap: () {
            showDialog(barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.white
                        : mainBackColor(
                        widget: Constants.WIDGET_LAYER_MIDDLE, theme: _theme),
                    content: Container(
                      child: Text(
                        "You have done this task.",
                        style: new TextStyle(
                            color: (_theme == Constants.THEME_DEFAULT) ? Colors
                                .black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: new Text(
                            "Confirm",
                            style: new TextStyle(
                                color: typeColor(type: Constants.TYPE_DONE, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        onPressed: () {
                          element.type = Constants.TYPE_DONE;
                          updateElement(context, element);
                          state.setState(() {});
                          Navigator.of(context).pop();
                        },
                      ),
                      MaterialButton(
                        child: new Text(
                            "Cancel",
                            style: new TextStyle(
                                color: typeColor(type: Constants.TYPE_DONE, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
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
            size: 16,
          ),
          onTap: () {
            showDialog(barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: (_theme == Constants.THEME_DEFAULT)
                        ? Colors.white
                        : mainBackColor(
                        widget: Constants.WIDGET_LAYER_MIDDLE, theme: _theme),
                    content: Container(
                      child: Text(
                        "You are about to start doing this task again.",
                        style: new TextStyle(
                            color: (_theme == Constants.THEME_DEFAULT) ? Colors
                                .black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      MaterialButton(
                        child: new Text(
                            "Confirm",
                            style: new TextStyle(
                                color: typeColor(type: Constants.TYPE_DOING, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        onPressed: () {
                          element.type = Constants.TYPE_DOING;
                          updateElement(context, element);
                          state.setState(() {});
                          Navigator.of(context).pop();
                        },
                      ),
                      MaterialButton(
                        child: new Text(
                            "Cancel",
                            style: new TextStyle(
                                color: typeColor(type: Constants.TYPE_DOING, theme: _theme),
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
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

  String _getNoDataMessage(){

    switch(_type){
      case Constants.TYPE_DO:
        return Constants.EMPTY_MESSAGE_TYPE_DO;
        break;
      case Constants.TYPE_DOING:
        return Constants.EMPTY_MESSAGE_TYPE_DOING;
        break;
      case Constants.TYPE_DONE:
        return Constants.EMPTY_MESSAGE_TYPE_DONE;
        break;
      case Constants.TYPE_NOTES:
        return Constants.EMPTY_MESSAGE_TYPE_NOTES;
        break;
      default:
        return Constants.EMPTY_MESSAGE_TYPE_DEFAULT;
        break;
    }
  }
}
