part of aristadart.client;

@Component
(
    selector : "sitio2",
    templateUrl: 'components/views/sitio/sitio2.html'
)
class VistaSitio2 extends VistaSitio
{
  
  
  VistaSitio2 (RouteProvider route) : super (route);
  
  clock () => print ("Chao");
  
}