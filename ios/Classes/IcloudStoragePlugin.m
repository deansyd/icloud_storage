#import "IcloudStoragePlugin.h"
#if __has_include(<icloud_storage/icloud_storage-Swift.h>)
#import <icloud_storage/icloud_storage-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "icloud_storage-Swift.h"
#endif

@implementation IcloudStoragePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIcloudStoragePlugin registerWithRegistrar:registrar];
}
@end
