part of aristadart.server;

@PrintHeaders()
@app.Route ('/cookies')
cookie ()
{
    var cookie = app.request.headers['cookie'];
    return new shelf.Response.ok (cookie, headers: {'set-cookie':'ID=2; Path=/; HttpOnly'});
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

