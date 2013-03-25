// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos
// SuspendResume by Matt Clarke (matchstick, matchstick-dev on Github and some other places)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplicationIcon.h>
#import <SpringBoard/SBTelephonyManager.h>
#import <GraphicsServices/GSEvent.h>
#include <notify.h>

static NSString *settingsFile = @"/var/mobile/Library/Preferences/com.matchstick.suspendresume.plist";
static BOOL tweakOn;
static BOOL _clearIdleTimer;

%hook SpringBoard

-(void)_performDeferredLaunchWork {
    // Allow SpringBoard to initialise
    %orig;
    
    // Check if tweak is on
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];

    if (tweakOn) {
        [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:YES];
    }
    
    [dict release];
}

- (void)setExpectsFaceContact:(BOOL)expectsFaceContact
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    %orig(tweakOn);
    
    [dict release];
}

// This is where the magic happens!
-(void)_proximityChanged:(NSNotification*)notification {
    
    // Check if tweak is on
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    // Check for time interval - the value is stored in <real> tags
    double timeInterval = [[dict objectForKey:@"interval"] doubleValue];
    // Check for camera locking
    BOOL cameraLock = [[dict objectForKey:@"cameraLock"] boolValue];
    
    // Get the topmost application
    SBApplication *runningApp = [(SpringBoard *)self _accessibilityFrontMostApplication];

    _clearIdleTimer = NO;
    %orig;
    _clearIdleTimer = YES;
    
    // Don't run if in a call or in Cydia - compatible with CallBar!
    if (([[runningApp bundleIdentifier] isEqualToString:@"com.saurik.Cydia"]) || ([[%c(SBTelephonyManager) sharedTelephonyManager] inCall])) {
        [dict release];
        return;
    }
    
    // Don't lock in camera unless specified to
    if (!cameraLock && [[runningApp bundleIdentifier] isEqualToString:@"com.apple.camera"]) {
        [dict release];
        return;
    }
    
    // Get first proximity value
    BOOL proximate = [[notification.userInfo objectForKey:@"kSBNotificationKeyState"] boolValue];
    if (proximate && tweakOn) {
        
        NSLog(@"Received first proximity state");
        
        // Wait a few milliseconds FIXME causes a lockup of interface whilst waiting
        [NSThread sleepForTimeInterval:timeInterval];
        
        // Second proximity value
        if (proximate) {
            
            // Debug
            NSLog(@"Recieved second proximity state, now locking device");
            
            if (runningApp == nil) {
                
                // We're in SpringBoard, no need to resign active - lock device
                GSEventLockDevice();
            }
            
            else {
                
                // We're in application, resign app
                [runningApp notifyResignActiveForReason:1];
                
                // Lock device
                GSEventLockDevice();
            }
            
            // Debug
            NSLog(@"Device locked");
        }
    
        [dict release];
    
    }
}

- (void)clearIdleTimer
{
    if (_clearIdleTimer) {
        %orig;
    }
    else {
        return;
    }
}

%end