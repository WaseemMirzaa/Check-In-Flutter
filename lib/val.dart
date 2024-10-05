// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:email_validator/email_validator.dart';

bool Validate(String email) {
  bool isvalid = EmailValidator.validate(email);
  print("${isvalid}isValid");
  return isvalid;
}
