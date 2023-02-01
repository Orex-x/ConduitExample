import 'dart:io';
import 'package:conduit/conduit.dart';

import '../models/category.dart';
import '../models/post.dart';
import '../utils/app_response.dart';
import '../utils/app_util.dart';

class PostController extends ResourceController {
  PostController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getAll({@Bind.query('name') String? name}) async {
    final query = Query<Post>(context);

    if (name != null) {
      query.where((h) => h.name).contains(name, caseSensitive: false);
    }

    final posts = await query.fetch();

    return Response.ok(posts);
  }

  @Operation.get("id")
  Future<Response> getPost(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await context.fetchObjectWithID<Post>(id);
      if (post == null) {
        return AppResponse.ok(message: "Пост не найден");
      }
      if (post.category?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }
      post.backing.removeProperty("author");
      return AppResponse.ok(
          body: post.backing.contents, message: "Успешное создание поста");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка создания поста");
    }
  }

  @Operation.post()
  Future<Response> create(@Bind.body(ignore: ["id"]) Post post) async {
    final query = Query<Post>(context)..values = post;

    final inserted = await query.insert();

    return Response.ok(inserted);
  }

  @Operation.put('id')
  Future<Response> updatePost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id,
      @Bind.body() Post bodyPost) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await context.fetchObjectWithID<Post>(id);

      if (post == null) {
        return AppResponse.ok(message: "Пост не найден");
      }

      if (post.category?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }
      final qUpdatePost = Query<Post>(context)
        ..where((x) => x.id).equalTo(id)
        ..values.name = bodyPost.name;
      await qUpdatePost.update();
      return AppResponse.ok(message: 'Пост успешно обновлен');
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.delete("id")
  Future<Response> deletePost(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await context.fetchObjectWithID<Post>(id);
      if (post == null) {
        return AppResponse.ok(message: "Post not found");
      }
      if (post.category?.id != currentAuthorId) {
        return AppResponse.ok(message: "No access to the post");
      }
      final deletepost = Query<Post>(context)..where((x) => x.id).equalTo(id);

      await deletepost.delete();

      return AppResponse.ok(message: "Successful post deletion");
    } catch (error) {
      return AppResponse.serverError(error, message: "Post deletion error");
    }
  }
}
