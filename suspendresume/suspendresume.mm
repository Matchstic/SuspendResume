#line 1 "/Users/Matt/iOS/Projects/suspendresume/suspendresume/suspendresume.xm"




#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBTelephonyManager.h>
#import <GraphicsServices/GSEvent.h>
#include <notify.h>

static NSString *settingsFile = @"/var/mobile/Library/Preferences/com.matchstick.suspendresume.plist";
static BOOL tweakOn;
static BOOL _clearIdleTimer;
extern NSString const *CTCallStateDisconnected;

#include <logos/logos.h>
#include <substrate.h>
@class SBTelephonyManager; @class SpringBoard; 
static void (*_logos_orig$_ungrouped$SpringBoard$_performDeferredLaunchWork)(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$_performDeferredLaunchWork(SpringBoard*, SEL); static void (*_logos_orig$_ungrouped$SpringBoard$setExpectsFaceContact$)(SpringBoard*, SEL, BOOL); static void _logos_method$_ungrouped$SpringBoard$setExpectsFaceContact$(SpringBoard*, SEL, BOOL); static void (*_logos_orig$_ungrouped$SpringBoard$_proximityChanged$)(SpringBoard*, SEL, NSNotification*); static void _logos_method$_ungrouped$SpringBoard$_proximityChanged$(SpringBoard*, SEL, NSNotification*); static void (*_logos_orig$_ungrouped$SpringBoard$clearIdleTimer)(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$clearIdleTimer(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$setFaceAfterTelephony$(SpringBoard*, SEL, NSNotification*); static void (*_logos_orig$_ungrouped$SBTelephonyManager$airplaneModeChanged)(SBTelephonyManager*, SEL); static void _logos_method$_ungrouped$SBTelephonyManager$airplaneModeChanged(SBTelephonyManager*, SEL); 
static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBTelephonyManager(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBTelephonyManager"); } return _klass; }
#line 17 "/Users/Matt/iOS/Projects/suspendresume/suspendresume/suspendresume.xm"


static void _logos_method$_ungrouped$SpringBoard$_performDeferredLaunchWork(SpringBoard* self, SEL _cmd) {
    
    _logos_orig$_ungrouped$SpringBoard$_performDeferredLaunchWork(self, _cmd);
    
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];

    [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:tweakOn];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFaceAfterTelephony:) name:@"com.apple.springboard.activeCallStateChanged" object:nil];
    
    [dict release];
}

static void _logos_method$_ungrouped$SpringBoard$setExpectsFaceContact$(SpringBoard* self, SEL _cmd, BOOL expectsFaceContact) {
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    _logos_orig$_ungrouped$SpringBoard$setExpectsFaceContact$(self, _cmd, tweakOn);
    
    
    NSLog(@"******** I'll be back... *********");
    
    [dict release];
}


static void _logos_method$_ungrouped$SpringBoard$_proximityChanged$(SpringBoard* self, SEL _cmd, NSNotification* notification) {
    
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    double timeInterval = [[dict objectForKey:@"interval"] doubleValue];
    
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
        
        
        NSLog(@"Received first proximity state");
        
        
        [NSThread sleepForTimeInterval:timeInterval];
        
        
        if (proximate) {
            
            
            NSLog(@"Recieved second proximity state, now locking device");
            
            if (runningApp == nil) {
                
                
                
                GSEventLockDevice();
            }
            
            else {
                
                
                [runningApp notifyResignActiveForReason:1];
                
                
                GSEventLockDevice();
            }
            
            
            NSLog(@"Device locked");
        }
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




static void _logos_method$_ungrouped$SpringBoard$setFaceAfterTelephony$(SpringBoard* self, SEL _cmd, NSNotification* notification) {
    
    NSLog(@"setFaceAfterTelephony is being run!");
    
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    if (!([[_logos_static_class_lookup$SBTelephonyManager() sharedTelephonyManager] inCall])) {
        NSLog(@"Call not connected, changing expectsFaceContact accordingly.");
        [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:tweakOn];
    }
}








static void _logos_method$_ungrouped$SBTelephonyManager$airplaneModeChanged(SBTelephonyManager* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBTelephonyManager$airplaneModeChanged(self, _cmd);
    
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    [(SpringBoard *)[UIApplication sharedApplication] setExpectsFaceContact:tweakOn];
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(_performDeferredLaunchWork), (IMP)&_logos_method$_ungrouped$SpringBoard$_performDeferredLaunchWork, (IMP*)&_logos_orig$_ungrouped$SpringBoard$_performDeferredLaunchWork);MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(setExpectsFaceContact:), (IMP)&_logos_method$_ungrouped$SpringBoard$setExpectsFaceContact$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$setExpectsFaceContact$);MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(_proximityChanged:), (IMP)&_logos_method$_ungrouped$SpringBoard$_proximityChanged$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$_proximityChanged$);MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(clearIdleTimer), (IMP)&_logos_method$_ungrouped$SpringBoard$clearIdleTimer, (IMP*)&_logos_orig$_ungrouped$SpringBoard$clearIdleTimer);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSNotification*), strlen(@encode(NSNotification*))); i += strlen(@encode(NSNotification*)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(setFaceAfterTelephony:), (IMP)&_logos_method$_ungrouped$SpringBoard$setFaceAfterTelephony$, _typeEncoding); }Class _logos_class$_ungrouped$SBTelephonyManager = objc_getClass("SBTelephonyManager"); MSHookMessageEx(_logos_class$_ungrouped$SBTelephonyManager, @selector(airplaneModeChanged), (IMP)&_logos_method$_ungrouped$SBTelephonyManager$airplaneModeChanged, (IMP*)&_logos_orig$_ungrouped$SBTelephonyManager$airplaneModeChanged);} }
#line 162 "/Users/Matt/iOS/Projects/suspendresume/suspendresume/suspendresume.xm"
