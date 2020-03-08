import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_tasks/sql/database.dart';
import 'package:flutter_tasks/model/image-model.dart';
import 'package:flutter_tasks/utils/funcs.dart';
import 'package:flutter_tasks/utils/const.dart';

class Gallery extends StatefulWidget{

  int initialIndex = 0;
  int type;
  int theme;
  List<String> paths = [];
  List<ImageModel> models = [];

  @override
  State createState()=>new GalleryState(initial: initialIndex, paths: paths, models: models, type: type, theme: theme);
  
  Gallery({int initial, List<String> paths, List<ImageModel> models, int type, int theme}){
    initialIndex = initial;
    this.paths = paths;
    this.models = models;
    this.type = type;
    this.theme = theme;
  }
  
}

class GalleryState extends State<Gallery> {

  DBhelper localDatabase = new DBhelper();
  int initialIndex = 0,
      currentIndex = 0;
  int type = 0;
  int theme;
  List<String> paths = [];
  List<ImageModel> models = [];


  @override
  void initState() {
    for(String path in paths) {
      precacheImage(new FileImage(File(path)), context);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: mainBackColor(widget: Constants.WIDGET_LAYER_BOTTOM, theme: theme),
      appBar: AppBar(
        elevation: 0,
        actions: <Widget>[
          IconButton(icon: new Icon(Icons.delete_outline, color: typeColor(type: type, theme: Constants.THEME_DEFAULT)),
            onPressed: () {
              deleteImage(context, models[currentIndex]);
              if(models.length==0)
                Navigator.pop(context);
              setState(() {
                if (currentIndex > 1) {
                  currentIndex--;
                  initialIndex = currentIndex;
                } else {
                  currentIndex = 0;
                  initialIndex = currentIndex;
                }
              });
            },)
        ],
        backgroundColor: Colors.transparent,
        iconTheme: new IconThemeData(color: typeColor(type: type, theme: Constants.THEME_DEFAULT)),
      ),
      body: PhotoViewGallery.builder(
        backgroundDecoration: new BoxDecoration(color: mainBackColor(theme: theme, widget: Constants.WIDGET_LAYER_BOTTOM)),
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          models[index].elementId = index;

          return PhotoViewGalleryPageOptions(
            imageProvider: new FileImage(new File(models[index].url)),
            initialScale: PhotoViewComputedScale.contained,
            heroAttributes: PhotoViewHeroAttributes(tag: models[index].url),
          );
        },
        itemCount: models.length,
        loadingChild: new Center(
          child: new FractionallySizedBox(
            widthFactor: 0.34,
            heightFactor: 0.34,
            child: /*new CircularProgressIndicator(
              strokeWidth: 1,
              valueColor: AlwaysStoppedAnimation<Color>(typeColor(type: type, theme: theme)),
            )*/ Image(
              image: loadingGif(type: type),
            ),
          ),
        ),
        pageController: new PageController(initialPage: initialIndex),
        onPageChanged: (index) {
          currentIndex = index;
          initialIndex = index;
        },
      ),
    );
  }

  GalleryState({int initial, List<String> paths, List<ImageModel> models, int type, int theme}) {
    this.initialIndex = initial;
    this.currentIndex = initial;
    this.paths = paths;
    this.models = models;
    this.type = type;
    this.theme = theme;
  }

  void deleteImage(BuildContext context, ImageModel model) async {
    localDatabase.removeElementImageByUrl(model);
    models.removeWhere((mod) => (mod.elementId == model.elementId));
  }
}