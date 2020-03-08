import 'package:flutter/material.dart';
import '../utils/const.dart';
import '../model/element-model.dart';
import '../sql/database.dart';
import '../list.dart';

//todo postaviti mali razmak izmedju teksta i kockice i namjestiti da tekst overflow bude sa tackicama

class MainList extends StatefulWidget{

  MainList();

  @override
  State createState()=>new MainListState();

}

class MainListState extends State<MainList>{

  MainListState();

  @override
  Widget build(BuildContext context) {
      return new Container(
        margin: EdgeInsets.fromLTRB(28, 48, 16, 16),
        child: new Center(
          child: new ListView(
            children: <Widget>[
              new Card(
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    new MaterialButton(
                      onPressed: ()=>print("button pressed"),
                      height: 30,
                      minWidth: 30,
                      child: new Icon(
                        Icons.filter_list,
                        color: Color(0xff967adc),
                      ),
                      color: Colors.transparent,
                      elevation: 0,
                    ),
                    new Expanded(
                        child: new Container(
                            margin: EdgeInsets.all(4),
                            child: new Theme(
                              data: new ThemeData(
                                  primaryColor: Colors.grey
                              ),
                              child: new TextField(
                                textInputAction: TextInputAction.search,
                                maxLines: 1,
                                cursorColor: Color(0xff967adc),
                                style: new TextStyle(
                                  color: Color(0xff967adc),
                                ),
                                showCursor: true,
                                decoration: new InputDecoration(
                                  hintText: "Search",
                                  fillColor: Color(0xff967adc),
                                  focusedBorder: new UnderlineInputBorder(borderSide: new BorderSide(color: Color(0xff967adc))),
                                  enabledBorder: new UnderlineInputBorder(borderSide: new BorderSide(color: Color(0xff967adc))),
                                  prefixIcon: new Icon(
                                    Icons.search,
                                  ),
                                ),
                              ),
                            )
                        )
                    ),
                  ],
                ),
                elevation: 5,
              ),

              new MostRecentOfATypeList(Constants.TYPE_DO),
              new MostRecentOfATypeList(Constants.TYPE_DOING),
              new MostRecentOfATypeList(Constants.TYPE_DONE),
              new MostRecentOfATypeList(Constants.TYPE_NOTES)

            ],

          ),
        )
      );
  }
}

class MostRecentOfATypeList extends StatefulWidget{

  int type;

  MostRecentOfATypeList(this.type);

  @override
  State createState()=>new MostRecentOfATypeListState(this.type);

}

class MostRecentOfATypeListState extends State<MostRecentOfATypeList>{

  int type, theme=Constants.THEME_DEFAULT;
  DBhelper localDatabase = new DBhelper();

  MostRecentOfATypeListState(this.type);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<List<TodoElement>>(builder: (BuildContext context, AsyncSnapshot<List<TodoElement>> snapshot)
    {
      if(snapshot.connectionState == ConnectionState.done && snapshot.hasData)
        return new GestureDetector(
          child: new Container(
            child: Card(
              elevation: 5,
              child: new Container(
                padding: EdgeInsets.all(4),
                child: new Column(
                  children: _getTodoWidgets(snapshot.data),
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
            ),
            margin: EdgeInsets.symmetric(vertical: 5),
          ),
          onTap: (){

            //todo ovaj dio je za to da kad se klikne na cijelu podlistu na glavnom ekranu da otvori kategoriju a ne samo na dugme da bude
            setState(() {
              getTheme();
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder:
                  (context) =>
              new ListPage(
                  theme: theme,
                  type: this.type,
                  title: _getTypeText(),
                  el: getTypedElements(this.type)
              )
              )
              ,);
          },
        );
      else {
        return new Container(
          child: Card(
            elevation: 10,
            child: new Container(
              padding: EdgeInsets.all(4),
              child: new Column(
                children: _getTodoWidgets(new List<TodoElement>()),
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          ),
          margin: EdgeInsets.symmetric(vertical: 5),
        );
      }
    },
    future: (this.type==Constants.TYPE_NOTES)?localDatabase.getMostImportantNotesByType(this.type):localDatabase.getMostImportantElementsByType(this.type));
  }

  /*
    )*/

  String _getTypeText(){
    switch(this.type){
      case Constants.TYPE_DO:
        return "To do";
      case Constants.TYPE_DOING:
        return "Doing";
      case Constants.TYPE_DONE:
        return "Done";
      case Constants.TYPE_NOTES:
        return "Notes";
      default:
        return "";
    }
  }

  Color _getTypeColor(){
    switch(this.type){
      case Constants.TYPE_DO:
        return Color(0xffe9573f); //0xffc21807
      case Constants.TYPE_DOING:
        return Color(0xfff6bb42); //0xffe1ad01
      case Constants.TYPE_DONE:
        return Color(0xff8cc152); //0xff84c011
      case Constants.TYPE_NOTES:
        return Color(0xff4a89dc); //0xff111e6c
      default:
        return Colors.black;
    }
  }

  Widget _getTodoWidget(TodoElement element){
    return new ListTile(
      title: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Container(
            color: _getTypeColor(),
            width: 8,
            height: 8,
          ), new Text(
            element.header,
            style: new TextStyle(
              color: _getTypeColor(),
              fontSize: 12
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getTodoWidgets(List<TodoElement> elements){

    List<Widget> widgets = [];

    widgets.add(
        new MaterialButton(
          height: 20,
          minWidth: 22,
          elevation: 5,
          onPressed: (){
            print("Navigating using material button");

            setState(() {
              getTheme();
            });

            Navigator.push(
              context,
              MaterialPageRoute(builder:
                  (context) => new ListPage(
                      theme: theme,
                      type: this.type,
                      title: _getTypeText(),
                      el: getTypedElements(this.type)
                  )
               )
              ,);
          },
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.all(new Radius.circular(12)),
          ),
          child: new Text(
            _getTypeText(),
            style: new TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[50],
              fontSize: 14
            ),
            overflow: TextOverflow.ellipsis,
          ),
          color: _getTypeColor(),
        )
    );

    for(TodoElement element in elements)
      widgets.add(_getTodoWidget(element));

    return widgets;

  }

  Future<List<TodoElement>> getTypedElements(int type) async {
    return await localDatabase.getElementsByType(type);
  }

  getTheme() async {
    theme = await localDatabase.getTheme();
  }

  }
