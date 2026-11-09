import 'package:flutter_test/flutter_test.dart';
import 'package:week4_networking_rest_api/main.dart';

void main() {
  test('Post maps nullable JSON safely', () {
    final post = Post.fromJson({'id': 4, 'title': null});
    expect(post.id, 4);
    expect(post.title, isEmpty);
    expect(post.body, isEmpty);
  });
}
