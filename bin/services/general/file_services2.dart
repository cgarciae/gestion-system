part of aristadart.server;

@Injectable()
class FileServices2 extends RethinkServices<FileDb> {

  FileServices2(InjectableRethinkConnection irc) : super.fromInjectableConnection (Col.files, irc);

  Future<FileDb> upload (Map form, FileDb metadata,
      {String id, String ownerId}) async {
    HttpBodyFileUpload fileUpload = extractFile(form);

    if (fileUpload == null ||
        fileUpload.content == null ||
        fileUpload.content.length == 0) throw new app.ErrorResponse(
            400, {'error': "file is null or empty"});

    if (id != null) metadata.id = id;

    if (ownerId != null) metadata.owner = new User()..id = ownerId;

    if (metadata.contentType == null) metadata.contentType = fileUpload.contentType.value;
    if (metadata.filename == null) metadata.filename = fileUpload.filename;

    Map resp = await insertNow(metadata);
    if (resp['inserted'] == 0) throw new app.ErrorResponse(
        400, {'error': "filedb no se inserto"});

    metadata.id = resp['generated_keys'].first;

    String fileId = resp['generated_keys'].first;
    var file = new File('${path.current}/${Col.files}/$fileId');

    await file.writeAsBytes(fileUpload.content);

    return metadata;
  }

  Future<shelf.Response> getFile (String id) async {
    var metadata = await getNow(id);

    var file = new File("${path.current}/${Col.files}/$id");
    return new shelf.Response.ok(file.openRead(), headers: {"Content-Type": metadata.contentType});
  }





  Future Get(String id) async {
    GridOut gridOut = await fs.findOne(where.id(StringToId(id)));

    if (gridOut == null) throw new app.ErrorResponse(
        400, "El archivo no existe");

    return new shelf.Response.ok(getData(gridOut),
        headers: {"Content-Type": gridOut.contentType});
  }

  @app.Route('/:id/metadata', methods: const [app.GET])
  //@Private()
  @Encode()
  Future<FileDb> GetMetadata(String id) async {
    if (id == null) throw new app.ErrorResponse(
        400, "No se pudo obtener metadata: id null");

    GridOut gridOut = await fs.findOne(where.id(StringToId(id)));

    if (gridOut == null) throw new app.ErrorResponse(
        400, "El archivo no existe");

    return mongoDb.decode(gridOut.metaData, FileDb);
  }

  @app.Route('/:id', methods: const [app.PUT], allowMultipartRequest: true)
  //@Private()
  @Encode()
  Future<FileDb> Update(String id, @app.Body(app.FORM) Map form,
      {String ownerId}) async {
    FileDb metadata = await GetMetadata(id);
    Ref obj = await Delete(id);
    FileDb fileDb = await New(form, metadata, id: id, ownerId: ownerId);

    return fileDb;
  }

  @app.Route('/:id', methods: const [app.DELETE])
  //@Private()
  @Encode()
  Future<Ref> Delete(String id) async {
    await deleteFile(id);

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
