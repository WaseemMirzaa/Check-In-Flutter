import 'package:email_validator/email_validator.dart';

bool Validate(String email) {
  bool isvalid = EmailValidator.validate(email);
  print(isvalid.toString() + "isValid");
  return isvalid;
}
