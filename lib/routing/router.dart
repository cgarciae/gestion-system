part of aristadart.client;


void routeInitializer(Router router, RouteViewFactory view) 
{
    
    ifLoggedIn (String route)
    {
        return (RouteEnterEvent e)
        {
            if (loggedIn)
            {
                view (route) (e);
            }
            else
            {
                router.go
                (
                    'login', {},
                    forceReload: true
                );
            }
        };
    }
    
    ifAdmin (String route)
    {
        return (RouteEnterEvent e)
        {
            if (loggedAdmin)
            {
                view (route) (e);
            }
            else
            {
                router.go
                (
                    'home', {},
                    forceReload: true
                );
            }
        };
    }
    
    view.configure
    ({
        'sitio': ngRoute
        (
          path: '/sitio/:subsitio',
          viewHtml: "<sitio></sitio>"
        ),
        
        'especial': ngRoute
        (
          path: '/sitio/especial',
          viewHtml: "<sitio2></sitio2>"
        ),
        
        'home': ngRoute
        (
          path: '/home',
          viewHtml: '<home></home>',
          defaultRoute: true
        ),
        
        'login': ngRoute(
          path: '/login',
          viewHtml: '<login></login>'
        )
    });
} 


