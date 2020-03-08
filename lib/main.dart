import 'package:flutter/material.dart';
import 'package:flutter_tasks/model/element-model.dart';
import 'package:flutter_tasks/utils/const.dart';
import 'package:flutter_tasks/utils/funcs.dart';
import 'sql/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/main_list.dart';

//todo uraditi credits prior2
//todo ubaciti zvukove prior3
//todo uraditi animacije prior2
//todo IMAGES UPDATE - srediti palceholder,napraviti uklanjanje slike, napraviti pregled slike kao hero da otvori u dijalogu kao instagram a pozadinu da bluruje tj frozen water effect (indexed stack sa backdrop filterom bi mogao to biti fino taman), dodati selekciju veceg broja slika,
//todo IMAGES UPDATE - srediti palceholder, napraviti uklanjanje slike, napraviti pregled slike kao hero da otvori u dijalogu kao instagram a pozadinu da bluruje tj frozen water effect (indexed stack sa backdrop filterom bi mogao to biti fino taman), dodati selekciju veceg broja slika,
//todo dodati snimanje zvuka za biljesku prior3 (za audio vizuelizaciju morace native kod biti i povezivan)
//todo dodati dodavanje biljeske nakon slikanja slike prior3
//todo na kraju niza slika da stoji plus na ciji klik ce ici alert dialog sa izborom da se otvori kamera ili da se unese iz fajla nesto (column sa childom gridviewom i ispod njega dugme da bude plus
//todo i natpis Dodaj prior2
//todo ???samo kada snima pomocu todo-a ce moci??? dodati spektogram kada ima snimak zvuka prior4
//todo kada u bazi postoji da je trebalo biti slika ili snimak za nesto, a korisnik je to obrisao, da mu bude obavjestenje da je tu trebalo biti ali trenutno nije moguce doci do toga
//todo dodati postignuca prior4
//todo optimizovati da ne bude skipping frames prior4
//todo dodati citat dana u neki dio da se pojavi mozda kao da iskoci ako se prvi put pali sad app ovog dana. u dijalogu nekom da bude i pozadina da bude blurovana tako nesto, isto na foru indexed stack-a
//todo sigurnost da ide pin/otisak/sifra/sema

void main() => runApp(MainPage());

class MainPage extends StatelessWidget {
  DBhelper help = DBhelper();

  @override
  Widget build(BuildContext context) {

    initializeTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo list',
      home: MainPageContent(),
      theme: ThemeData(fontFamily: "OpenSans"),
    );
  }

  void insertElement(BuildContext context, TodoElement element) async {
    await help.insertElement(element);
  }

  void initializeTheme() async {
    dynamic rez = await help.getTheme();
    if(rez!=1 && rez!=2) {
      help.initializeTheme();
     // help.setTheme(Constants.THEME_DEFAULT);
      {
        print("help initialized theme");
        themeSharedPref = Constants.THEME_DEFAULT;
      }
    }
  }
}

bool soundSharedPref = true, isInitial = true, isModalOpen=false;
int themeSharedPref = Constants.THEME_DEFAULT;
bool automaticTypeChanging = true;
MainPageContent content;
VoidCallback callback;

class MainPageContent extends StatefulWidget {
  State createState() {
    MainPageState mainPageState = MainPageState();
    mainPageState.getTheme();
    isInitial = false;
    return mainPageState;

  }
}

class MainPageState extends State<MainPageContent> {
  DBhelper localDatabase = DBhelper();


  @override
  void initState() {
    initialShared();
    getSound();
    getTheme();
    getAutomaticTypeChanging();
    super.initState();
  }

  bool swipedRight = false;

  @override
  Widget build(BuildContext context) {

     return Scaffold(
      backgroundColor: (themeSharedPref==Constants.THEME_DARK)?mainBackColor(widget: Constants.WIDGET_LAYER_BOTTOM, theme: themeSharedPref):Color(0xffd9dddc),
         appBar: new PreferredSize(
           preferredSize: new Size(0, 0),

           child: new Container(
             width: 0,
             height: 0,
           ),
         ),
      body: new MainList()

      ,
       floatingActionButton: new SheetFloatingButton(this),
    );

  }

  void insertElement(BuildContext context, TodoElement element) async {
    localDatabase.insertElement(element);
  }

  Future<List<TodoElement>> getTypedElements(int type) async {
    return await localDatabase.getElementsByType(type);
  }

  void switchSound(bool sound) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(Constants.SHARED_SOUND, sound);
    soundSharedPref = sound;
  }

  Future<bool> getSound() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool sound = sharedPreferences.getBool(Constants.SHARED_SOUND);
    soundSharedPref = sound;
    return sound;
  }

  Future<bool> getAutomaticTypeChanging() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool automatic = sharedPreferences.getBool(Constants.SHARED_AUTO_TYPE_CHANGING);
    automaticTypeChanging = automatic;
    return automatic;
  }

  void setAutomaticTypeChanging(bool auto) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(Constants.SHARED_AUTO_TYPE_CHANGING, auto);
  }

  initialShared() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (!sharedPreferences.containsKey(Constants.SHARED_SOUND))
      await sharedPreferences.setBool(Constants.SHARED_SOUND, true);
    if (!sharedPreferences.containsKey(Constants.SHARED_THEME))
      await sharedPreferences.setInt(
          Constants.SHARED_THEME, Constants.THEME_DARK);
    if(!sharedPreferences.containsKey(Constants.SHARED_AUTO_TYPE_CHANGING))
      await sharedPreferences.setBool(Constants.SHARED_AUTO_TYPE_CHANGING, true);
  }

  setTheme(int theme) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt(Constants.SHARED_THEME, theme);
  }

  getTheme() async {
    themeSharedPref = await localDatabase.getTheme();
  }

  Color getThemeColor(bool isLight) {
    if (isLight) {
      if (themeSharedPref == Constants.THEME_DEFAULT)
        return Color(0xff967adc);
      else
        return Colors.black;
    } else {
      if (themeSharedPref == Constants.THEME_DARK)
        return Color(0xff967adc);
      else
        return Colors.black;
    }
  }

}

//todo napraviti u settings opciju samo da se pali/gasi autoTypeChanging jos.

class SheetFloatingButton extends StatefulWidget{

  MainPageState state;

  SheetFloatingButton(this.state);

  @override
  State createState()=>SheetFloatingButtonState(this.state);

}

class SheetFloatingButtonState extends State<SheetFloatingButton>{

  bool showFab=true;
  MainPageState state;

  SheetFloatingButtonState(this.state);

  @override
  Widget build(BuildContext context) {
    return (showFab)? new FloatingActionButton.extended(
      onPressed: (){
        var bottomSheetController = showBottomSheet(context: context, builder: (context){
          return new BottomSheetWidget(this.state);
        }, backgroundColor: Color(0x00000000));

        showFloatingButton(false);
        bottomSheetController.closed.then((value){
          showFloatingButton(true);
        });
      },
      icon: new Icon(
        Icons.more,
        color: Color(0xff967adc),
      ),
      label: new Text(
        "More",
        style: new TextStyle(
          color: Color(0xff967adc)
        ),
      ),
      backgroundColor: Colors.grey[50],
    ):Container(width: 0, height: 0,);



  }

  void showFloatingButton(bool show){
    setState(() {
      showFab=show;
    });
  }

}

class BottomSheetWidget extends StatefulWidget{

  MainPageState state;

  BottomSheetWidget(this.state);

  @override
  State createState()=>BottomSheetWidgetState(this.state);

}

class BottomSheetWidgetState extends State<BottomSheetWidget>{

  MainPageState state;

  BottomSheetWidgetState(this.state);

  @override
  Widget build(BuildContext context) {
        return Container(
          decoration: new BoxDecoration(
            borderRadius: new BorderRadius.only(
              topRight: new Radius.circular(10),
              topLeft: new Radius.circular(10)
            ),
            color: Colors.white,
            border: new Border.all(
              color: Color(0xff967adc),
              width: 0.1
            )
          ),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: new Icon(
                  Icons.settings,
                  color: Color(0xff967adc),
                ),
                title: new Text(
                  "Settings",
                  style: new TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Color(0xff967adc) //0xff57187e
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                      context: context, barrierDismissible: true, builder: (_) {
                    return SettingsDialog(this.state);
                  });
                }
              ),
              new ListTile(
                leading: new Icon(
                  Icons.info,
                  color: Color(0xff967adc),
                ),
                title: new Text(
                  "Credits",
                  style: new TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color(0xff967adc)
                  ),
                ),
                onTap: (){
                  Navigator.pop(context);
                  print("Credits pressed");
                },
              )
            ],
          ),
        );
  }
}

class SettingsDialog extends StatefulWidget {
  State createState() => SettingsState(_content);

  MainPageState _content;

  SettingsDialog(this._content);
}

class SettingsState extends State<SettingsDialog> {
  MainPageState _content;
  DBhelper dBhelper = new DBhelper();

  SettingsState(this._content);

  @override
  void initState() {
    getTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(5),
      title: Container(
        padding: EdgeInsets.all(4),
        decoration: new BoxDecoration(
          color: typeColor(
              type: Constants.TYPE_SETTINGS_OR_CREDITS, theme: themeSharedPref),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.00),
              topRight: Radius.circular(32.00)),
        ),
        child: new Align(
          alignment: FractionalOffset.center,
          child: new Text(
            "Settings",
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32.00)),
      ),
      backgroundColor: mainBackColor(
          widget: Constants.WIDGET_LAYER_HIGH, theme: themeSharedPref),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Sound on/off:",
                    style: TextStyle(
                        color: typeColor(
                            type: Constants.TYPE_SETTINGS_OR_CREDITS,
                            theme: themeSharedPref),
                        fontWeight: FontWeight.w300,
                        fontSize: 16),
                  ),
                  Switch(
                    value: (soundSharedPref!=null)?soundSharedPref:true,
                    onChanged: (bool set) {
                      switchSound(set);
                    },
                    activeColor: typeColor(
                        type: Constants.TYPE_SETTINGS_OR_CREDITS,
                        theme: themeSharedPref),
                    inactiveTrackColor: Colors.deepPurple[200],
                  )
                ],
              ),
            ),
            new Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Auto type-switch",
                    style: TextStyle(
                        color: typeColor(
                            type: Constants.TYPE_SETTINGS_OR_CREDITS,
                            theme: themeSharedPref),
                        fontWeight: FontWeight.w300,
                        fontSize: 16),
                  ),
                  Switch(
                    value: (automaticTypeChanging!=null)?automaticTypeChanging:true,
                    onChanged: (bool set) {
                      setAutomaticTypeChanging(set);
                    },
                    activeColor: typeColor(
                        type: Constants.TYPE_SETTINGS_OR_CREDITS,
                        theme: themeSharedPref),
                    inactiveTrackColor: Colors.deepPurple[200],
                  )
                ],
              ),
            ),
            new Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Theme:",
                    style: TextStyle(
                        color: typeColor(
                            type: Constants.TYPE_SETTINGS_OR_CREDITS,
                            theme: themeSharedPref),
                        fontWeight: FontWeight.w300,
                        fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.brightness_5,
                              color: getThemeColor(true),
                              size: 30,
                            ),
                            Text(
                              "Light",
                              style: TextStyle(
                                  fontWeight: FontWeight.w200,
                                  fontSize: 10,
                                  color: (themeSharedPref ==
                                          Constants.THEME_DEFAULT)
                                      ? typeColor(
                                          type: Constants
                                              .TYPE_SETTINGS_OR_CREDITS,
                                          theme: themeSharedPref)
                                      : Colors.deepPurple[200]),
                            )
                          ],
                        ),
                        onTap: () {
                          setTheme(Constants.THEME_DEFAULT);
                          setThemeDatabase(Constants.THEME_DEFAULT);
                          themeSharedPref = Constants.THEME_DEFAULT;
                          setState(() {});
                          this._content.setState(() {});
                        },
                      ),
                      GestureDetector(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.brightness_3,
                              color: getThemeColor(false),
                              size: 30,
                            ),
                            Text(
                              "Dark",
                              style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontSize: 10,
                                color: (themeSharedPref ==
                                        Constants.THEME_DEFAULT)
                                    ? typeColor(
                                        type:
                                            Constants.TYPE_SETTINGS_OR_CREDITS,
                                        theme: themeSharedPref)
                                    : Colors.deepPurple[200],
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          setTheme(Constants.THEME_DARK);
                          setThemeDatabase(Constants.THEME_DARK);
                          themeSharedPref = Constants.THEME_DARK;
                          setState(() {});
                          this._content.setState(() {});
                        },
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  switchSound(bool sound) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(Constants.SHARED_SOUND, sound);
    soundSharedPref = sound;
  }

  Future<bool> getSound() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool sound = sharedPreferences.getBool(Constants.SHARED_SOUND);
    soundSharedPref = sound;
    return sound;
  }

  initialShared() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (!sharedPreferences.containsKey(Constants.SHARED_SOUND))
      await sharedPreferences.setBool(Constants.SHARED_SOUND, true);
    if (!sharedPreferences.containsKey(Constants.SHARED_THEME))
      await sharedPreferences.setInt(
          Constants.SHARED_THEME, Constants.THEME_DARK);
    if(!sharedPreferences.containsKey(Constants.SHARED_AUTO_TYPE_CHANGING))
      await sharedPreferences.setBool(Constants.SHARED_AUTO_TYPE_CHANGING, true);
  }

  setTheme(int theme) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt(Constants.SHARED_THEME, theme);
  }

  setThemeDatabase(int theme) async{

     dBhelper.setTheme(theme);
     print("Theme set $theme");

  }

  getTheme() async {
    themeSharedPref = await dBhelper.getTheme();
  }


  void setAutomaticTypeChanging(bool auto) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(Constants.SHARED_AUTO_TYPE_CHANGING, auto);
    automaticTypeChanging = auto;
  }

  Future<bool> getAutomaticTypeChanging() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool automatic = sharedPreferences.getBool(Constants.SHARED_AUTO_TYPE_CHANGING);
    automaticTypeChanging = automatic;
    return automatic;
  }

  Color getThemeColor(bool isLight) {
    if (isLight) if (themeSharedPref == Constants.THEME_DEFAULT)
      return typeColor(
          type: Constants.TYPE_SETTINGS_OR_CREDITS, theme: themeSharedPref);
    else
      return Colors.white;
    else {
      if (themeSharedPref == Constants.THEME_DARK)
        return typeColor(
            type: Constants.TYPE_SETTINGS_OR_CREDITS, theme: themeSharedPref);
      else
        return Colors.black;
    }
  }


}
