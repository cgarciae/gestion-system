part of aristadart.client;

@Component
(
    selector : "login",
    templateUrl: 'components/views/login/login.html',
    useShadowDom: false
)
class LoginVista
{
    ClientUserServices clientUserServies;
    User user = new User();
    Router router;
    bool immediate = false;
    
    var id = new auth.ClientId("287932517253-d6fp73ms7d33ith6r561p1g225q5th0h.apps.googleusercontent.com", null);
    var scopes = ["openid", "email"];
    
    LoginVista (this.router, this.clientUserServies);
    
    googleLogin () async {
      var credentials = await getCredentials ();
      var user = await clientUserServies.GoogleLogin(credentials);
      
      userId = user.id;
    }
    
    
    Future<JsonAccessCredentials> getCredentials () async
    {
      auth.BrowserOAuth2Flow flow = await auth.createImplicitBrowserFlow(id, scopes);
      var credentials = await flow.obtainAccessCredentialsViaUserConsent();
      return new JsonAccessCredentials.fromAccessCredentials(credentials);
    }
    
//    login ()
//    {
//        getClient().then((auth.AutoRefreshingAuthClient client){
//            
//        var oauthApi = new oauth.Oauth2Api(client);
//        oauthApi.userinfo.get().then((oauth.Userinfoplus info){
//                    
//        
//        User googleUser = new User()
//            ..email = info.email
//            ..nombre = info.name
//            ..apellido = info.familyName;
//        
//        
//        return clientUserServies.NewOrLogin(googleUser).then((User dbUser){
//        
//        userId = dbUser.id;
//        print (encode(dbUser));
//        
//        return clientUserServies.IsAdmin(dbUser.id).then((BoolResp resp){
//            
//        loggedAdmin = resp.value;
//        router.go('home', {});
//        });
//        });
//        });
//        }).catchError(printReqError, test: ifProgEvent);
//    }
//
//    Future<auth.AutoRefreshingAuthClient> getClient()
//    {
//        return auth.createImplicitBrowserFlow(id, scopes)
//                            .then((auth.BrowserOAuth2Flow flow) {
//                  
//        return flow.clientViaUserConsent(immediate: immediate).then((auth.AutoRefreshingAuthClient client){
//            
//        immediate = false;
//        
//        return client;
//        
//        }).catchError((_) {
//                
//        immediate = true;    
//                
//        }, test: (error) => error is auth.UserConsentException);
//        });
//    }
    
}

