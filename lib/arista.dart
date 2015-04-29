library aristadart.general;

import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_mongo/metadata.dart';
//import 'package:redstone/query_map.dart';
import 'dart:convert';
import "package:googleapis_auth/auth.dart" as auth;

part 'models/user.dart';
part 'models/producto.dart';
part 'models/home.dart';
part 'models/sitio.dart';
part 'models/categoria.dart';
part 'models/noticia.dart';
part 'models/imagen_slider.dart';
part 'models/file.dart';
part 'models/json_access_credentials.dart';

const int tipoBuild = TipoBuild.desarrollo;

int get port => 9090;

String get staticFolder {
    switch (tipoBuild)
    {
        case TipoBuild.desarrollo:
            return "web";
        case TipoBuild.jsTesting:
            return "build/web";
        case TipoBuild.dockerTesting:
        case TipoBuild.deploy:
            return "build/web";
    }
}

String get partialHost {
    switch (tipoBuild)
    {
        case TipoBuild.desarrollo:
        case TipoBuild.jsTesting:
            return "localhost:9090";
        case TipoBuild.dockerTesting:
            return "192.168.59.103:9090";
        case TipoBuild.deploy:
            return "104.131.109.228";
    }
}



String get localHost => "http://${partialHost}/";

String get partialDBHost {
    switch (tipoBuild)
    {
        case TipoBuild.desarrollo:
        case TipoBuild.jsTesting:
            return "192.168.59.103:8095";
        case TipoBuild.dockerTesting:
        case TipoBuild.deploy:
            return "db";
    }
}

class TipoBuild
{
    static const int desarrollo =  0;
    static const int jsTesting =  1;
    static const int dockerTesting =  2;
    static const int deploy =  3;
}


class Ref
{
    @Id() String id;
    String get href => "IMPLEMENTATION MISSING";
}


class BoolResp
{
    @Field() bool value = true;
}

class StringResp
{
    @Field() String string;
}



abstract class Header
{
    static const String contentType = 'Content-Type';
    static const String authorization = 'Authorization';
}

abstract class ContType
{
    static const String applicationJson = r"application/json";
    static const String multipart = "multipart";
    static const String imagePng = r"image/png";
}

abstract class Method
{
    static final String POST = "POST";
    static final String PUT = "PUT";
    static final String GET = "GET";
    static final String DELETE = "DELETE";
}

abstract class Col
{
    static const String user = 'user';
    static const String evento = 'evento';
    static const String vista = 'vista';
    static const String cloudTarget = 'cloudTarget';
    static const String objetoUnity = 'objetoUnity';
    static const String localTarget = 'localTarget';
    static const String file = "file";
    static const String noticia = "noticia";
    static const String home = "home";
    static const String sitio = "sitio";
}

abstract class ErrCode
{
    static final int NOTFOUND = 1;
}

abstract class IconDir
{
    static const String missingImage = "images/webapp/missing_image.png";
    static const String icon3D = "images/webapp/3D.png";
}

//FUNCTIONS
bool notNullOrEmpty (String s) => ! (s == null || s == '');
bool nullOrEmpty (String s) => ! notNullOrEmpty (s);
List flatten (List<List> list) => list.expand((x) => x).toList();
dynamic Cast (Type type, Object obj) => decode (encode(obj), type);
dynamic Clone (Object obj) => decode (encode(obj), obj.runtimeType);

Function decodeTo (Type type)
{
    return (String json)
    {
        return decodeJson(json, type);
    };
}

Function MapToObject (Type type) => (Map map)
{
    return decodeJson(JSON.encode(map), type);
};

Map ObjectToMap (dynamic obj)
{
    return JSON.decode (encodeJson (obj));
}

Map addOrSet (Map headers, Map additions)
{   
    if (headers != null)
        headers.addAll (additions);
    else
        headers = additions;
    
    return headers;
}

Map maybeAdd (Map map, String field, Object value)
{
    if (value != null)
        map [field] = value;
    
    return map;
}