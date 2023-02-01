import 'dart:io';

import 'package:conduit/conduit.dart';

import '../models/user.dart';
import '../utils/app_response.dart';
import '../utils/app_util.dart';

class UserController extends ResourceController {
  UserController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getProfile(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      // Получаем id пользователя
      // Была создана новая функция ее нужно реализоваться для просмотра функции нажмите на картинку
      final id = AppUtils.getIdFromHeader(header);

      // Получаем данные пользователя по его id
      final user = await context.fetchObjectWithID<User>(id);

      // Удаляем не нужные параметры для красивого вывода данных пользователя
      user!.removePropertiesFromBackingMap(['refresh Token', 'access Token']);
      return AppResponse.ok(
          message: 'Успешное получение профиля', body: user.backing.contents);
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка получения профиля');
    }
  }

  @Operation.post()
  Future<Response> updateProfile(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() User user,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final fUser = await context.fetchObjectWithID<User>(id);

      final qUpdateUser = Query<User>(context)
        ..where((element) => element.id).equalTo(id)
        ..values.name = user.name ?? fUser!.name
        ..values.email = user.email ?? fUser!.email;

      await qUpdateUser.updateOne();

      final findUser = await context.fetchObjectWithID<User>(id);

      findUser!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);
      return AppResponse.ok(
        message: "Успешное обновление данных",
        body: findUser.backing.contents,
      );
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления данных');
    }
  }

  @Operation.put()
  Future<Response> updatePassword(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.query('newPassword') String newPassword,
    @Bind.query('oldPassword') String oldPassword,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qFindUser = Query<User>(context)
        ..where((element) => element.id).equalTo(id)
        ..returningProperties(
          (element) => [
            element.salt,
            element.hashPassword,
          ],
        );

      final fUser = await qFindUser.fetchOne();

      final oldHashPassword =
          generatePasswordHash(oldPassword, fUser!.salt ?? "");
      if (oldHashPassword != fUser.hashPassword) {
        return AppResponse.badrequest(
          message: "Неверный старый пароль",
        );
      }

      final newHashPassword =
          generatePasswordHash(newPassword, fUser.salt ?? "");

      final qUpdateUser = Query<User>(context)
        ..where((x) => x.id).equalTo(id)
        ..values.hashPassword = newHashPassword;
        
      await qUpdateUser.fetchOne();
      return AppResponse.ok(body: 'Пароль успешно обновлен');
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления пароля');
    }
  }
}
