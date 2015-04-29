part of aristadart.general;

class Producto extends Ref
{
  @Field() String nombre;
  @Field() String descripcion;
  @Field() Sitio sitio;
  @Field() Categoria categoria;
  @Field() List<FileDb> imagenes; 
}

