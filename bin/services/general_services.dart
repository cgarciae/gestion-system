part of aristadart.server;


@app.Route('/query/:collection', methods: const [app.POST])
@Private(ADMIN)
@Catch()
queryCollection (@app.Attr() MongoDb dbConn, @app.Body(app.JSON) Map query, String collection)
{
    return dbConn.collection (collection)
            .find(query)
            .toList();
}
