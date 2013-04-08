// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos
// SuspendResume by Matt Clarke (matchstick, matchstick-dev on Github and some other places)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBTelephonyManager.h>
#import <GraphicsServices/GSEvent.h>
#import <CoreTelephony/CTCall.h>
#include <notify.h>

static NSString *settingsFile = @"/var/mobile/Library/Preferences/com.matchstick.suspendresume.plist";
static BOOL tweakOn;
static BOOL _clearIdleTimer;
static BOOL isBlacklisted;

// Required for the CoreTelephony notifications
extern "C" id kCTCallStatusChangeNotification;
extern "C" id kCTCallStatus;
extern "C" id CTTelephonyCenterGetDefault( void );
extern "C" void CTTelephonyCenterAddObserver( id, id, CFNotificationCallback, NSString *, void *, int );

// ********** Start main functions/hooks ************

%hook SpringBoard

// ********** Ensure proximity is on when booted ***********

-(void)_performDeferredLaunchWork {
    // Allow SpringBoard to initialise
    %orig;
    
    // Check if tweak is on
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];

    [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:tweakOn];
    
    [dict release];
}
// *********** Finished boot hooks ********

// *********** Do some funky stuff *********
-(void)setExpectsFaceContact:(BOOL)expectsFaceContact {
    
    %orig;
    
    // Debug
    NSLog(@"SuspendResume: I'll be back...");
}
// *********** End funky stuff **********

// *********** This is where the magic happens! ************

-(void)_proximityChanged:(NSNotification*)notification {
    
    // Check if tweak is on
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    // Check for time interval - the value is stored in <real> tags
    int timeInterval = [[dict objectForKey:@"interval"] doubleValue];
    // Check for camera locking
    BOOL cameraLock = [[dict objectForKey:@"cameraLock"] boolValue];
    //BOOL onlySuspend = [[dict objectForKey:@"onlySuspend"] boolValue];
    
    // Get the topmost application
    SBApplication *runningApp = [(SpringBoard *)self _accessibilityFrontMostApplication];

    _clearIdleTimer = NO;
    %orig;
    _clearIdleTimer = YES;
    
    // Don't run in a blacklisted app - prevents the locking of the app, probably.
    if (isBlacklisted) {
        [dict release];
        return;
    }
    
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
        NSLog(@"SuspendResume: Received first proximity state");
        // Wait a few milliseconds, and run second proximity method FIXME locks up main thread
        [self performSelector:@selector(secondProximityState) withObject:nil afterDelay:timeInterval];
    }
    [dict release];
}
// ********* End the proximity changed method ************

- (void)clearIdleTimer {
    if (_clearIdleTimer) {
        %orig;
    }
    else {
        return;
    }
}

// ********* Run to get second proximity state ************
%new
-(void)secondProximityState {
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    BOOL onlySuspend = [[dict objectForKey:@"onlySuspend"] boolValue];
    //[UIDevice currentDevice].proximityMonitoringEnabled = YES; -- until a fix is built
    //BOOL proximate = [[UIDevice currentDevice] proximityState];
    BOOL proximate = YES;
    NSLog(@"SuspendResume: Proximity state = %d", proximate);
    
    SBApplication *runningApp = [(SpringBoard *)self _accessibilityFrontMostApplication];
    
    // Second proximity value - bug here! Always evaluates to no
    if (proximate) {
        // Debug
        NSLog(@"SuspendResume: Recieved second proximity state, now locking/suspending device");
        
        if (onlySuspend) {
            NSLog(@"SuspendResume: Device suspended");
            [dict release];
            return;
        }
        else {
            if (runningApp == nil) {
                // We're in SpringBoard, no need to resign active - turn off screen, then lock device
                [self performSelector:@selector(lockTheDevice)];
            }
            else {
                // We're in application, resign app, then lock device
                [runningApp notifyResignActiveForReason:1];
                [self performSelector:@selector(lockTheDevice)];
            }
            // Debug
            NSLog(@"SuspendResume: Device locked");
        }
    }
    [dict release];
}
// ********* End second proximity state **********

// ********* Device locking code **********
%new
-(void)lockTheDevice {
    SBUIController *controller = (SBUIController *)[%c(SBUIController) sharedInstance];
    if ([controller respondsToSelector:@selector(lock)])
        [controller lock];
    if ([controller respondsToSelector:@selector(lockFromSource:)])
        [controller lockFromSource:0];
}

// ********* End locking code **************

%end

// ********* End main functions ************

// Need to hook the camera when in lockscreen to ensure that it locks there too

// ************** Reset proximity after airplane mode changed ************

%hook SBTelephonyManager
-(void)airplaneModeChanged {
    %orig;
    
    // Check if tweak is on
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:tweakOn];
    [dict release];
}
%end

// ************** End airplane mode hooking ***********

// ************** App blacklisting hooks *****************

%hook SBApplication
-(void)didActivate {
    %orig;
    // Check if tweak is on
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    if (tweakOn) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.matchstick.suspendresume.applaunched"), NULL, NULL, TRUE);
    }
    [dict release];
}

// Ensure expectsFaceContact is reset after a blacklisted app is quit
-(void)didSuspend {
    if (tweakOn && !([[%c(SBTelephonyManager) sharedTelephonyManager] inCall])) {
        [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:YES];
        //BOOL isBlacklisted = NO;
        //NSLog(@"SuspendResume: isBlacklisted state = %d", isBlacklisted);
    }
    %orig;
}
%end

// ************** End app blacklisting hooks **************

// ***************** Resetting proximity monitoring after a phone call ***************

static void telephonyEventCallback(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
    if([(NSString *)name isEqualToString:kCTCallStatusChangeNotification]) {
        NSDictionary *info = (NSDictionary *)userInfo;
        
        if(!info) {
            return;
        }
        
        int state = [[info objectForKey:kCTCallStatus] intValue];
        
        if((state == 5) && (tweakOn)) {
            NSLog(@"SuspendResume: CTCallStatus is in state 5 (call disconnected), resetting expectsFaceContact.");
            [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:YES];
            NSLog(@"SuspendResume: expectsFaceContact is reset");
        }
    }
}

// ************** End resetting after telephony ******************

// ************** More app blacklisting code - runs when app is launched ************

static void appHasLaunched(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    // Get the topmost application
    SBApplication *runningApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
    // Don't run in a blacklisted app
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    NSString *displayId = [runningApp displayIdentifier];
    if ([displayId length] == 0) {
        return;
    }
    BOOL blacklist = [[dict objectForKey:[@"Blacklist-" stringByAppendingString:displayId]] boolValue];
    if (blacklist) {
        [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:NO];
        //BOOL isBlacklisted = YES;
        NSLog(@"SuspendResume: App is blacklisted, temporarily disabled.");
    }
    [dict release];
}

// ************* End blacklisting code **************

// ************* Handle change of settings **************

static void suspendSettingsChangedNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    // Check if tweak is on
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    if (tweakOn) {
        [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:YES];
        NSLog(@"SuspendResume: is now enabled");
    }
    else {
        [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:NO];
        NSLog(@"SuspendResume: is now disabled");
    }
    [dict release];
}

// ************* End settings handling ************

%ctor {
    @autoreleasepool {
    %init;
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &suspendSettingsChangedNotify, CFSTR("com.matchstick.suspendresume.changed"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &appHasLaunched, CFSTR("com.matchstick.suspendresume.applaunched"), NULL, 0);
    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, telephonyEventCallback, NULL, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}