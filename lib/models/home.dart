part of aristadart.general;

class Home extends Ref
{
    @Field() List<ImagenSlider> slider;
    @Field() FileDb ImagenListaPrecios;
    @Field() FileDb ArchivoListaPrecios;
    @Field() List<Producto> productosDestacado;
    @Field() String urlVideo;
}

