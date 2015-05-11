part of aristadart.server;

@mvc.GroupController('/api/${Col.files}/v1')
class RestFileServices extends FileServices2 {

  RestFileServices(InjectableRethinkConnection irc): super (irc);

  @mvc.DefaultDataController (methods: const[app.POST], allowMultipartRequest: true)
  Future<FileDb> newFile(@app.Body(app.FORM) QueryMap form, @Decode(fromQueryParams: true) FileDb metadata) async {
    HttpBodyFileUpload fileUpload = extractFileUpload(form);
    metadata.contentType = fileUpload.contentType.value;
    metadata.filename = fileUpload.filename;
    metadata = await insertMetadata(metadata);
    writeFile(metadata.id, fileUpload.content);
    return metadata;
    //TODO: Usar los metodos de la clase padre 'writeFile' y 'insertMetadata', antes de insertar metadata, asignarle el filename y el contentType desde la info de fileUpload
  }

  @mvc.DataController('/:id', methods: const [app.GET])
  Future<shelf.Response> getFile(String id){
    return super.downloadFile(id);
  }

}