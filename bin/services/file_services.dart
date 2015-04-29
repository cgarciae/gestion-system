part of aristadart.server;

@app.Group('/file')
@Catch()
class FileServices extends AristaService<FileDb>
{
    FileServices (MongoService mongoService) : super (Col.file, mongoService);
    
    GridFS get fs => new GridFS(mongoDb.innerConn);
    
    @app.DefaultRoute(methods: const[app.POST], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<FileDb> New (@app.Body(app.FORM) Map form, 
                                @Decode(fromQueryParams: true) FileDb queryMetadata,
                                {String id, String ownerId}) async
    {
        HttpBodyFileUpload file = FormToFileUpload(form);
            
        if (file == null || file.content == null || file.content.length == 0)
            throw new app.ErrorResponse (400, "File is null or empty");
        
        //Define input from uploaded file
        var input = new Stream.fromIterable([file.content]);
        
        //Create gridFS file
        var gridIn = fs.createFile(input, file.filename)
            ..contentType = file.contentType.value;
        
        
        //Set new metadata
        FileDb newMetadata;
        if (queryMetadata != null)
            newMetadata = Clone (queryMetadata);
        else
            newMetadata = new FileDb();
        
        if (newMetadata.type == null)
            newMetadata.type = file.contentType.value;
        
        if (ownerId == null)
            newMetadata.owner = (new User()
            ..id = userId);
        
        if (id != null)
        {
            gridIn.id = StringToId(id);
            newMetadata.id = id;
        }
        else
        {
            newMetadata.id = gridIn.id.toHexString();
        }
        
        newMetadata
            ..filename = file.filename;
        
        print ("Metadata es ${encode(newMetadata)}");
        
        
        
        //Convert to map and clean null fields
        var metadataMap = cleanMap(mongoDb.encode(newMetadata));
        
        //Save metadata
        gridIn.metaData = metadataMap;
        
        print ("MetadataMap es ${metadataMap}");
               
        //Wait till save finishes
        await gridIn.save();
        
        return newMetadata;
    }
    
    @app.Route ('/:id', methods: const [app.GET])
    Future Get (String id) async
    {
        GridOut gridOut = await fs.findOne
        (
            where.id (StringToId(id))
        );
        
        if (gridOut == null)
            throw new app.ErrorResponse (400, "El archivo no existe");
        
        return new shelf.Response.ok
        (
            getData (gridOut), 
            headers: { "Content-Type": gridOut.contentType }
        );
    }
    
    @app.Route ('/:id/metadata', methods: const [app.GET])
    @Private()
    @Encode()
    Future<FileDb> GetMetadata (String id) async
    {
        if (id == null)
            throw new app.ErrorResponse (400, "No se pudo obtener metadata: id null");
        
        GridOut gridOut = await fs.findOne
        (
            where.id (StringToId(id))
        );
        
        
        if (gridOut == null)
            throw new app.ErrorResponse(400, "El archivo no existe");
        
        return mongoDb.decode(gridOut.metaData, FileDb);
        
    }
    
    @app.Route('/:id', methods: const[app.PUT], allowMultipartRequest: true)
    @Private()
    @Encode()
    Future<FileDb> Update (String id, @app.Body(app.FORM) Map form, {String ownerId}) async
    {
        FileDb metadata = await GetMetadata(id);
        Ref obj = await Delete (id);
        FileDb fileDb = await New(form, metadata, id: id, ownerId: ownerId);
        
        return fileDb;
    }
    
    @app.Route('/:id', methods: const[app.DELETE])
    @Private()
    @Encode()
    Future<Ref> Delete (String id) async
    {
        await deleteFile(id);
             
        return new Ref()
            ..id = id;
    }
    
    @app.Route('/all', methods: const[app.GET])
    @Private()
    @Encode()
    Future All (@app.QueryParam('type') String type) async
    {
        
        Stream<QueryMap> stream = fs.files.find
        (
            where.eq("metadata.owner._id", StringToId(userId))
        )
        .stream
        .map(MapToQueryMap);
        
        if (type != null)
            stream = stream.where((QueryMap file)
                    => (file.contentType as String).contains(type) || file.metadata.type == type);
        
        
        return stream.map((QueryMap file) => mongoDb.decode(file.metadata, FileDb)).toList();
    }
    
    @app.Route('/allImages', methods: const[app.GET])
    @Private()
    @Encode()
    Future AllImages () async
    {
        return All ('image');
    }
    
    Future<List<dynamic>> deleteFile (String id)
    {
        var fileId = StringToId(id);
        
        var removeFiles = fs.files.remove (where.id (fileId));
        var removeChunks = fs.chunks.remove (where.eq ('files_id', fileId));
            
        return Future.wait([removeChunks, removeFiles]);  
    }
    
    Stream<List<int>> getData (GridOut gridOut)
    {
        var controller = new StreamController<List<int>>();
        var sink = new IOSink (controller);
        gridOut.writeTo(sink).then((n) => sink.close());
        return controller.stream;
    }
    
}