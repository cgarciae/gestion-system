part of aristadart.server;

@app.Group('/${Col.noticia}')
@Encode()
class NoticiaServices extends AristaService<Noticia>
{
    NoticiaServices (MongoService mongoDb) : super (Col.noticia, mongoDb);
    
    @app.DefaultRoute (methods: const [app.POST])
    @Private(ADMIN)
    Future<Noticia> New () async
    {
        var noticia = new Noticia()
            ..id = newId()
            ..titulo = "Titulo"
            ..texto = "Texto";
        
        return NewGeneric (noticia);
    }
    
    @app.Route ('/:id', methods: const [app.GET])
    Future<Noticia> Get (String id)
    {
        return GetGeneric (id);
    }
    
    @app.Route ('/:id', methods: const [app.PUT])
    @Private(ADMIN)
    Future<Noticia> Update (String id, @Decode() Noticia delta) async
    {
        await UpdateGeneric(id, delta);
        
        return Get(id);
    }
    
    @app.Route ('/:id', methods: const [app.DELETE])
    @Private (ADMIN)
    Future<Ref> Delete (String id)
    {
        return DeleteGeneric (id);
    }
    
    @app.Route ('/ultimas', methods: const [app.GET])
    Future<List<Noticia>> Ultimas (@app.QueryParam() int n) async
    {
        var cursor = mongoDb.innerConn
                    .collection (collectionName)
                    .find(where.sortBy('_id', descending: true))
                    ..limit = 5;
                
        List<Map> list = await cursor.toList();
        
        return list.map ((Map map) => mongoDb.decode (map, Noticia)).toList();
    }
}



