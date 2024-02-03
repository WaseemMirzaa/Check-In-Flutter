import 'package:nb_utils/nb_utils.dart';

successMessage(String msg) {
  return Fluttertoast.showToast(msg: msg);
}

errorMessage(String msg) {
  return Fluttertoast.showToast(msg: msg, backgroundColor: redColor);
}
