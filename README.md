# icloud_storage

A flutter plugin for uploading and downloading files to and from iCloud.

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/donate?hosted_button_id=BH6WBSGWN594U)

## Introduction

Documents and other data that is user-generated and stored in the <Application_Home>/Documents directory can be automatically backed up by iCloud on iOS devices, if the iCloud Backup setting is turned on. The data can be recovered when user sets up a new device or resets an existing device. If you need to do backup and download outside the forementioned scenarios, this plugin could help.

## Prerequisite

The following setups are needed in order to use this plugin:

1. An apple developer account
2. Created an App ID and iCloud Container ID
3. Enabled iCloud capability and assigned iCloud Container ID for the App ID
4. Enabled iCloud capability in Xcode

Refer to the 'How to set up iCloud Container and enable the capability' section for more detailed instructions.

## API Usage

### Get instance

```dart
final iCloudStorage = await ICloudStorage.getInstance('iCloudContainerId');
```

### List files from iCloud

```dart
final files = await iCloudStorage.listFiles();
files.forEach((file) => print('--- List Files --- file: $file'));
```

Note: The 'listFile' API lists files from the iCloud container directory, which also lives on the device (To understand how iCloud Storage works on iOS, please refer to [Apple Documentation - Designing for Documents in iCloud](https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/DesigningForDocumentsIniCloud.html)). In the situations where a file is just uploaded to iCloud from another device, or when the user just signed in to iCloud, the files's meta data may not be available in the iCloud container straight away. You can use the 'watchFiles' API to listen for updates.

```dart
final fileListStream = await iCloudStorage.watchFiles();
final fileListSubscription = fileListStream.listen((files) {
  files.forEach((file) => print('--- Watch Files --- file: $file'));
});

Future.delayed(Duration(seconds: 10), () {
  fileListSubscription.cancel();
  print('--- Watch Files --- canceled');
});
```

### Upload a file to iCloud

```dart
await iCloudStorage.startUpload(
  filePath: 'someDirectory/someFile',
  destinationFileName: 'icloud_file',
  onProgress: (stream) {
    uploadProgressSubcription = stream.listen(
      (progress) => print('--- Upload File --- progress: $progress'),
      onDone: () => print('--- Upload File --- done'),
      onError: (err) => print('--- Upload File --- error: $err'),
      cancelOnError: true,
    );
  },
);
```

Note: The 'startUpload' API is only to start the upload process. The upload may not be completed when the future returns. Use 'onProgress' to track the upload progress.

### Download afile from iCloud

```dart
await iCloudStorage.startDownload(
  fileName: 'icloud_file',
  destinationFilePath: 'someDirectory/someFile',
  onProgress: (stream) {
    downloadProgressSubcription = stream.listen(
      (progress) => print('--- Download File --- progress: $progress'),
      onDone: () => print('--- Download File --- done'),
      onError: (err) => print('--- Download File --- error: $err'),
      cancelOnError: true,
    );
  },
);
```

Note: The 'startDownload' API is only to start the download process. The download may not be completed when the future returns. Use 'onProgress' to track the download progress.

### Error handling

```dart
catch (err) {
  if (err is PlatformException &&
      err.code == PlatformExceptionCode.iCloudConnectionOrPermission) {
    print(
        'Error: iCloud container ID is not valid, or user is not signed in for iCloud, or user denied iCloud permission for this app');
  } else {
    print(err.toString());
  }
}
```

## How to set up iCloud Container and enable the capability

1. Log in to your apple developer account and select 'Certificates, IDs & Profiles' from the left navigation.
2. Select 'Identifiers' from the 'Certificates, IDs & Profiles' page, create an App ID if you haven't done so, and create an iCloud Containers ID.
   ![icloud container id](./doc/images/icloud_container_id.png)
3. Click on your App ID. In the Capabilities section, select 'iCloud' and assign the iCloud Container created in step 2 to this App ID.
   ![assign icloud capability](./doc/images/assign_icloud_capability.png)
4. Open your project in Xcode. Set your App ID as 'Bundle Identifier' if you haven't done so. Click on '+ Capability' button, select iCloud, then tick 'iCloud Documents' in the Services section and select your iCloud container.
   ![xcode capability](./doc/images/xcode_capability.png)

## References

[Apple Documentation - iOS Data Storage Guidelines](https://developer.apple.com/icloud/documentation/data-storage/)

[Apple Documentation - Designing for Documents in iCloud](https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/DesigningForDocumentsIniCloud.html)
