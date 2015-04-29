part of aristadart.client;

@Component
(
    selector : "sitio",
    templateUrl: 'components/views/sitio/sitio.html'
)
class VistaSitio
{
  String subsitio;
  String templateUrl;
  
  VistaSitio (RouteProvider route)
  {
    subsitio = route.parameters["subsitio"];
    templateUrl = "view/sitio/${subsitio}.html";
  }
  
  click ()
  {
    print ("Hola");
  }
  
  
}