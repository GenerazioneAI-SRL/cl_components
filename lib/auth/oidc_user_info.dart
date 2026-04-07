import 'package:cl_components/auth/cl_user_info.dart';
import 'package:oidc/oidc.dart';

/// Implementazione di [CLUserInfo] che wrappa un [OidcUser].
class OidcUserInfo implements CLUserInfo {
  final OidcUser _user;

  OidcUserInfo(this._user);

  @override
  String get firstName => _user.userInfo['userInfo']?['firstName']?.toString() ?? '';

  @override
  String get lastName => _user.userInfo['userInfo']?['lastName']?.toString() ?? '';

  @override
  String? get email => _user.userInfo['email']?.toString();

  @override
  String get fullName => '$firstName $lastName'.trim();

  @override
  Map<String, dynamic> get rawData => Map<String, dynamic>.from(_user.userInfo);
}

