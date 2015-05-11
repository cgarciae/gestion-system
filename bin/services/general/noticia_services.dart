part of aristadart.server;

class NoticiaServices extends GenericRethinkServices<Noticia> {
  NoticiaServices(InjectableRethinkConnection irc) : super(Col.noticias, irc);

  Future<Noticia> insertNoticia(Noticia noticia) async {
    return genericInsert(noticia);
  }

  Future<Noticia> newNoticia() => insertNoticia(new Noticia()
    ..titulo = "Titulo"
    ..texto = "Texto"
    ..fechaAgregada = new DateTime.now());

  Future<Noticia> getNoticia(String id) => genericGet(id);

  Future<Noticia> updateNoticia(String id, Noticia delta) async {
    await genericUpdate(id, delta);
    return getNoticia(id);
  }

  Future<Ref> deleteNoticia(String id) => genericDelete(id);

  Future<List<Noticia>> ultimas(@app.QueryParam() int n) async {
    Cursor cursor =
        await orderBy({'index': r.desc('fechaAgregada')}).limit(n).run(conn);
    var list = await cursor.toArray();
    return decode(list, Noticia);
  }
}
