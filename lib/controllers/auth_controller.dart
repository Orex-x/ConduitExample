import 'dart:io';
import 'package:conduit/conduit.dart';

import '../models/ModelRespone.dart';
import '../models/user.dart';
import '../utils/app_response.dart';
import '../utils/app_util.dart';

import 'package:jaguar_jwt/jaguar_jwt.dart';

class MyAuthController extends ResourceController {
  MyAuthController(this.context);

  final ManagedContext context;

  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.password == null || user.name == null) {
      return Response.badRequest(
          body: ModelResponse(message: 'Поля password username обязательны'));
    }
    try {
      final qFindUser = Query<User>(context)
        ..where((element) => element.name).equalTo(user.name)
        ..returningProperties((element) => [
              element.id,
              element.salt,
              element.hashPassword,
            ]);

      final findUser = await qFindUser.fetchOne();

      if (findUser == null) {
        throw QueryException.input('Пользователь не найден', []);
      }

      final requestHashPassword =
          generatePasswordHash(user.password ?? '', findUser.salt ?? '');

      if (requestHashPassword == findUser.hashPassword) {
         _updateTokens(findUser.id ?? -1, context);

        final newUser = await context.fetchObjectWithID<User>(findUser.id);

        return Response.ok(ModelResponse(
            data: newUser!.backing.contents, message: 'Успешная авторизация'));
      } else {
        throw QueryException.input('Не верный пароль', []);
      }
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.put()
  Future<Response> singUp(@Bind.body() User user) async {
    if (user.password == null || user.name == null || user.email == null) {
      return Response.badRequest(
          body: ModelResponse(
              message:
                  'Обязательные поля не заполнены (password, name, email)'));
    }

    //generate salt
    final salt = generateRandomSalt();

    final hashPassword = generatePasswordHash(user.password!, salt);

    try {
      late final int id;

      await context.transaction((t) async {
        final qUser = Query<User>(t)
          ..values.name = user.name
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;

        final createdUser = await qUser.insert();

        id = createdUser.id!;
      });

      final userData = await context.fetchObjectWithID<User>(id);

      return AppResponse.ok(
          body: userData!.backing.contents, message: 'Успешная регистрация');
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.post('refresh')
  Future<Response> refreshToken(
      @Bind.path('refresh') String refreshToken) async {
    try {
      // Полчаем id пользователя из jwt token
      final id = AppUtils.getIdFromToken(refreshToken);
      // Получаем данные пользователя по его id
      final user = await context.fetchObjectWithID<User>(id);
      if (user!.refreshToken != refreshToken) {
        return Response.unauthorized(body: 'Token не валидный');
      }

       _updateTokens(id, context);

      return Response.ok(
        ModelResponse(
          data: user.backing.contents,
          message: 'Токен успешно обновлен',
        ),
      );
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  void _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, String> tokens = _getTokens(id);

    final qUpdateTokens = Query<User>(transaction)
      ..where((element) => element.id).equalTo(id)
      ..values.accessToken = tokens['access']
      ..values.refreshToken = tokens['refresh'];
      
    await qUpdateTokens.updateOne();
  }


  // Генерация jwt token-a
  Map<String, String> _getTokens(int id) {

    final key = Platform.environment['SECRET_KEY'] ?? 'SECRET_KEY';

    final accessClaimSet = JwtClaim(
      maxAge: const Duration(hours: 1), // Время жизни token
      otherClaims: {'id': id},
    );
    final refreshClaimSet = JwtClaim(
      otherClaims: {'id': id},
    );
    
    final tokens = <String, String>{};
    tokens['access'] = issueJwtHS256(accessClaimSet, key);
    tokens['refresh'] = issueJwtHS256(refreshClaimSet, key);
    return tokens;
  }
}
