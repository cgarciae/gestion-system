part of aristadart.tests;

noticiaServicesTests ()
{
    group("Noticia Services Tests:", ()
    {
        MongoDbManager dbManager = new MongoDbManager("mongodb://${partialDBHost}/servicesTesting");
        MongoDb db;
        MongoService mongoService;
        NoticiaServices noticiaServices;
        setUp(() async
        {
            db = await dbManager.getConnection();
            mongoService = new MongoServiceMock.spy (new MongoService.fromMongoDb(db));
            noticiaServices = new NoticiaServices (mongoService);
        });

        //remove all loaded handlers
        tearDown(() async
        {
            await db.innerConn.drop();
            dbManager.closeConnection (db);
        });
        
        test("New", () async
        {
            Noticia respNoticia = await noticiaServices.New();
             
            expect (respNoticia.titulo != null, true);
            expect (respNoticia.texto != null, true);
        });
        
        test("Get", () async
        {
            Noticia noticia = await noticiaServices.New();
            
            Noticia respNoticia = await noticiaServices.Get (noticia.id);
             
            expect (encode(noticia), encode(respNoticia));
        });
        
        test("Update", () async
        {
            //Creat noticia
            Noticia noticia = await noticiaServices.New();
            
            //Update
            var cambio = "AAA";
            var delta = new Noticia()
                ..texto = cambio;
            
            Noticia noticiaActualizada = await noticiaServices.Update (noticia.id, delta);
             
            //Actualizar noticia original
            noticia.texto = cambio;
            
            //Validar
            expect (encode(noticia), encode(noticiaActualizada));
        });
        
        test("Delete", () async
        {
            //Creat noticia
            Noticia noticia = await noticiaServices.New();
            
            //Delete
            Ref ref = await noticiaServices.Delete (noticia.id);
             
            //Validar id
            expect(ref.id, noticia.id);
            
            //Validar noticia borrada
            var borrada = await noticiaServices.findOne(where.id(StringToId(noticia.id)));
            expect (borrada, null);
        });
        
        test ("Ultimas", () async 
        {
            //Crear noticias
            Iterable<Noticia> noticias = await Future.wait 
            (
                new Iterable
                    .generate(10)
                    .map((n) => noticiaServices.New())
            );
            
            List<Noticia> ultimas5 = await noticiaServices.Ultimas(5);
            
            //Validar que todas las ultimas noticias sean noticias originales
            expect (ultimas5.every((ultima) => noticias.any((noticia) => noticia.id == ultima.id)), true);
            
            //Eliminar una noticia de las ultimas
            Ref borrada = await noticiaServices.Delete (ultimas5.first.id);
            
            //Validar noticia borrada
            ultimas5 = await noticiaServices.Ultimas(5);
            expect (ultimas5.any((noticia) => noticia.id == borrada.id), false);
            var todas = await noticiaServices.find();
            expect (todas.length, 9);
            
            //Guardar noticia mas vieja
            var vieja = ultimas5.last;
            
            //Agregar nueva noticia
            var nueva = await noticiaServices.New();
            
            //Validar noticia vieja no sea ultima noticia
            ultimas5 = await noticiaServices.Ultimas(5);
            expect (ultimas5.any((noticia) => noticia.id == vieja.id), false);
            expect (ultimas5.first.id == nueva.id, true);
        });
    });
}

