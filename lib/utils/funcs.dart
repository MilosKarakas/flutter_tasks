import 'package:flutter/material.dart';
import 'package:flutter_tasks/utils/const.dart';

//todo promjeniti nijansu plave i zelene kada je dark mod namjesten jer ne rade dobro
//todo namjestiti boju kartica na pocetnom da idu u skladu sa temiranjem sto se tice pozadine da ne ostaju bijele uvijek

Color typeColor({int type, int theme}){

  if(theme==Constants.THEME_DEFAULT) {
    switch(type){
      case Constants.TYPE_DO:
        return Color(0xffe9573f); //0xffc21807
      case Constants.TYPE_DOING:
        return Color(0xfff6bb42); //0xffe1ad01
      case Constants.TYPE_DONE:
        return Color(0xff8cc152); //0xff84c011
      case Constants.TYPE_NOTES:
        return Color(0xff4a89dc); //0xff111e6c
      default:
        return Color(0xff967adc); //0xff57187e
        break;
    }
  } else if(theme==Constants.THEME_DARK){
    switch(type){
      case Constants.TYPE_DO:
        return Color(0xffe9573f); //0xffc21807
      case Constants.TYPE_DOING:
        return Color(0xfff6bb42); //0xffe1ad01
      case Constants.TYPE_DONE:
        return Color(0xff8cc152); //0xff84c011
      case Constants.TYPE_NOTES:
        return Color(0xff4a89dc); //0xff111e6c
      default:
        return Color(0xff967adc); //0xff57187e
        break;
    }
  }
  else
    return Colors.black;

}

AssetImage loadingGif({int type}){
  switch(type){
    case Constants.TYPE_DO:
      return AssetImage("lib/images/loading_red.gif");
    case Constants.TYPE_DOING:
      return AssetImage("lib/images/loading_yellow.gif");
    case Constants.TYPE_DONE:
      return AssetImage("lib/images/loading_green.gif");
    case Constants.TYPE_NOTES:
      return AssetImage("lib/images/loading_blue.gif");
    default:
      return AssetImage("lib/images/loading_purple.gif");
  }
}

Color backColor(int type,) {

  switch (type) {
    case Constants.TYPE_DO :
      return Colors.deepOrange[50];
      break;
    case Constants.TYPE_DOING :
      return Colors.amber[50];
      break;
    case Constants.TYPE_DONE :
      return Colors.green[50];
      break;
    case Constants.TYPE_NOTES :
      return Colors.blue[50];
      break;
    default:
      return Colors.deepPurple[50];
      break;
  }

}

Color mainBackColor({int widget, int theme}){

  switch(theme){
    case Constants.THEME_DEFAULT:
      return Colors.white;
      break;
    case Constants.THEME_DARK:
      switch(widget){
        case Constants.WIDGET_LAYER_BOTTOM:
          return Colors.grey[900];
          break;
        case Constants.WIDGET_LAYER_MIDDLE:
          return new Color(0xff303030);
          break;
        case Constants.WIDGET_LAYER_HIGH:
          return Colors.grey[800];
          break;
        default:
          return Colors.black;
          break;
      }
      break;
    default:
      return Colors.black;
      break;
  }

}

Color dialogColor(int type) {
  switch (type) {
    case Constants.TYPE_DO :
      return Colors.redAccent;
      break;
    case Constants.TYPE_NOTES :
      return Colors.blueAccent;
      break;
    default:
      return Colors.deepPurple[50];
      break;
  }
}


