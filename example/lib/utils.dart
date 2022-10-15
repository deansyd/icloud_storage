import 'package:flutter/services.dart';
import 'package:icloud_storage/icloud_storage.dart';

String getErrorMessage(dynamic ex) {
  if (ex is PlatformException) {
    if (ex.code == PlatformExceptionCode.iCloudConnectionOrPermission) {
      return 'Platform Exception: iCloud container ID is not valid, or user is not signed in for iCloud, or user denied iCloud permission for this app';
    }

    return 'Platform Exception: ${ex.message}; Details: ${ex.details}';
  }

  return ex.toString();
}
