part of aristadart.client.tests;

clientNoticiaServicesTest ()
{
    group ("Noticia Services:", ()
    {
        RequestMakerMock requestMaker;
        Requester requester;
        ClientNoticiaServices noticiaServices;
        
        setUp(()
        {
            requestMaker = new RequestMakerMock();
            requester = new Requester(requestMaker);
            noticiaServices = new ClientNoticiaServices(requester);
        });
        
        tearDown(()
        {
            
        });
        
        test ("New", () async
        {
            var noticia = new Noticia()
              ..id = "1234"
              ..texto = "Texto"
              ..titulo = "Titulo";
            
            var response = new Future.value(encodeJson(noticia));
            requestMaker.when(callsTo('requestString')).thenReturn(response);
            
            var newNoticia = await noticiaServices.New();
            
            expect(encode(noticia),encode(newNoticia));
        });
        
        test ("Get", ()
        {
            throw new UnimplementedError();
        });
        
        test ("Update", ()
        {
            throw new UnimplementedError();
        });
        
        test ("Delete", ()
        {
            throw new UnimplementedError();
        });
        
        test ("Ultimas", ()
        {
            throw new UnimplementedError();
        });
    });
}