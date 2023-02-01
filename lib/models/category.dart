import 'package:conduit/conduit.dart';
import 'post.dart';

class Category extends ManagedObject<_Category> implements _Category {}

class _Category {
  @primaryKey
  int? id;

  @Column(unique: true, indexed: true)
  String? title;
  
  // При помощи класса ManagedSet указывам что переменная будет иметь Relation
  ManagedSet<Post>? postList;
}
