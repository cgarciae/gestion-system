part of aristadart.server;

@Injectable()
class FileServices2 extends GenericRethinkServices<FileDb> {

  FileServices2(InjectableRethinkConnection irc) : super (Col.files, irc);

  Future writeFile (String id, List<int> data) async {
    var file = new File('${path.current}/${Col.files}/$id');
    await file.writeAsBytes(data);
  }

  Stream<List<int>> readFile (String id) async * {
    var file = new File("${path.current}/${Col.files}/$id");
    yield * file.openRead();
  }

  Future<shelf.Response> downloadFile (String id) async {
    var metadata = await getMetadata(id);
    return new shelf.Response.ok(readFile(id), headers: {"Content-Type": metadata.contentType});
  }

  Future<FileDb> insertMetadata (FileDb metadata) async {
    var resp = await insertNow(metadata);

    if (resp['inserted'] == 0)
      throw new app.ErrorResponse (400, {'error': 'Metadata no insertada'});

    return metadata..id = resp['generated_keys'].first;
  }

  Future<FileDb> getMetadata(String id) async {
    var metadata = await getNow(id);
    if (metadata == null) throw new app.ErrorResponse(
        400, "El archivo no existe");
    return metadata;
  }

  Future<FileDb> updateMetadata (String id, FileDb delta) async {
    Map resp = await updateNow(id, delta);
    return getMetadata(id);
  }

  Future deleteFile(String id) async {
    var file = new File("${path.current}/${Col.files}/$id");
    await file.delete();
  }

  Future deleteMetadata(String id) async {
    return deleteNow(id);
  }

}