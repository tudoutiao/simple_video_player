#import "SimpleVideoPlayerPlugin.h"
#if __has_include(<simple_video_player/simple_video_player-Swift.h>)
#import <simple_video_player/simple_video_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "simple_video_player-Swift.h"
#endif

@implementation SimpleVideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSimpleVideoPlayerPlugin registerWithRegistrar:registrar];
}
@end
