part of aristadart.server;

@mvc.GroupController('/${Col.files}')
class MvcFileServices extends FileServices2 {

  MvcFileServices(InjectableRethinkConnection irc): super (irc);

  @mvc.DataController ('/:id', methods: const[app.GET])
  Future<shelf.Response> getFile(String id)
    => super.getFile(id);


}