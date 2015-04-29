part of aristadart.client.tests;

class RequestMakerMock extends Mock implements RequestMaker
{
  RequestMakerMock ();
  RequestMakerMock.spy (RequestMaker real) : super.spy (real);
}

class RequesterMock extends Mock implements Requester
{
    RequesterMock ();
    RequesterMock.spy (Requester real) : super.spy (real);
}