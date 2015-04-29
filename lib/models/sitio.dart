part of aristadart.general;

class Sitio extends Ref
{
    @Field() String nombre;
    @Field() String descripcion;
    @Field() List<ImagenSlider> slider;
    @Field() List<Categoria> categoriasDestacadas;
    @Field() List<Categoria> categorias;
    @Field() List<Producto> productosDestacados;
    @Field() String urlVideo;
}

