part of aristadart.general;

class Categoria extends Ref
{
    @Field() String nombre;
    @Field() FileDb imagen; 
    @Field() List<Producto> destacados;
}

