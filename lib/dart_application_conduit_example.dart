import 'dart:io';
import 'package:conduit/conduit.dart';
import 'package:dart_application_conduit_example/controllers/auth_controller.dart';
import 'package:dart_application_conduit_example/controllers/post_controller.dart';
import 'package:dart_application_conduit_example/controllers/category_controller.dart';
import 'package:dart_application_conduit_example/controllers/token_controller.dart';
import 'package:dart_application_conduit_example/controllers/user_controller.dart';

import 'package:dart_application_conduit_example/models/post.dart';
import 'package:dart_application_conduit_example/models/user.dart';
import 'package:dart_application_conduit_example/models/category.dart';
import 'models/category.dart';
import 'models/user.dart';

class DatabaseChannel extends ApplicationChannel {
  late final ManagedContext context;

  @override
  Future prepare() async {
    final persistentStore = _initDatabase();
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();

    context = ManagedContext(dataModel, persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route('/user/[:id]').link(TokenController.new)!.link(() => UserController(context))
    ..route('/category/[:id]').link(() => CategoryController(context))
    ..route('post/[:id]').link(() => PostController(context))
    ..route('token/[:refresh]').link(() => MyAuthController(context));

  PersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'postgres';
    final password = Platform.environment['DB_PASSWORD'] ?? '123';
    final host = Platform.environment['DB_HOST'] ?? '127.0.0.1';
    final port = int.parse(Platform.environment['DB_PORT'] ?? '5432');
    final databaseName = Platform.environment['DB_NAME'] ?? 'Conduit';
    return PostgreSQLPersistentStore(
        username, password, host, port, databaseName);
  }
}