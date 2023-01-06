## 2.2.0

- Bug fix: upload and download errors were not passed from the platform code.

## 2.1.0

- Add support for managing files in the iCloud container's `Documents` subdirectory.

## 2.0.0

What's New

- Support for macOS
- Support for multiple iCloud Containers

Breaking changes

- All methods have been changed to static methods.
- `getInstance` has been removed. You need to specifiy the `iCloudContainerId` in each method.
- `gatherFiles` has been renamed to `gather`.
- `startUpload` has been renamed to `upload`.
- `startDownload` has been renamed to `download`.
- `listFiles` and `watchFiles` have been removed.
- `DownloadStatus` enum members haved been changed to camel case from pascal case.

## 1.0.0

Breaking changes

- The 'destinationFileName' parameter is renamed to 'destinationRelativePath' for the 'startUpload' API, as it is now supporting subdirectory creation.
- The 'fileName' parameter is renamed to 'relativePath' for the 'startDownload' API, as it now supporting downloading file from a subdirectory location.

New API

- 'gatherFiles': returns all the files' meta data and any updates can be listened to. This API is to replace 'listFiles' and 'watchFiles' which will be removed from a future release.
- 'move': move a file from one location to another
- 'rename': rename a file

## 0.2.3

- Bug fix: delete didn't work if the file hadn't been downloaded https://github.com/deansyd/icloud_storage/issues/11
- Bug fix: startUpload https://github.com/deansyd/icloud_storage/issues/12

## 0.2.2

- Bug fix: listFiles type cast issue

## 0.2.1

- Bug fix: startUpload/startDownload progress stream synchronisation issue
- Bug fix: startDownload not moving file to destination if onProgress is null

## 0.2.0

- Release for null safety.

## 0.1.0

- Added a new API for file deletion.

## 0.0.2

- Added API documentation.

## 0.0.1

- Initial release.
