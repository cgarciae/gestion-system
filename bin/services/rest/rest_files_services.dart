part of aristadart.server;

@mvc.GroupController('/api/${Col.files}/v1')
class RestFileServices extends FileServices2 {

  RestFileServices(InjectableRethinkConnection irc): super (irc);

  @app.DefaultRoute (methods: const[app.POST], allowMultipartRequest: true)
  @Encode()
  Future<FileDb> newFile(@app.Body(app.FORM) QueryMap form, @Decode(fromQueryParams: true) FileDb metadata) async {
    getT
  }
}