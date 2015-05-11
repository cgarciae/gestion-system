part of aristadart.server;



class HomeServices extends GenericRethinkServices<Home>
{
    HomeServices (InjectableRethinkConnection irc) : super (Col.home, irc);


    Future<Home> Get () async
    {
        var home = await findOne ({});
        
        if (home == null)
        {
            home = new Home()
                ..slider = []
                ..productosDestacado = [];
            
            await insertNow (home);
        }
        
        return home;
    }

    Future<Home> Update (Home delta) async
    {
        var home = await Get();
        
        delta.id = null;
        delta.productosDestacado = null;
        
        try {
          await update (
            where.id(StringToId(home.id)),
            delta,
            override: false
          );
        }
        catch (e, s) {
          await mongoDb.update (
              collectionName,
              where.id(StringToId(home.id)),
              getModifierBuilder (delta, mongoDb.encode)
          );
        }
        
        return Get();
    }

    Future<BoolResp> agregarProductoDestacado (Producto producto) {
      throw new UnimplementedError();
    }

    Future<BoolResp> eliminarProductoDestacado (Producto producto) {
      throw new UnimplementedError();
    }
}

@mvc.GroupController ('/${Col.home}', root: '/web/template')
class MvcHomeServices extends HomeServices {
    final NoticiaServices noticiaServices;

    MvcHomeServices (this.noticiaServices, InjectableRethinkConnection irc): super (irc);

    @mvc.DefaultDataController ()
    index (@app.QueryParam() int n) async {
        Home home = await genericGet("id");
        HomeView homeView = cast(HomeView, home);

        homeView.noticias = await noticiaServices.ultimas(n);

        return homeView;
    }
}

class HomeView extends Home {
    @Field() List<Noticia> noticias;
    @Field() List<Sitio> sitios;
}

