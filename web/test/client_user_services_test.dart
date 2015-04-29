part of aristadart.client.tests;

clientUserServicesTest ()
{
    group ("User Services:", ()
    {
        User user;
        Requester requester = new RequesterMock();
        ClientUserServices services = new ClientUserServices(requester);
        
        setUp(()
        {
            
        });
        
        tearDown(()
        {
            
        });
        
        test ("Login", ()
        {
            throw new UnimplementedError();
        });
        
        test ("Update", ()
        {
            throw new UnimplementedError();
        });
        
        test ("Is Admin", ()
        {
            throw new UnimplementedError();
        });
    });
}