part of aristadart.tests;

sitioServicesTests ()
{
    MongoDbManager dbManager = new MongoDbManager("mongodb://${dbHost}/servicesTesting");
    MongoDb db;
    MongoService mongoService;
    SitioServices sitioServices;
    group("Sitio Services Tests:", ()
    {
        setUp(() async
        {
            db = await dbManager.getConnection();
            mongoService = new MongoServiceMock.spy (new MongoService.fromMongoDb(db));
            sitioServices = new SitioServices (mongoService);
        });

        //remove all loaded handlers
        tearDown(() async
        {
            await db.innerConn.collection(Col.sitios).drop();
            dbManager.closeConnection (db);
        });
        
        test("New", () async
        {
            var sitio = await sitioServices.New();
            
            expect (sitio.descripcion != null, true);
            expect (sitio.categorias, []);
            expect (sitio.id != null, true);
            expect (sitio.categoriasDestacadas, []);
        });
        
        test("Get", () async
        {
            //Nuevo Sitio
            var sitio = await sitioServices.New();
            
            //Get
            var sitioGet = await sitioServices.Get (sitio.id);
            
            expect (encode(sitio), encode(sitioGet));
        });
        
        test("Update", () async
        {
            //Nuevo Sitio
            var sitio = await sitioServices.New();
            
            //Actualizar Sitio
            var actualizacion = "AAA";
            var sitioActualizado = await sitioServices.Update(sitio.id, new Sitio()..descripcion = actualizacion);
            
            expect (sitio.id, sitioActualizado.id);
            expect(sitioActualizado.descripcion, actualizacion);
        });
        
        test("Delete", () async
        {
            //Nuevo Sitio
            var sitio = await sitioServices.New();
            
            //Eliminar
            Ref ref = await sitioServices.Delete(sitio.id);
            expect (ref.id, sitio.id);
            
            //Validar sitio borrado
            var borrado = await sitioServices.findOne(where.id(StringToId(sitio.id)));
            expect (borrado, null);
        });
        
        test("Agregar y Eliminar Imagen Slider", () async
        {
            //Nuevo Sitio
            var sitio = await sitioServices.New();
            
            expect (sitio.slider, []);
            
            //Agregar Imagen
            var imagen = await sitioServices.AgregarImagenSlider (sitio.id);
            var sitioActualizado = await sitioServices.Get(sitio.id);
            
            //Validar
            expect (sitioActualizado.slider.length, 1);
            
            //Eliminar Imagen
            await sitioServices.EliminarImagenSlider(sitio.id, imagen);
            sitioActualizado = await sitioServices.Get(sitio.id);
            
            //Validar
            expect (sitioActualizado.slider.length, 0);
        });
        
        test("Agregar y Eliminar Categoria", () async
        {
            //Nuevo Sitio
            var sitio = await sitioServices.New();
            
            expect (sitio.categorias, []);
            
            //Agregar Categoria
            var categoria = new Categoria()
                ..id = newId();
            
            await sitioServices.AgregarCategoria (sitio.id, categoria);
            var sitioActualizado = await sitioServices.Get(sitio.id);
            
            //Validar
            expect (sitioActualizado.categorias.length, 1);
            
            //Eliminar Categoria
            await sitioServices.EliminarCategoria (sitio.id, categoria);
            sitioActualizado = await sitioServices.Get(sitio.id);
            
            //Validar
            expect (sitioActualizado.slider.length, 0);
        });
        
        test("Agregar y Eliminar Categoria Destacada", () async
        {
            //Nuevo Sitio
            var sitio = await sitioServices.New();
            
            expect (sitio.categoriasDestacadas, []);
            
            //Agregar Categoria
            var categoria = new Categoria()
                ..id = newId();
            
            await sitioServices.AgregarCategoriaDestacada (sitio.id, categoria);
            var sitioActualizado = await sitioServices.Get(sitio.id);
            
            //Validar
            expect (sitioActualizado.categoriasDestacadas.length, 1);
            
            //Eliminar Destacada
            await sitioServices.EliminarCategoriaDestacada (sitio.id, categoria);
            sitioActualizado = await sitioServices.Get(sitio.id);
            
            //Validar
            expect (sitioActualizado.categoriasDestacadas.length, 0);
        });
        
        test("AgregarProductoDestacado && EliminarProductoDestacado", () async {
          //Crear sitio
          var sitio = await sitioServices.New();
          //Verificar productosDestacados vacia
          expect(sitio.productosDestacados.isEmpty, true);
          //Crear producto
          var producto = new Producto()
            ..id = newId()
            ..nombre = "Producto X";
          //Agregar producto
          sitioServices.AgregarProductoDestacado(sitio.id, producto);
          //Actualizar sitio
          var sitioActualizado = await sitioServices.Get (sitio.id);
          //Verificar producto agregado
          expect (sitioActualizado.productosDestacados.length, 1);
          //Eliminar producto destacado
          sitioServices.EliminarProductoDestacado(sitio.id, producto);
          //Actualizar sitio
          sitioActualizado = await sitioServices.Get (sitio.id);
          //Verificar producto agregado
          expect (sitioActualizado.productosDestacados.length, 0);
        });
    });
}

