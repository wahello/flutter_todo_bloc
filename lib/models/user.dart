import 'package:meta/meta.dart';

class User {
  final String id;
  final String email;
  final String token;
  final String refreshToken;
  final String expiryTime;

  User({
    @required this.id,
    @required this.email,
    @required this.token,
    @required this.refreshToken,
    @required this.expiryTime,
  });
}
