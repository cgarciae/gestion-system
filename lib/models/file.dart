part of aristadart.general;

class FileDb extends Ref
{
    @Field() String get href => id != null ? localHost + 'file/$id' : null;
    @Field() String system;
    @Field() String filename;
    @Field() String type;
    @Field() User owner;
}

abstract class SystemType
{
    static const String ios = "ios";
    static const String osx = "osx";
    static const String windows = "windows";
    static const String android = "android";
}

abstract class LocalTargetFileType
{
    static const String xml = "xml";
    static const String dat = "dat";
}

abstract class FileDbType
{
    static const String imagen = "imagen";
    static const String objetoUnity = "objetoUnity";
    static const String dat = "dat";
    static const String xml = "xml";
}