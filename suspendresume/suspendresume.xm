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
    NSLog(@"SuspendResume: I'll be back...");
}

// This is where the magic happens!
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
    //NSString *openApp = [runningApp displayIdentifier];
    //BOOL blacklist = [[dict objectForKey:[@"Blacklist-" stringByAppendingString:openApp]] boolValue];
    //if (blacklist) {
    //    [dict release];
    //    return;
    //}
    
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
        // Wait a few milliseconds FIXME causes a lockup of interface whilst waiting
        [self performSelector:@selector(secondProximityState) withObject:nil afterDelay:timeInterval];
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

%new
-(void)secondProximityState {
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    BOOL onlySuspend = [[dict objectForKey:@"onlySuspend"] boolValue];
    //[UIDevice currentDevice].proximityMonitoringEnabled = YES; -- until a fix is built
    //BOOL proximate = [[UIDevice currentDevice] proximityState];
    BOOL proximate = YES;
    NSLog(@"SuspendResume: proximity state = %d", proximate);
    
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

%new
-(void)lockTheDevice {
    SBUIController *controller = (SBUIController *)[%c(SBUIController) sharedInstance];
    if ([controller respondsToSelector:@selector(lock)])
        [controller lock];
    if ([controller respondsToSelector:@selector(lockFromSource:)])
        [controller lockFromSource:0];
    //[controller wakeUp:nil];
}

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
    [dict release];
}

%end

// For app blacklisting
%hook SBApplicationIcon
-(void)launch {
    %orig;
    // Check if tweak is on
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    if (tweakOn) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.matchstick.suspendresume.applaunched" object:nil];
        NSLog(@"SuspendResume: App launched notification has been sent");
    }
    [dict release];
}
// Ensure expectsFaceContact is reset after a blacklisted app is quit
//-(void)exitedCommon {
//    %orig;
//    if (tweakOn && !([[%c(SBTelephonyManager) sharedTelephonyManager] inCall])) {
//        NSLog(@"SuspendResume: App closed, re-enabling expectsFaceContact");
//        [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:YES];
//    }
//}
%end

//@interface TheListener : NSObject
//@end
//@implementation TheListener

//-(id)init {
//    self = [super init];
//    NSLog(@"SuspendResume: TheListener has begun init!");
//    if (self) {
        
//        NSLog(@"SuspendResume: TheListener has set up observers!");
//    }
//    return self;
//}


//-(void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [super dealloc];
//}
//@end

// Reset expectsFaceContact after phone call
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

// For app blacklisting
//-(void)appHasLaunched:(NSNotification *)notification {
static void appHasLaunched(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSLog(@"SuspendResume: recieved app launched notification");
    // Get the topmost application
    SBApplication *runningApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
    // Don't run in a blacklisted app
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    BOOL blacklist = [[dict objectForKey:[@"Blacklist-" stringByAppendingString:[runningApp displayIdentifier]]] boolValue];
    if (blacklist) {
        [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:NO];
        NSLog(@"SuspendResume: app is blacklisted, temporarily disabled.");
    }
    [dict release];
}

// settings changed method
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

%ctor {
    @autoreleasepool {
    %init;
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &suspendSettingsChangedNotify, CFSTR("com.matchstick.suspendresume.changed"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &appHasLaunched, CFSTR("com.matchstick.suspendresume.applaunched"), NULL, 0);
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appHasLaunched:) name:suspendresumeAppLaunched object:nil];
    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, telephonyEventCallback, NULL, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}