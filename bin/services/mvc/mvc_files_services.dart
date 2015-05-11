part of aristadart.server;

@mvc.GroupController('/${Col.files}', root: "/web/template")
class MvcFileServices extends FileServices2 {

  MvcFileServices(InjectableRethinkConnection irc): super (irc);

  @mvc.DataController ('/:id', methods: const[app.GET])
  Future<shelf.Response> downloadFile(String id) => super.downloadFile(id);

  @mvc.DefaultViewController(methods: const [app.GET], filePath: "/Images")
  Future<List<FileDb>> getFiles() async{
    return genericAll();
  }
}