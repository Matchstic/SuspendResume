#line 1 "/Users/Matt/iOS/Projects/suspendresume/suspendresume/suspendresume.xm"




#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/UIApplicationDelegate.h>
#import <GraphicsServices/GSEvent.h>
#include <notify.h>

@interface suspendresume : NSObject 

@property(nonatomic, readonly) BOOL proximityState;

@end

@implementation suspendresume

BOOL tweakOn;

@end

static NSString *settingsFile = @"/var/mobile/Library/Preferences/com.matchstick.suspendresume.plist";

#include <logos/logos.h>
#include <substrate.h>
@class UIApplication; @class UIApplicationDelegate; @class SpringBoard; 
static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$proximityChange$(SpringBoard*, SEL, NSNotification*); static void _logos_method$_ungrouped$SpringBoard$lockDeviceAfterDelay(SpringBoard*, SEL); static void (*_logos_orig$_ungrouped$UIApplication$_loadMainNibFile)(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$_loadMainNibFile(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$proximityChange$(UIApplication*, SEL, NSNotification*); static void _logos_method$_ungrouped$UIApplication$lockDeviceAfterDelay(UIApplication*, SEL); 

#line 26 "/Users/Matt/iOS/Projects/suspendresume/suspendresume/suspendresume.xm"


static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(SpringBoard* self, SEL _cmd, id application) {
    
    _logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);

    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[UIDevice currentDevice] proximityState];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}




static void _logos_method$_ungrouped$SpringBoard$proximityChange$(SpringBoard* self, SEL _cmd, NSNotification* notification) {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];

    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    
    if (tweakOn) {

        
        if ([[UIDevice currentDevice] proximityState] == YES) {

            
            [self performSelector:@selector(lockDeviceAfterDelay) withObject:nil afterDelay:1.0];
        }
    }
}



static void _logos_method$_ungrouped$SpringBoard$lockDeviceAfterDelay(SpringBoard* self, SEL _cmd) {
    
    
    if ([[UIDevice currentDevice] proximityState] == YES) {
        
        
        GSEventLockDevice();
    }
}



static void (*_logos_orig$DelegateHooks$UIApplicationDelegate$applicationDidFinishLaunching$)(id, SEL, id); static void _logos_method$DelegateHooks$UIApplicationDelegate$applicationDidFinishLaunching$(id, SEL, id); static void _logos_method$DelegateHooks$UIApplicationDelegate$proximityChange$(id, SEL, NSNotification*); 


static void _logos_method$DelegateHooks$UIApplicationDelegate$applicationDidFinishLaunching$(id self, SEL _cmd, id application) {
    _logos_orig$DelegateHooks$UIApplicationDelegate$applicationDidFinishLaunching$(self, _cmd, application);
    NSLog(@"-[<UIApplicationDelegate: %p> applicationDidFinishLaunching:%@]", self, application);
    
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[UIDevice currentDevice] proximityState];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}



static void _logos_method$DelegateHooks$UIApplicationDelegate$proximityChange$(id self, SEL _cmd, NSNotification* notification) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Testing"
                                                    message:@"Proximity changed"
                                                   delegate:nil
                                          cancelButtonTitle:@"Thanks"
                                          otherButtonTitles:nil];
    [alert show];
}







static void _logos_method$_ungrouped$UIApplication$_loadMainNibFile(UIApplication* self, SEL _cmd) {
    _logos_orig$_ungrouped$UIApplication$_loadMainNibFile(self, _cmd);
    
    Class delegateClass = [[self delegate] class] ?: [self class];
    {Class _logos_class$DelegateHooks$UIApplicationDelegate = delegateClass; MSHookMessageEx(_logos_class$DelegateHooks$UIApplicationDelegate, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$DelegateHooks$UIApplicationDelegate$applicationDidFinishLaunching$, (IMP*)&_logos_orig$DelegateHooks$UIApplicationDelegate$applicationDidFinishLaunching$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSNotification*), strlen(@encode(NSNotification*))); i += strlen(@encode(NSNotification*)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$DelegateHooks$UIApplicationDelegate, @selector(proximityChange:), (IMP)&_logos_method$DelegateHooks$UIApplicationDelegate$proximityChange$, _typeEncoding); }}
    
    
    [self performSelector:@selector(proximityChange:)];
}




static void _logos_method$_ungrouped$UIApplication$proximityChange$(UIApplication* self, SEL _cmd, NSNotification* notification) {
    NSLog(@"-[<UIApplication: %p> proximityChange:%@]", self, notification);
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    
    if (tweakOn) {
        
        
        if ([[UIDevice currentDevice] proximityState] == YES) {
            
            
            [self performSelector:@selector(lockDeviceAfterDelay) withObject:nil afterDelay:1.0];
        }
    }
}



static void _logos_method$_ungrouped$UIApplication$lockDeviceAfterDelay(UIApplication* self, SEL _cmd) {
    
    
    if ([[UIDevice currentDevice] proximityState] == YES) {
        
        
        GSEventLockDevice();
    }
}




static __attribute__((constructor)) void localInit() {
    {Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSNotification*), strlen(@encode(NSNotification*))); i += strlen(@encode(NSNotification*)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(proximityChange:), (IMP)&_logos_method$_ungrouped$SpringBoard$proximityChange$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(lockDeviceAfterDelay), (IMP)&_logos_method$_ungrouped$SpringBoard$lockDeviceAfterDelay, _typeEncoding); }Class _logos_class$_ungrouped$UIApplication = objc_getClass("UIApplication"); MSHookMessageEx(_logos_class$_ungrouped$UIApplication, @selector(_loadMainNibFile), (IMP)&_logos_method$_ungrouped$UIApplication$_loadMainNibFile, (IMP*)&_logos_orig$_ungrouped$UIApplication$_loadMainNibFile);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSNotification*), strlen(@encode(NSNotification*))); i += strlen(@encode(NSNotification*)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(proximityChange:), (IMP)&_logos_method$_ungrouped$UIApplication$proximityChange$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(lockDeviceAfterDelay), (IMP)&_logos_method$_ungrouped$UIApplication$lockDeviceAfterDelay, _typeEncoding); }}
}
