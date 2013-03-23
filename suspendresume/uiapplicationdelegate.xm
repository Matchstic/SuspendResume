// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos
// SuspendResume by Matt Clarke (matchstick, matchstick-dev on Github and some other places)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <GraphicsServices/GSEvent.h>
#include <notify.h>

@interface suspendresume

@property(nonatomic, readonly) BOOL proximityState;

@end

@implementation suspendresume

BOOL tweakOn;

@end

static NSString *settingsFile = @"/var/mobile/Library/Preferences/com.matchstick.suspendresume.plist";

%hook UIApplicationDelegate

-(void)applicationDidBecomeActive:(id)application {
    %orig;

    // Run proximity method
    [self performSelector:@selector(proximityChange:)];
}

%new

// Add new code into application
-(void)proximityChange:(NSNotification*)notification {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    // Check if tweak is on
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    // Only run if tweak is on
    if (tweakOn) {
        
        // Get first proximity value
        if ([[UIDevice currentDevice] proximityState] == YES) {
            
            // Wait a few seconds TODO allow changing of wait interval from prefrences FIXME causes a lockup of interface whilst sleeping
            [self performSelector:@selector(lockDeviceAfterDelay) withObject:nil afterDelay:1.0];
        }
    }
}

%new

-(void)lockDeviceAfterDelay {
    
    // Second proximity value
    if ([[UIDevice currentDevice] proximityState] == YES) {
        
        // Lock device
        GSEventLockDevice();
    }
}

%end

