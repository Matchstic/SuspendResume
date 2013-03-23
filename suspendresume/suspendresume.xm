// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos
// SuspendResume by Matt Clarke (matchstick, matchstick-dev on Github and some other places)

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

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    // Allow SpringBoard to initialise
    %orig;

    // Set up proximity monitoring
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[UIDevice currentDevice] proximityState];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

%new

// Add new code into SpringBoard
-(void)proximityChange:(NSNotification*)notification {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];

    // Check if tweak is on
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    // Check for time interval - the value is stored in <real> tags
    double timeInterval = [[dict objectForKey:@"interval"] doubleValue];
    
    // Only run if tweak is on
    if (tweakOn) {

        // Get first proximity value
        if ([[UIDevice currentDevice] proximityState] == YES) {

            // Wait a few seconds FIXME causes a lockup of interface whilst waiting
            [self performSelector:@selector(lockDeviceAfterDelay) withObject:nil afterDelay:timeInterval];
        }
    }
    
    // Turn off proximity monitoring if tweak isn't enabled
    else {
        // Check if proximity monitoring is enabled
        BOOL proximityOn = [[UIDevice currentDevice] isProximityMonitoringEnabled];
        
        if (proximityOn) {
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
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

//%group DelegateHooks
//%hook UIApplicationDelegate

//-(void)applicationDidFinishLaunching:(id)application {
//    %orig;
//    %log;
    
    // Set up proximity monitoring
//    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
//    [[UIDevice currentDevice] proximityState];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
//}

//%new

//-(void)proximityChange:(NSNotification*)notification {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Testing"
//                                                    message:@"Proximity changed"
//                                                   delegate:nil
//                                          cancelButtonTitle:@"Thanks"
//                                          otherButtonTitles:nil];
//    [alert show];
//}

//%end
//%end

//%hook UIApplication

// From iPhone-backgrounder
//-(void)_loadMainNibFile {
//    %orig;
    // Delegate if it exists, UIApplication subclass if not.
//    Class delegateClass = [[self delegate] class] ?: [self class];
//    %init(DelegateHooks, UIApplicationDelegate = delegateClass);
    
    // Run proximity method
//    [self performSelector:@selector(proximityChange:)];
//}

//%new

// Add new code into application
//-(void)proximityChange:(NSNotification*)notification {
//    %log;
//    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    // Check if tweak is on
//    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:settingsFile];
//    tweakOn = [[dict objectForKey:@"enabled"] boolValue];
    
    // Only run if tweak is on
//    if (tweakOn) {
        
        // Get first proximity value
//        if ([[UIDevice currentDevice] proximityState] == YES) {
            
            // Wait a few seconds TODO allow changing of wait interval from prefrences FIXME causes a lockup of interface whilst sleeping
//            [self performSelector:@selector(lockDeviceAfterDelay) withObject:nil afterDelay:0.5];
//        }
//    }
//}

//%new

//-(void)lockDeviceAfterDelay {
    
    // Second proximity value
//    if ([[UIDevice currentDevice] proximityState] == YES) {
        
        // Lock device
//        GSEventLockDevice();
//    }
//}


//%end

//static __attribute__((constructor)) void localInit() {
//    %init;
//}