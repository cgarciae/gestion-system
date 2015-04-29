library aristadart.main;


import 'package:angular/angular.dart';
import 'package:angular/routing/module.dart';
import 'package:angular/application_factory.dart';
import 'package:logging/logging.dart';


import 'package:redstone_mapper/mapper_factory.dart';
import 'package:GestionSystem/arista_client.dart';


@MirrorsUsed(override: '*')
import 'dart:mirrors';

class MyAppModule extends Module
{
    MyAppModule()
    {
        //Views
        bind (VistaSitio);
        bind (VistaSitio2);
        bind(LoginVista);
        //Services
        bind (ClientUserServices);
        bind (ClientFileServices);
        bind (Requester);
        bind (RequestMaker);
        //Router
        bind (RouteInitializerFn, toValue: routeInitializer);
        bind (NgRoutingUsePushState, toValue: new NgRoutingUsePushState.value(false));
    }
}


void main()
{
    
    bootstrapMapper();

    Logger.root.level = Level.FINEST;
    Logger.root.onRecord.listen((LogRecord r) { print(r.message); });

    
    applicationFactory()
        .addModule(new MyAppModule())
        .rootContextType (MainController)
        .run();
}
