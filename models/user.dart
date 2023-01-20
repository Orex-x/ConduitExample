import 'package:conduit/conduit.dart';

class User extends ManagedObject<_User> implements _User{}

class _User{
  @primaryKey
  int? id;

  @Column(unique: true, indexed: true)
  String? name;

  @Column(unique: true, indexed: true)
  String? email;

  @Column()
  String? password;

  @Column(nullable: true)
  String? accessToken;

  @Column(nullable: true)
  String? refreshToken;
}