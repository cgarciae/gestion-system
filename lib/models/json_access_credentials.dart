part of aristadart.general;

class JsonAccessCredentials implements auth.AccessCredentials
{
    @Field()
    JsonAccessToken accessToken;

    @Field()
    String refreshToken;

    @Field()
    List<String> scopes;
    
    JsonAccessCredentials ();
  
    JsonAccessCredentials.create (this.accessToken, this.refreshToken, this.scopes);
    
    JsonAccessCredentials.fromAccessCredentials (auth.AccessCredentials credentials)
    {
        this.accessToken = credentials.accessToken;
        this.refreshToken = credentials.refreshToken;
        this.scopes = credentials.scopes;
    }
}

class JsonAccessToken implements auth.AccessToken
{
    
    @Field()
    String data;

    @Field()
    DateTime expiry;

    @Field()
    bool get hasExpired {
        return new DateTime.now().toUtc().isAfter(expiry);
    }

    @Field()
    String type;
    
    JsonAccessToken ();
    
    JsonAccessToken.create (String this.type, String this.data, DateTime this.expiry) 
    {
        if (type == null || data == null || expiry == null) {
            throw new ArgumentError('Arguments type/data/expiry may not be null.');
        }
    
        if (!expiry.isUtc) {
            throw new ArgumentError('The expiry date must be a Utc DateTime.');
        }
    }
    
    JsonAccessToken.fromAccessToken (auth.AccessToken token)
    {
        this.type = token.type;
        this.data = token.data;
        this.expiry = token.expiry;
    }
}