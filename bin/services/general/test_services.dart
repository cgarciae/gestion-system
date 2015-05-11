part of aristadart.server;

@PrintHeaders()
@app.Route ('/cookies')
cookie ()
{
    var cookie = app.request.headers['cookie'];
    return new shelf.Response.ok (cookie, headers: {'set-cookie':'ID=2; Path=/; HttpOnly'});
}

@app.Route ('/testPATCH', methods: const['PATCH',app.POST])
testPatch () => "OK";

@mvc.DataController ('/testUltimas')
testUlitmas (@Inject() InjectableRethinkConnection irc) async {
  var noticiaServices = new NoticiaServices(irc);
  await noticiaServices.newNoticia();
  await noticiaServices.newNoticia();
  await noticiaServices.newNoticia();
  await noticiaServices.newNoticia();

  return noticiaServices.ultimas(3);
}

@mvc.DataController('/testGenericAll')
testGenericAll (@Inject() RestFileServices restFileServices) {
  return restFileServices.genericAll();
}

class PrintHeaders
{
    const PrintHeaders();
}
void PrintHeadersPlugin(app.Manager manager) {
    
    
    manager.addRouteWrapper(PrintHeaders, (metadata, Map<String,String> pathSegments, injector, 
                                        app.Request request, app.RouteHandler route) async {
        
        var res = route(pathSegments, injector, request);
        
        print (app.response.headers);
        
        return res;
    
  }, includeGroups: true);
}

