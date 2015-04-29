part of aristadart.client;

@Injectable()
class ClientUserServices extends ClientService<User>
{
    ClientUserServices (Requester requester) : super (Col.user, requester);
    
    //@app.Route ('/googleLogin', methods: const [app.POST])
    Future<User> GoogleLogin (JsonAccessCredentials credentials) async
    {
      return json (Method.POST, '$pathBase/googleLogin', credentials);
    }
    
    Future<User> NewOrLogin (User user)
    {
        return json (Method.POST, pathBase, user);
    }
    
    Future<BoolResp> IsAdmin (String id)
    {
        return requester.private (BoolResp, Method.GET, '${href(id)}/isAdmin');
    }
}