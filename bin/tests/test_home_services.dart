part of aristadart.tests;

homeServicesTests ()
{
    group("Home Services Tests:", ()
    {
        MongoDbManager dbManager = new MongoDbManager("mongodb://${partialDBHost}/servicesTesting");
        MongoDb db;
        
        setUp(() async
        {
            db = await dbManager.getConnection();
        });

        //remove all loaded handlers
        tearDown(() async
        {
            await db.innerConn.collection(Col.home).drop();
            dbManager.closeConnection (db);
        });
        
        test("Get", () async
        {
            //Servicios
            var mongoService = new MongoServiceMock.spy (new MongoService.fromMongoDb(db));      
            var homeServices = new HomeServices(mongoService);
            
            //Get
            var home = await homeServices.Get();
            
            //Validar
            mongoService.getLogs(callsTo('insert')).verify(happenedOnce);
            expect(home.slider, []);
            expect(home.id != null, true);
            
            //Reset logs
            mongoService.clearLogs();
            
            //Get otra vez
            home = await homeServices.Get();

            //Validar, no debe llamar insert
            mongoService.getLogs(callsTo('insert')).verify(neverHappened);
        });
        
        test("Update", () async
        {
            //Servicios
            var mongoService = new MongoServiceMock.spy (new MongoService.fromMongoDb(db));      
            var homeServices = new HomeServices(mongoService);
            
            //Get
            var home = await homeServices.Get();
            
            expect (home.slider.length, 0);
            
            var delta = new Home()
                ..slider = [new ImagenSlider()..caption = "Caption"];
            
            //Update
            var homeActualizado = await homeServices.Update (delta);
            
            //Validar
            expect (homeActualizado.slider.length, 1);
        });
    });
}

