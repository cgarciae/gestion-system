library aristadart.server;

import 'dart:io';
import 'package:GestionSystem/arista.dart';
import 'package:path/path.dart' as path;
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:di/di.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_static/shelf_static.dart';
import 'package:redstone_rethinkdb/redstone_rethinkdb.dart';
import 'package:rethinkdb_driver/rethinkdb_driver.dart';
import 'package:redstone_mvc/redstone_mvc.dart' as mvc;
import 'dart:async';

import 'dart:convert' as conv;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;
import "package:googleapis_auth/auth.dart" as auth;
import 'package:googleapis/oauth2/v2.dart' as oauth;
import 'package:redstone/query_map.dart';

import 'package:redstone_mapper/mapper.dart';

import 'package:redstone/server.dart';

//part 'services/core/arista_service.dart';
//part 'services/general/user_services.dart';
part 'services/general/noticia_services.dart';
//part 'services/general/home_services.dart';
//part 'services/general/sitio_services.dart';
//part 'services/general/general_services.dart';
//part 'services/general/file_services.dart';
part 'services/general/file_services2.dart';
part 'services/general/test_services.dart';
//part 'utils/authorization.dart';
part 'utils/utils.dart';
part 'services/rest/rest_files_services.dart';
part 'services/mvc/mvc_files_services.dart';
part 'services/core/generic_rethink_services.dart';

main() async {

  var l = [1,2,3,4];

  l.forEach((n) => n = n + 3);

  print (l);

  var config = new ConfigRethink(
    host: dbHost,
    port: 7272,
    database: 'gstest',
    tables: [
      new TableConfig (Col.usuarios),
      new TableConfig (Col.sitios),
      new TableConfig (Col.noticias,
        secondaryIndexes: ['fechaAgregada']),
      new TableConfig (Col.home),
      new TableConfig (Col.files),
      new TableConfig (Col.categorias),
      new TableConfig (Col.productos)
    ]
  );

  var r = new Rethinkdb();
  var conn = await r.connect(host: config.host, db: config.database, port: config.port);

  print ("Connected");

  var dbManager = new RethinkDbManager.fromCongif(config);

  app.addPlugin(getMapperPlugin(dbManager));
  //app.addPlugin(AuthenticationPlugin);
  //app.addPlugin(ErrorCatchPlugin);
  app.addPlugin(PrintHeadersPlugin);

  app.addModule(new Module()
      ..bind(NoticiaServices)
      ..bind(InjectableRethinkConnection)
      ..bind(FileServices2)
      ..bind(MvcFileServices)
      ..bind(RestFileServices)
      );
    //..bind(UserServives)
    //..bind(GoogleServices)
    //..bind(FileServices));



  app.setShelfHandler(createStaticHandler(staticFolder,
      defaultDocument: "testView.html", serveFilesOutsidePath: true));
  app.setupConsoleLog();

  await setupRethink(config);
  await app.start(port: port, autoCompress: true);

  RethinkConnection dbConn = await dbManager.getConnection();
  var users = new RethinkServices<User>.fromConnection('usuarios', dbConn.conn);

  User user = await users.findOne({'admin': true});

  if (user == null) {
    print("Creando nuevo admin");
    if (tipoBuild == TipoBuild.deploy) {
      var newUser = new ProtectedUser()
        ..nombre = "Arista"
        ..apellido = "Dev"
        ..email = "info@aristadev.com"
        ..money = 1000000000
        ..admin = true;

      await users.insertNow(newUser);
    } else {
      var newUser = new ProtectedUser()
        ..nombre = "Arista"
        ..apellido = "Dev"
        ..email = "a"
        ..money = 1000000000
        ..admin = true;

      await users.insertNow(newUser);
    }
  } else {
    print("Admin found:");
    print(user.email);
    print(user.id);
  }

  //List users = await dbConn.collection (Col.user).find().toList();
  //users.forEach (print);

  user = await users.findOne({"email": "cgarcia.e88@gmail.com"});

  if (user == null) {
    var cristian = new ProtectedUser()
      ..nombre = "Cristian"
      ..apellido = "Garcia"
      ..email = "cgarcia.e88@gmail.com"
      ..money = 1000000000
      ..admin = true;

    await users.insertNow(cristian);

    print("Usuario Cristian Creado");
  } else {
    print("Cristian ya existe");
  }
}

@app.Interceptor(r'/.*')
handleResponseHeader() {
  if (app.request.method == "OPTIONS") {
    //overwrite the current response and interrupt the chain.
    app.response = new shelf.Response.ok(null, headers: _specialHeaders());
    app.chain.interrupt();
  } else {
    //process the chain and wrap the response
    app.chain.next(() => app.response.change(headers: _specialHeaders()));
  }
}
/*
setupRethink(ConfigRethink config) async {
  Rethinkdb r = new Rethinkdb();
  Connection conn = await r.connect(host: config.host, db: config.database, port: config.port);

  print("CONNECTED");

  if (! await r.dbList().contains(config.database).run(conn)) {
    print(0);
    await r.dbCreate(config.database).run(conn);
    print(1);

    print('Created db: ${config.database}');
  }

  print(2);

  List tables = await r.db(config.database).tableList().run(conn);
  for (var table in config.tables) {
    if (!tables.contains(table)) {
      await r.tableCreate(table).run(conn);
      print('Created table: $table');
    }
  }

  conn.close();
}
*/

_specialHeaders() {
  var cross = {"Access-Control-Allow-Origin": "*"};

  if (tipoBuild <= TipoBuild.jsTesting) {
    cross['Cache-Control'] =
        'private, no-store, no-cache, must-revalidate, max-age=0';
  }

  return cross;
}

setupRethink(ConfigRethink config) async {
  Rethinkdb r = new Rethinkdb();
  Connection conn = await r.connect(host: config.host, db: config.database, port: config.port);

  if (!await r.dbList().contains(config.database).run(conn)) {
    await r.dbCreate(config.database).run(conn);
    print('Created db: ${config.database}');
  }

  List tables = await r.db(config.database).tableList().run(conn);
  for (var tableConfig in config.tables) {
    if (!tables.contains(tableConfig.name)) {
      await r.tableCreate(tableConfig.name).run(conn);
      print('Created table: ${tableConfig.name}');
    }

    var table = r.table(tableConfig.name);
    for (var index in tableConfig.secondaryIndexes) {
      List<String> indexes = await table.indexList().run(conn);
      if (! indexes.contains(index)) {
        await table.indexCreate(index).run(conn);
        print('Created index $index on table ${tableConfig.name}');
      }
    }
  }

  conn.close();
}