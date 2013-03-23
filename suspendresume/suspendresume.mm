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
@class SpringBoard; 
static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(SpringBoard*, SEL, id); static void _logos_method$_ungrouped$SpringBoard$proximityChange$(SpringBoard*, SEL, NSNotification*); static void _logos_method$_ungrouped$SpringBoard$lockDeviceAfterDelay(SpringBoard*, SEL); 

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
    
    
    double timeInterval = [[dict objectForKey:@"interval"] doubleValue];
    
    
    if (tweakOn) {

        
        if ([[UIDevice currentDevice] proximityState] == YES) {

            
            [self performSelector:@selector(lockDeviceAfterDelay) withObject:nil afterDelay:timeInterval];
        }
    }
    
    
    else {
        
        BOOL proximityOn = [[UIDevice currentDevice] isProximityMonitoringEnabled];
        
        if (proximityOn) {
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}



static void _logos_method$_ungrouped$SpringBoard$lockDeviceAfterDelay(SpringBoard* self, SEL _cmd) {
    
    
    if ([[UIDevice currentDevice] proximityState] == YES) {
        
        
        GSEventLockDevice();
    }
}









    
    
























    


    
    









    
    


    
    

        
        

            
            








    
    

        
        










static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSNotification*), strlen(@encode(NSNotification*))); i += strlen(@encode(NSNotification*)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(proximityChange:), (IMP)&_logos_method$_ungrouped$SpringBoard$proximityChange$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(lockDeviceAfterDelay), (IMP)&_logos_method$_ungrouped$SpringBoard$lockDeviceAfterDelay, _typeEncoding); }} }
#line 168 "/Users/Matt/iOS/Projects/suspendresume/suspendresume/suspendresume.xm"
