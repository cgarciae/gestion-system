part of aristadart.server;

@Injectable()
class FileServices2 extends RethinkServices<FileDb> {

  FileServices2(InjectableRethinkConnection irc) : super.fromInjectableConnection (Col.files, irc);

  Future<FileDb> upload (Map form, FileDb metadata) async {
    HttpBodyFileUpload fileUpload = extractFile(form);

    if (fileUpload == null ||
        fileUpload.content == null ||
        fileUpload.content.length == 0) throw new app.ErrorResponse(
            400, {'error': "file is null or empty"});

    if (metadata.contentType == null) metadata.contentType = fileUpload.contentType.value;
    if (metadata.filename == null) metadata.filename = fileUpload.filename;

    Map resp = await insertNow(metadata);
    if (resp['inserted'] == 0) throw new app.ErrorResponse(
        400, {'error': "filedb no se inserto"});

    metadata.id = resp['generated_keys'].first;


    return metadata;
  }

  Future writeFile (String id, List<int> data) async {
    var file = new File('${path.current}/${Col.files}/$fileId');
    await file.writeAsBytes(data);
  }

  Stream<List<int>> readFile (String id) async * {
    var file = new File("${path.current}/${Col.files}/$id");
    yield * file.openRead();
  }

  shelf.Response downloadFile (String id) async {
    var metadata = await getMetadata(id);
    new shelf.Response.ok(readFile(id), headers: {"Content-Type": metadata.contentType});
  }


  Future<FileDb> getMetadata(String id) async {
    var metadata = await getNow(id);
    if (gridOut == null) throw new app.ErrorResponse(
        400, "El archivo no existe");
    return metadata;
  }

  Future<FileDb> updateMetadata (String id, FileDb delta) async {
    Map resp = await updateNow(id, delta);
    return getMetadata(id);
  }


  Future deleteFile(String id) async {
    var file = new File("${path.current}/${Col.files}/$id");
    await file.delete()
    return new Ref()..id = id;
  }

  @app.Route('/all', methods: const [app.GET])
  //@Private()
  @Encode()
  Future All(@app.QueryParam('type') String type) async {
    Stream<QueryMap> stream = fs.files
            .find(where.eq("metadata.owner._id", StringToId(userId))).stream
        .map(MapToQueryMap);

    if (type != null) stream = stream.where(
        (QueryMap file) => (file.contentType as String).contains(type) ||
            file.metadata.type == type);

    return stream
        .map((QueryMap file) => mongoDb.decode(file.metadata, FileDb))
        .toList();
  }

  @app.Route('/allImages', methods: const [app.GET])
  //@Private()
  @Encode()
  Future AllImages() async {
    return All('image');
  }

  Future<List<dynamic>> deleteFile(String id) {
    var fileId = StringToId(id);

    var removeFiles = fs.files.remove(where.id(fileId));
    var removeChunks = fs.chunks.remove(where.eq('files_id', fileId));

    return Future.wait([removeChunks, removeFiles]);
  }

  Stream<List<int>> getData(GridOut gridOut) {
    var controller = new StreamController<List<int>>();
    var sink = new IOSink(controller);
    gridOut.writeTo(sink).then((n) => sink.close());
    return controller.stream;
  }
}
