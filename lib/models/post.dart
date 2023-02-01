import 'package:conduit/conduit.dart';
import 'category.dart';

class Post extends ManagedObject<_Post> implements _Post {}

class _Post {
  @primaryKey
  int? id;
  
  @Column(unique: true, indexed: true)
  String? number;

  @Column(unique: true, indexed: true)
  String? name;

  @Column(unique: true, indexed: true)
  String? description;

  @Column(unique: true, indexed: true)
  DateTime? date;

  @Column(unique: true, indexed: true)
  int? sum;

  @Relate(#postList, isRequired: true, onDelete: DeleteRule.cascade)
  Category? category; 
}