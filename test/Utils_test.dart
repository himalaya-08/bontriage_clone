
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/util/Utils.dart';

void main(){
  group('email and password verification', (){
    test('password validation should be successful', () {
      bool password = Utils.validatePassword('hello');
      expect(password, false);
    },);
    test('password validation should fail', (){
      bool password = Utils.validatePassword('Hello@123');
      expect(password, true);
    });
    test('email validation should fail', (){
      bool email = Utils.validateEmail('lakshay');
      expect(email, false);
    });
    test('password validation should fail', (){
      bool email = Utils.validateEmail('lakshay7@yopmail.com');
      expect(email, true);
    });
  });


}