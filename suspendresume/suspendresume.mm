#line 1 "/Users/Matt/iOS/Projects/suspendresume/suspendresume/suspendresume.xm"




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


extern "C" id kCTCallStatusChangeNotification;
extern "C" id kCTCallStatus;
extern "C" id CTTelephonyCenterGetDefault( void );
extern "C" void CTTelephonyCenterAddObserver( id, id, CFNotificationCallback, NSString *, void *, int );

#include <logos/logos.h>
#include <substrate.h>
@class SBApplicationIcon; @class SBTelephonyManager; @class SBUIController; @class SpringBoard; 
static void (*_logos_orig$_ungrouped$SpringBoard$_performDeferredLaunchWork)(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$_performDeferredLaunchWork(SpringBoard*, SEL); static void (*_logos_orig$_ungrouped$SpringBoard$setExpectsFaceContact$)(SpringBoard*, SEL, BOOL); static void _logos_method$_ungrouped$SpringBoard$setExpectsFaceContact$(SpringBoard*, SEL, BOOL); static void (*_logos_orig$_ungrouped$SpringBoard$_proximityChanged$)(SpringBoard*, SEL, NSNotification*); static void _logos_method$_ungrouped$SpringBoard$_proximityChanged$(SpringBoard*, SEL, NSNotification*); static void (*_logos_orig$_ungrouped$SpringBoard$clearIdleTimer)(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$clearIdleTimer(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$secondProximityState(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$lockTheDevice(SpringBoard*, SEL); static void (*_logos_orig$_ungrouped$SBTelephonyManager$airplaneModeChanged)(SBTelephonyManager*, SEL); static void _logos_method$_ungrouped$SBTelephonyManager$airplaneModeChanged(SBTelephonyManager*, SEL); static void (*_logos_orig$_ungrouped$SBApplicationIcon$launch)(SBApplicationIcon*, SEL); static void _logos_method$_ungrouped$SBApplicationIcon$launch(SBApplicationIcon*, SEL); 
static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBTelephonyManager(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBTelephonyManager"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBUIController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBUIController"); } return _klass; }
#line 23 "/Users/Matt/iOS/Projects/suspendresume/suspendresume/suspendresume.xm"


static void _logos_method$_ungrouped$SpringBoard$_performDeferredLaunchWork(SpringBoard* self, SEL _cmd) {
    
    _logos_orig$_ungrouped$SpringBoard$_performDeferredLaunchWork(self, _cmd);
    
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];

    [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:tweakOn];
    
    [dict release];
}

static void _logos_method$_ungrouped$SpringBoard$setExpectsFaceContact$(SpringBoard* self, SEL _cmd, BOOL expectsFaceContact) {
    
    _logos_orig$_ungrouped$SpringBoard$setExpectsFaceContact$(self, _cmd, tweakOn);
    
    
    NSLog(@"SuspendResume: I'll be back...");
}


static void _logos_method$_ungrouped$SpringBoard$_proximityChanged$(SpringBoard* self, SEL _cmd, NSNotification* notification) {
    
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    int timeInterval = [[dict objectForKey:@"interval"] doubleValue];
    
    BOOL cameraLock = [[dict objectForKey:@"cameraLock"] boolValue];
    
    
    
    SBApplication *runningApp = [(SpringBoard *)self _accessibilityFrontMostApplication];

    _clearIdleTimer = NO;
    _logos_orig$_ungrouped$SpringBoard$_proximityChanged$(self, _cmd, notification);
    _clearIdleTimer = YES;
    
    
    
    
    
    
    
    
    
    
    if (([[runningApp bundleIdentifier] isEqualToString:@"com.saurik.Cydia"]) || ([[_logos_static_class_lookup$SBTelephonyManager() sharedTelephonyManager] inCall])) {
        if (tweakOn) {
            [dict release];
            return;
        }
    }
    
    
    if ((tweakOn) && (!cameraLock) && ([[runningApp bundleIdentifier] isEqualToString:@"com.apple.camera"])) {
        [dict release];
        return;
    }
    
    
    BOOL proximate = [[notification.userInfo objectForKey:@"kSBNotificationKeyState"] boolValue];
    if (proximate && tweakOn) {
        
        NSLog(@"SuspendResume: Received first proximity state");
        
        [self performSelector:@selector(secondProximityState) withObject:nil afterDelay:timeInterval];
    }
    [dict release];
}

static void _logos_method$_ungrouped$SpringBoard$clearIdleTimer(SpringBoard* self, SEL _cmd) {
    if (_clearIdleTimer) {
        _logos_orig$_ungrouped$SpringBoard$clearIdleTimer(self, _cmd);
    }
    else {
        return;
    }
}


static void _logos_method$_ungrouped$SpringBoard$secondProximityState(SpringBoard* self, SEL _cmd) {
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    BOOL onlySuspend = [[dict objectForKey:@"onlySuspend"] boolValue];
    
    
    BOOL proximate = YES;
    NSLog(@"SuspendResume: proximity state = %d", proximate);
    
    SBApplication *runningApp = [(SpringBoard *)self _accessibilityFrontMostApplication];
    
    
    if ([[UIDevice currentDevice] proximityState] == YES) {
        
        NSLog(@"SuspendResume: Recieved second proximity state, now locking/suspending device");
        
        if (onlySuspend) {
            NSLog(@"SuspendResume: Device suspended");
            [dict release];
            return;
        }
        else {
            if (runningApp == nil) {
                
                [self performSelector:@selector(lockTheDevice)];
            }
            else {
                
                [runningApp notifyResignActiveForReason:1];
                [self performSelector:@selector(lockTheDevice)];
            }
            
            NSLog(@"SuspendResume: Device locked");
        }
    }
    [dict release];
}


static void _logos_method$_ungrouped$SpringBoard$lockTheDevice(SpringBoard* self, SEL _cmd) {
    SBUIController *controller = (SBUIController *)[_logos_static_class_lookup$SBUIController() sharedInstance];
    if ([controller respondsToSelector:@selector(lock)])
        [controller lock];
    if ([controller respondsToSelector:@selector(lockFromSource:)])
        [controller lockFromSource:0];
    
}








static void _logos_method$_ungrouped$SBTelephonyManager$airplaneModeChanged(SBTelephonyManager* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBTelephonyManager$airplaneModeChanged(self, _cmd);
    
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:tweakOn];
    [dict release];
}





static void _logos_method$_ungrouped$SBApplicationIcon$launch(SBApplicationIcon* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBApplicationIcon$launch(self, _cmd);
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    if (tweakOn) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.matchstick.suspendresume.applaunched" object:nil];
        NSLog(@"SuspendResume: App launched notification has been sent");
    }
    [dict release];
}


















        













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



static void appHasLaunched(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSLog(@"SuspendResume: recieved app launched notification");
    
    SBApplication *runningApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    BOOL blacklist = [[dict objectForKey:[@"Blacklist-" stringByAppendingString:[runningApp displayIdentifier]]] boolValue];
    if (blacklist) {
        [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:NO];
        NSLog(@"SuspendResume: app is blacklisted, temporarily disabled.");
    }
    [dict release];
}


static void suspendSettingsChangedNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
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

static __attribute__((constructor)) void _logosLocalCtor_60b1dd2a() {
    @autoreleasepool {
    {Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(_performDeferredLaunchWork), (IMP)&_logos_method$_ungrouped$SpringBoard$_performDeferredLaunchWork, (IMP*)&_logos_orig$_ungrouped$SpringBoard$_performDeferredLaunchWork);MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(setExpectsFaceContact:), (IMP)&_logos_method$_ungrouped$SpringBoard$setExpectsFaceContact$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$setExpectsFaceContact$);MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(_proximityChanged:), (IMP)&_logos_method$_ungrouped$SpringBoard$_proximityChanged$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$_proximityChanged$);MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(clearIdleTimer), (IMP)&_logos_method$_ungrouped$SpringBoard$clearIdleTimer, (IMP*)&_logos_orig$_ungrouped$SpringBoard$clearIdleTimer);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(secondProximityState), (IMP)&_logos_method$_ungrouped$SpringBoard$secondProximityState, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(lockTheDevice), (IMP)&_logos_method$_ungrouped$SpringBoard$lockTheDevice, _typeEncoding); }Class _logos_class$_ungrouped$SBTelephonyManager = objc_getClass("SBTelephonyManager"); MSHookMessageEx(_logos_class$_ungrouped$SBTelephonyManager, @selector(airplaneModeChanged), (IMP)&_logos_method$_ungrouped$SBTelephonyManager$airplaneModeChanged, (IMP*)&_logos_orig$_ungrouped$SBTelephonyManager$airplaneModeChanged);Class _logos_class$_ungrouped$SBApplicationIcon = objc_getClass("SBApplicationIcon"); MSHookMessageEx(_logos_class$_ungrouped$SBApplicationIcon, @selector(launch), (IMP)&_logos_method$_ungrouped$SBApplicationIcon$launch, (IMP*)&_logos_orig$_ungrouped$SBApplicationIcon$launch);}
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &suspendSettingsChangedNotify, CFSTR("com.matchstick.suspendresume.changed"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &appHasLaunched, CFSTR("com.matchstick.suspendresume.applaunched"), NULL, 0);
    
    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, telephonyEventCallback, NULL, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}
