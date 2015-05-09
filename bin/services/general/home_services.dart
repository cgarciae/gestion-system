part of aristadart.server;

@app.Group('/${Col.home}')
@Catch()
@Encode()
class HomeServices extends AristaService<Home>
{
    HomeServices (MongoService mongoDb) : super (Col.home, mongoDb);
    
    @app.DefaultRoute (methods: const [app.GET])
    @Private(ADMIN)
    Future<Home> Get () async
    {
        var home = await findOne ();
        
        if (home == null)
        {
            home = new Home()
                ..id = newId()
                ..slider = []
                ..productosDestacado = [];
            
            insert (home);
        }
        
        return home;
    }
    
    @app.DefaultRoute (methods: const [app.PUT])
    @Private(ADMIN)
    Future<Home> Update (@Decode() Home delta) async
    {
        var home = await Get();
        
        delta.id = null;
        delta.productosDestacado = null;
        
        try {
          await update (
            where.id(StringToId(home.id)),
            delta,
            override: false
          );
        }
        catch (e, s) {
          await mongoDb.update (
              collectionName,
              where.id(StringToId(home.id)),
              getModifierBuilder (delta, mongoDb.encode)
          );
        }
        
        return Get();
    }
    
    
    @app.Route ('/productoDestacado', methods: const [app.POST])
    Future<BoolResp> agregarProductoDestacado (Producto producto)
    {
      throw new UnimplementedError();
    }
    
    @app.Route ('/productoDestacado', methods: const [app.DELETE])
    Future<BoolResp> eliminarProductoDestacado (Producto producto)
    {
      throw new UnimplementedError();
    }
}



