part of aristadart.server;

@app.Group('/${Col.sitio}')
@Catch()
@Encode()
class SitioServices extends AristaService<Sitio>
{
    SitioServices (MongoService mongoDb) : super (Col.sitio, mongoDb);
    
    @app.DefaultRoute (methods: const [app.POST])
    @Private(ADMIN)
    Future<Sitio> New ({@app.QueryParam() String nombre: "Nuevo Sitio"})
    {
        var sitio = new Sitio()
            ..categorias = []
            ..descripcion = "Descripcion"
            ..categoriasDestacadas = []
            ..id = newId()
            ..nombre = nombre
            ..slider = []
            ..productosDestacados = [];
        
        return NewGeneric(sitio);
    }
    
    @app.Route ('/:id', methods: const [app.GET])
    @Private(ADMIN)
    Future<Sitio> Get (String id, {@app.QueryParam() bool export: false}) async
    {
        if (export == true)
        {
            throw new UnimplementedError();
        }
        else
        {
            return GetGeneric(id);
        }
    }
    
    @app.Route ('/:id', methods: const [app.PUT])
    @Private(ADMIN)
    Future<Sitio> Update (String id, Sitio delta) async
    {
        delta.id = null;
        
        await UpdateGeneric(id, delta);
        
        return Get (id);
    }
    
    //DELETE /:id ::
    @app.Route ('/:id', methods: const [app.DELETE])
    @Private(ADMIN)
    Future<Ref> Delete (String id)
    {
        return DeleteGeneric (id);
    }
    
    @app.Route ('/:id/imagenSlider', methods: const [app.POST])
    @Private(ADMIN)
    Future<ImagenSlider> AgregarImagenSlider (String id) async {
      var imagen = new ImagenSlider()
        ..id = newId()
        ..caption = "Caption";
      
        await mongoDb.update
        (
            collectionName,
            where.id(StringToId(id)),
            modify.push ("slider", mongoDb.encode(imagen))
        );
        
        return imagen;
    }
    
    @app.Route ('/:id/eliminarImagenSlider', methods: const [app.DELETE])
    @Private(ADMIN)
    Future<BoolResp> EliminarImagenSlider (String id, ImagenSlider imagen) async
    {
        await mongoDb.update
        (
            collectionName,
            where.id(StringToId(id)),
            {r'$pull': {'slider': {'_id': StringToId(imagen.id)}}}
        );
        
        return new BoolResp()
            ..value = true;
    }

    Future<BoolResp> AgregarCategoria (String id, Categoria categoria) async
    {
        categoria = new Categoria()
            ..id = categoria.id;
        
        await mongoDb.update
        (
            collectionName,
            where.id(StringToId(id)), 
            modify.push ("categorias", mongoDb.encode(categoria))
        );
        
        return new BoolResp()
            ..value = true;
    }

    Future<BoolResp> EliminarCategoria (String id, Categoria categoria) async
    {
        await mongoDb.update
        (
            collectionName,
            where.id(StringToId(id)), 
            {
                r'$pull': {'categorias': {'_id': StringToId (categoria.id)}}
            }
        );
        
        return new BoolResp()
            ..value = true;
    }
    
    Future<BoolResp> AgregarCategoriaDestacada (String id, Categoria categoria) async
    {
        categoria = new Categoria()
            ..id = categoria.id;
        
        await mongoDb.update
        (
            collectionName,
            where.id(StringToId(id)), 
            modify.push ("categoriasDestacadas", mongoDb.encode(categoria))
        );
        
        return new BoolResp()
            ..value = true;
    }
    
    Future<BoolResp> EliminarCategoriaDestacada (String id, Categoria categoria) async
    {
        await mongoDb.update
        (
            collectionName,
            where.id(StringToId(id)),
            {r'$pull': {'categoriasDestacadas': {'_id': StringToId (categoria.id)}}}
        );
        
        return new BoolResp()
            ..value = true;
    }
    
    Future<BoolResp> AgregarProductoDestacado (String id, Producto producto) async
    {
      Map productoAgregar = mongoDb.encode(new Producto()
                                            ..id = producto.id);
      await mongoDb.update
      (
        collectionName,
        where.id(StringToId(id)),
        modify.push('productosDestacados', productoAgregar)
      );
      
      return new BoolResp();
    }
    
    Future<BoolResp> EliminarProductoDestacado (String id, Producto producto) async
    {
      await mongoDb.update(
        collectionName,
        where.id(StringToId(id)),
        modify.pull('productosDestacados', {'_id': StringToId (producto.id)})
      );
      
      return new BoolResp();
    }
}

