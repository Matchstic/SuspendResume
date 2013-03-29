// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos
// SuspendResume by Matt Clarke (matchstick, matchstick-dev on Github and some other places)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBTelephonyManager.h>
#import <GraphicsServices/GSEvent.h>
#import <CoreTelephony/CTCall.h>
#include <notify.h>

static NSString *settingsFile = @"/var/mobile/Library/Preferences/com.matchstick.suspendresume.plist";
static BOOL tweakOn;
static BOOL _clearIdleTimer;

// Required for the CoreTelephony notifications
extern "C" id kCTCallStatusChangeNotification;
extern "C" id kCTCallStatus;
extern "C" id CTTelephonyCenterGetDefault( void );
extern "C" void CTTelephonyCenterAddObserver( id, id, CFNotificationCallback, NSString *, void *, int );

%hook SpringBoard

-(void)_performDeferredLaunchWork {
    // Allow SpringBoard to initialise
    %orig;
    
    // Check if tweak is on
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];

    [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:tweakOn];
    
    [dict release];
}

- (void)setExpectsFaceContact:(BOOL)expectsFaceContact {
    
    %orig(tweakOn);
    
    // Debug
    NSLog(@"******** I'll be back... *********");
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
        if (tweakOn) {
            [dict release];
            return;
        }
    }
    
    // Don't lock in camera unless specified to
    if ((tweakOn) && (!cameraLock) && ([[runningApp bundleIdentifier] isEqualToString:@"com.apple.camera"])) {
        [dict release];
        return;
    }
    
    // Get first proximity value
    BOOL proximate = [[notification.userInfo objectForKey:@"kSBNotificationKeyState"] boolValue];
    if (proximate && tweakOn) {
        
        // Debug
        NSLog(@"Received first proximity state");
        
        // Wait a few milliseconds FIXME causes a lockup of interface whilst waiting
        [NSThread sleepForTimeInterval:timeInterval];
        
        // Second proximity value
        if (proximate) {
            
            // Debug
            NSLog(@"Recieved second proximity state, now locking device");
            
            if (runningApp == nil) {
                
                // We're in SpringBoard, no need to resign active - turn off screen, then lock device
                // TODO Insert dimming code here!
                GSEventLockDevice();
            }
            
            else {
                
                // We're in application, resign app, then turn off screen
                [runningApp notifyResignActiveForReason:1];
                
                // Lock device
                GSEventLockDevice();
            }
            
            // Debug
            NSLog(@"Device locked");
        }
    }
    [dict release];
}

- (void)clearIdleTimer {
    if (_clearIdleTimer) {
        %orig;
    }
    else {
        return;
    }
}

//%new

%end

// Need to hook the camera when in lockscreen to ensure that it locks there too

// Reset setExpectsFaceContact if it gets disabled after airplane mode
%hook SBTelephonyManager

-(void)airplaneModeChanged {
    %orig;
    
    // Check if tweak is on
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:tweakOn];
}

%end

// Reset expectsFaceContact if needed
static void telephonyEventCallback(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object,
 CFDictionaryRef userInfo) {
    if([(NSString *)name isEqualToString:kCTCallStatusChangeNotification]) {
        NSDictionary *info = (NSDictionary *)userInfo;
        
        if(!info) {
            return;
        }
        
        int state = [[info objectForKey:kCTCallStatus] intValue];
        
        if((state == 5) && (tweakOn)) {
            NSLog(@"CTCallStatus is in state 5 (call disconnected), resetting expectsFaceContact.");
            [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:YES];
            NSLog(@"expectsFaceContact is reset");
        }
    }
    
}

static void suspendSettingsChangedNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    // Check if tweak is on
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    if (tweakOn) {
        [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:YES];
        NSLog(@"SuspendResume is now enabled");
    }
    else {
        [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:NO];
        NSLog(@"SuspendResume is now disabled");
    }
    [dict release];
}

%ctor {
    
    %init;
    
    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, telephonyEventCallback, NULL, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &suspendSettingsChangedNotify, CFSTR("com.matchstick.suspendresume.changed"), NULL, 0);
}