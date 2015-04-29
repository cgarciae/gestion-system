library aristadart.tests;

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:GestionSystem/arista.dart';
import 'package:http/http.dart' as http;
import 'package:redstone/server.dart' as app;
import 'dart:io' as io;
import 'package:redstone/mocks.dart';
import 'package:di/di.dart';
import 'package:mock/mock.dart';
import 'arista_server.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:redstone_mapper_mongo/manager.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/mapper_factory.dart';
import 'package:redstone_mapper/plugin.dart';

part 'tests/test_user_services.dart';
part 'tests/test_noticia_services.dart';
part 'tests/test_sitio_services.dart';
part 'tests/test_home_services.dart';
part 'tests/test_models.dart';
part 'tests/mocks.dart';

main() {
  bootstrapMapper();
    
  userServicesTests ();
  noticiaServicesTests ();
  homeServicesTests ();
  sitioServicesTests ();
  testModels ();
  
  print (new DateTime.now().add(new Duration(seconds: 2770)));
}
