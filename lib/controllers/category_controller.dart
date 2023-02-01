import 'package:conduit/conduit.dart';
import 'package:dart_application_conduit_example/models/category.dart';

class CategoryController extends ResourceController {
  CategoryController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getAll({@Bind.query('name') String? name}) async {
    final query = Query<Category>(context);

    if (name != null) {
      query.where((h) => h.title).contains(name, caseSensitive: false);
    }

    final categorys = await query.fetch();

    return Response.ok(categorys);
  }

  @Operation.post()
  Future<Response> create(@Bind.body(ignore: ["id"]) Category category) async {
    final query = Query<Category>(context)..values = category;

    final inserted = await query.insert();

    return Response.ok(inserted);
  }

  @Operation.put('id')
  Future<Response> update(@Bind.path("id") int id,
      @Bind.body(ignore: ["id"]) Category category) async {
    final qUpdate = Query<Category>(context)
      ..where((x) => x.id).equalTo(id)
      ..values.title = category.title;

    final updated = await qUpdate.update();

    return Response.ok(updated);
  }

  @Operation.delete('id')
  Future<Response> delete(@Bind.path("id") int id) async {
    final qUpdate = Query<Category>(context)
      ..where((x) => x.id).equalTo(id);

    final deleted = await qUpdate.delete();

    return Response.ok(deleted);
  }
}
