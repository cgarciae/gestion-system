part of aristadart.client;


class ClientNoticiaServices extends ClientService<Noticia>
{
    ClientNoticiaServices (Requester requester) : super (Col.noticia, requester);
    
    //private
    Future<Noticia> New () async
    {
        return private
        (
            Method.POST, pathBase
        );
    }
    
    Future<Noticia> Get (String id)
    {
        return decoded
        (
            Method.GET,
            href(id)
        );
    }

    //private
    Future<Noticia> Update (String id, /*JSON*/ Noticia delta) async
    {
        return UpdateGeneric (id, delta);
    }
    
    //private
    Future<Ref> Delete (String id)
    {
        return DeleteGeneric(id);
    }
    
    //private
    Future<List<Noticia>> Ultimas (/*Query Param*/int n) async
    {
        return requester.decoded(Noticia, Method.GET, "$pathBase/ultimas");
    }
}



