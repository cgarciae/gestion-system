part of aristadart.server;

String encryptPassword(String pass) {
  var toEncrypt = new SHA1();
  toEncrypt.add(UTF8.encode(pass));
  return CryptoUtils.bytesToHex(toEncrypt.close());
}

QueryMap NewQueryMap () => new QueryMap(new Map());
QueryMap MapToQueryMap (Map map) => new QueryMap(map);

ObjectId StringToId (String id) => new ObjectId.fromHexString(id);
String newId () => new ObjectId().toHexString();

HttpSession get session => app.request.session;



String get userId => app.request.headers.authorization;
set userId (String value) => app.request.headers.authorization = value;

const int ADMIN = 1;


HttpBodyFileUpload extractFile (Map form)
=> form.values.where((value) => value is HttpBodyFileUpload).first;

Future<Map> streamResponseToJSON (http.StreamedResponse resp)
{
  return resp.stream.toList()
  .then (flatten)
  .then (bytesToJSON);
}

Future<dynamic> streamResponseDecoded (Type type, http.StreamedResponse resp) async
{
  Map json = await streamResponseToJSON (resp);
  return decode(json, type);
}

String md5hash (String body)
{
  var md5 = new crypto.MD5()
    ..add(conv.UTF8.encode (body));

  return crypto.CryptoUtils.bytesToHex (md5.close());
}

String base64_HMAC_SHA1 (String hexKey, String stringToSign)
{

  var hmac = new crypto.HMAC(new crypto.SHA1(), conv.UTF8.encode (hexKey))
    ..add(conv.UTF8.encode (stringToSign));

  return crypto.CryptoUtils.bytesToBase64(hmac.close());
}

Future<List<dynamic>> deleteFiles (GridFS fs, dynamic fileSelector)
{
  return fs.files.find (fileSelector).toList().then((List<Map> list)
  {
    return list.map((map) => map['_id']).toList();
  })
  .then((List list)
  {
    var removeFiles = fs.files.remove(where.oneFrom('_id', list));
    var removeChunks = fs.chunks.remove(where.oneFrom('files_id', list));

    return Future.wait([removeChunks, removeFiles]);
  });

}

String bytesToString (List<int> list)
{
  return conv.UTF8.decode (list);
}

Map bytesToJSON (List<int> list)
{
  var string = conv.UTF8.decode (list);
  var map = conv.JSON.decode (string);

  return map;
}

Future<dynamic> streamedResponseToObject (Type type, http.StreamedResponse resp) async
{
  String json = await resp.stream.toList()
  .then (flatten)
  .then(bytesToString);

  return decodeJson(json, type);
}


ModifierBuilder getModifierBuilder (Object obj, dynamic encoder (dynamic obj))
{
  Map<String, dynamic> map = encoder (obj);

  map = cleanMap (map);

  Map mod = {r'$set' : map};

  return new ModifierBuilder()
    ..map = mod;
}

dynamic cleanMap (dynamic json)
{
  if (json is List)
  {
    return json.map (cleanMap).toList();
  }
  else if (json is Map)
  {
    var map = {};
    for (String key in json.keys)
    {
      var value = json[key];

      if (value == null)
        continue;

      if (value is List || value is Map)
        map[key] = cleanMap (value);

      else
        map[key] = value;
    }
    return map;
  }
  else
  {
    return json;
  }
}