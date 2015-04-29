part of aristadart.tests;

class GoogleServicesMock extends Mock implements GoogleServices {}
class MongoServiceMock extends Mock implements MongoService 
{
    MongoServiceMock ();
    MongoServiceMock.spy (MongoService real) : super.spy (real);
}