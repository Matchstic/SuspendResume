#line 1 "/Users/Matt/iOS/Projects/suspendresume/suspendresume/uiapplicationdelegate.xm"




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

#include <logos/logos.h>
#include <substrate.h>
@class UIApplicationDelegate; 
static void (*_logos_orig$_ungrouped$UIApplicationDelegate$applicationDidBecomeActive$)(UIApplicationDelegate*, SEL, id); static void _logos_method$_ungrouped$UIApplicationDelegate$applicationDidBecomeActive$(UIApplicationDelegate*, SEL, id); static void _logos_method$_ungrouped$UIApplicationDelegate$proximityChange$(UIApplicationDelegate*, SEL, NSNotification*); static void _logos_method$_ungrouped$UIApplicationDelegate$lockDeviceAfterDelay(UIApplicationDelegate*, SEL); 

#line 25 "/Users/Matt/iOS/Projects/suspendresume/suspendresume/uiapplicationdelegate.xm"


static void _logos_method$_ungrouped$UIApplicationDelegate$applicationDidBecomeActive$(UIApplicationDelegate* self, SEL _cmd, id application) {
    _logos_orig$_ungrouped$UIApplicationDelegate$applicationDidBecomeActive$(self, _cmd, application);

    
    [self performSelector:@selector(proximityChange:)];
}




static void _logos_method$_ungrouped$UIApplicationDelegate$proximityChange$(UIApplicationDelegate* self, SEL _cmd, NSNotification* notification) {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    
    if (tweakOn) {
        
        
        if ([[UIDevice currentDevice] proximityState] == YES) {
            
            
            [self performSelector:@selector(lockDeviceAfterDelay) withObject:nil afterDelay:1.0];
        }
    }
}



static void _logos_method$_ungrouped$UIApplicationDelegate$lockDeviceAfterDelay(UIApplicationDelegate* self, SEL _cmd) {
    
    
    if ([[UIDevice currentDevice] proximityState] == YES) {
        
        
        GSEventLockDevice();
    }
}



static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$UIApplicationDelegate = objc_getClass("UIApplicationDelegate"); MSHookMessageEx(_logos_class$_ungrouped$UIApplicationDelegate, @selector(applicationDidBecomeActive:), (IMP)&_logos_method$_ungrouped$UIApplicationDelegate$applicationDidBecomeActive$, (IMP*)&_logos_orig$_ungrouped$UIApplicationDelegate$applicationDidBecomeActive$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSNotification*), strlen(@encode(NSNotification*))); i += strlen(@encode(NSNotification*)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplicationDelegate, @selector(proximityChange:), (IMP)&_logos_method$_ungrouped$UIApplicationDelegate$proximityChange$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplicationDelegate, @selector(lockDeviceAfterDelay), (IMP)&_logos_method$_ungrouped$UIApplicationDelegate$lockDeviceAfterDelay, _typeEncoding); }} }
#line 70 "/Users/Matt/iOS/Projects/suspendresume/suspendresume/uiapplicationdelegate.xm"
