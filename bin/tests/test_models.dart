part of aristadart.tests;

testModels ()
{
    var _date = new DateTime.utc(3000);
    JsonAccessToken _token = new JsonAccessToken.create ("type", "data", _date);
    JsonAccessCredentials _credentials = new JsonAccessCredentials.create(_token, "refreshToken", ["email", "profile"]);
    var _tokenResult =
    {
        "type" : "type",
        "data" : "data",
        "expiry" : _date.toIso8601String(),
        "hasExpired" : false
    };
    
    group ("User Model Tests", ()
    {
        setUp((){});
        tearDown((){});
        
        test("Encoding", (){});
        test("Decoding", (){});
    });
    
    group ("User Model Tests", ()
    {
        Noticia noticia;
        
        setUp((){
            noticia = new Noticia()
                ..titulo = "Titulo"
                ..texto = "Texto"
                ..id = "1";
            
        });
        tearDown((){});
        
        test("Encoding", (){
            Noticia noticiaT = Cast (Noticia, noticia);
            
            expect (noticia.titulo, noticiaT.titulo);
            expect (noticia.texto, noticiaT.texto);
            expect (noticia.id, noticiaT.id);
        });
        test("Decoding", (){});
    });
    
    group ("Json Access Token Model Tests", ()
    {
        var _json = encode(_token);;
        
        setUp((){});
        tearDown((){});
        
        test("Encoding", ()
        {
            
            expect (_json, _tokenResult);
            
        });
        test("Decoding", (){
            
            JsonAccessToken token = decode(_json, JsonAccessToken);
            
            expect(token.data, _token.data);
            expect(token.type, _token.type);
            expect(token.expiry, _token.expiry);
            expect(token.hasExpired, _token.hasExpired);
        });
    });
    
    group ("Json Access Credentials Model Tests", ()
    {
        var _json = encode(_credentials);
        
        setUp((){});
        tearDown((){});
        
        test("Encoding", ()
        {
            expect (_json,
            {
                "accessToken" : _tokenResult,
                "scopes" : ["email", "profile"],
                "refreshToken" : "refreshToken"
            });
        });
        
        test("Decoding", ()
        {
            JsonAccessCredentials credentials = decode(_json, JsonAccessCredentials);
            JsonAccessToken token = credentials.accessToken;
                        
            //Retestear access token
            expect(token.data, _token.data);
            expect(token.type, _token.type);
            expect(token.expiry, _token.expiry);
            expect(token.hasExpired, _token.hasExpired);
               
            //Testear campos
            expect(credentials.refreshToken, _credentials.refreshToken);
            expect(credentials.scopes, _credentials.scopes);
        });
    });
}