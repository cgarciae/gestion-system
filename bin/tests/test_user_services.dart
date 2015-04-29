part of aristadart.tests;

userServicesTests ()
{
    MongoDbManager dbManager = new MongoDbManager("mongodb://${partialDBHost}/servicesTesting");
    group("User Tests", ()
    {
        //Definir usuario
        String nombre = "Juan";
        String apellido = "Perez";
        String email = "juanperez@gmail.com";
        String id = newId();
        
        User basicUser;
        
        createBasicUser () async
        {
            //Insertar usuario
            MongoDb db = await dbManager.getConnection();
            basicUser.id = newId();
            await db.insert (Col.user, basicUser);
            dbManager.closeConnection (db);
        }
        
        
        setUp(() async
        {
            app.addPlugin(getMapperPlugin(dbManager));
            app.addPlugin(AuthenticationPlugin);
            app.addPlugin(ErrorCatchPlugin);
            
            basicUser = new User ()
                ..nombre = nombre
                ..apellido = apellido
                ..email = email
                ..id = id;
        });

        //remove all loaded handlers
        tearDown(() async
        {
            app.tearDown();
            
            //Clear users
            MongoDb db = await dbManager.getConnection();
            await db.collection('user').drop();
            dbManager.closeConnection(db);
        });
    
        test("Login", () async
        {
            //Crear mock
            var googleServices = new GoogleServicesMock();
            
            googleServices
                .when(callsTo('GetUser'))
                .thenReturn(new Future.value(basicUser));
            
            
            //SETUP
            app.addModule (new Module()
                    ..bind(UserServives)
                    ..bind(GoogleServices, toValue: googleServices)//Injectar mock
                    ..bind(FileServices)
                    ..bind(MongoService));
            
            app.setUp([#aristadart.server]);
          
            //Crear mock request
            MockRequest req = new MockRequest
            (
                '/user/googleLogin', method: app.POST, bodyType: app.JSON,
                body : {}
            );
        
            //dispatch request
            var resp = await app.dispatch(req);
        
            
            User user = decodeJson (resp.mockContent, User);
            
            expect(user.id != null, true);
            expect(user.nombre, nombre);
            expect(user.apellido, apellido);
        });
        
        
        test ('GET Fail', () async
        {
            //SETUP
            app.addModule (new Module()
                  ..bind(UserServives)
                  ..bind(GoogleServices)
                  ..bind(FileServices)
                  ..bind(MongoService));
          
            app.setUp([#aristadart.server]);
            
            var id = new ObjectId ().toHexString();
            
            //Crear mock request
            MockRequest req = new MockRequest  
            (
                '/user/$id', method: app.GET,
                headers: {Header.authorization: id}
            );

            //dispatch request
            io.HttpResponse resp = await app.dispatch(req);
            
            expect (resp.statusCode > 299, true);
            
        });
        
        test ('GET Success', () async
        {
            await createBasicUser();
            
            //SETUP
            app.addModule (new Module()
                ..bind(UserServives)
                ..bind(GoogleServices)
                ..bind(FileServices)
                ..bind(MongoService));
          
            app.setUp([#aristadart.server]);
            
            //Crear mock request
            MockRequest req = new MockRequest  
            (
                '/user/${basicUser.id}', method: app.GET,
                headers: {Header.authorization: basicUser.id}
            );

            //dispatch request
            MockHttpResponse resp = await app.dispatch(req);
            
            
            expect (encodeJson(basicUser), resp.mockContent);
            expect (resp.statusCode == 200, true);
            
        });
        
        test ('Put User', () async
        {
            await createBasicUser();
            
            //SETUP
            app.addModule (new Module()
                ..bind(UserServives)
                ..bind(GoogleServices)
                ..bind(FileServices)
                ..bind(MongoService));
          
            app.setUp([#aristadart.server]);
            
            var delta = new User ()
                ..nombre = "Pedro";
            
            //Crear mock request
            MockRequest req = new MockRequest  
            (
                '/user/${basicUser.id}', method: app.PUT,
                headers: {Header.authorization: basicUser.id},
                bodyType: app.JSON, body: encode(delta)
            );

            //dispatch request
            MockHttpResponse resp = await app.dispatch(req);
            
            User nuevoUsuario = decodeJson(resp.mockContent, User);
            
            expect (nuevoUsuario.nombre, "Pedro");
            expect (resp.statusCode == 200, true);
        });
        
        test ('Delete User', () async
        {
            await createBasicUser();
            
            //SETUP
            app.addModule (new Module()
                ..bind(UserServives)
                ..bind(GoogleServices)
                ..bind(FileServices)
                ..bind(MongoService));
          
            app.setUp([#aristadart.server]);
            
            
            
            //Crear mock request
            MockRequest req = new MockRequest  
            (
                '/user/${basicUser.id}', method: app.DELETE,
                headers: {Header.authorization: basicUser.id}
            );

            //dispatch request
            MockHttpResponse resp = await app.dispatch(req);
            
            Ref ref = decodeJson(resp.mockContent, Ref);
            
            expect (ref.id, basicUser.id);
            expect (resp.statusCode == 200, true);
            
            req = new MockRequest
            (
                '/user/${basicUser.id}', method: app.GET,
                headers: {Header.authorization: basicUser.id}
            );
            
            //dispatch request
            resp = await app.dispatch(req);
            
            expect(resp.statusCode > 299, true);
        });
        
        test ('Is Admin', () async
        {
            ProtectedUser protectedUser = Cast (ProtectedUser, basicUser);
            protectedUser.admin = false;
            MongoDb db = await dbManager.getConnection();
            await db.insert (Col.user, protectedUser);
            dbManager.closeConnection (db);
            
            //SETUP
            app.addModule (new Module()
                ..bind(UserServives)
                ..bind(GoogleServices)
                ..bind(FileServices)
                ..bind(MongoService));
            
            app.setUp([#aristadart.server]);
            
            //Crear mock request
            MockRequest req = new MockRequest  
            (
                '/user/${basicUser.id}/isAdmin', method: app.GET,
                headers: {Header.authorization: basicUser.id}
            );

            //dispatch request
            MockHttpResponse resp = await app.dispatch(req);
            
            BoolResp ref = decodeJson(resp.mockContent, BoolResp);
            
            
            expect (ref.value, false, reason:  resp.mockContent);
            expect (resp.statusCode == 200, true);
            
        });
    });
}

