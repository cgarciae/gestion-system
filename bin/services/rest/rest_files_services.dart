part of aristadart.server;

@mvc.GroupController('/api/${Col.files}/v1')
class RestFileServices extends FileServices2 {

  RestFileServices(InjectableRethinkConnection irc): super (irc);

  @app.DefaultRoute (methods: const[app.POST], allowMultipartRequest: true)
  @Encode()
  Future<FileDb> newFile(@app.Body(app.FORM) QueryMap form, @Decode(fromQueryParams: true) FileDb metadata) async {
    HttpBodyFileUpload fileUpload = extractFileUpload(form);
    metadata.contentType = fileUpload.contentType.value;
    metadata.filename = fileUpload.filename;
    metadata = await insertMetadata(metadata);
    writeFile(metadata.id, fileUpload.content);
    return metadata;
    //TODO: Usar los metodos de la clase padre 'writeFile' y 'insertMetadata', antes de insertar metadata, asignarle el filename y el contentType desde la info de fileUpload
  }
}