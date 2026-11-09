import '../repositories/auth_repository.dart';

class Login {
  const Login(this.repository);
  final AuthRepository repository;

  Future<AuthSession> call({
    required String username,
    required String password,
  }) {
    return repository.login(username: username, password: password);
  }
}
