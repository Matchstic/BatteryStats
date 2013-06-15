#line 1 "/Users/Matt/iOS/Projects/BatteryStats/BatteryStats/BatteryStats.xm"
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBAwayController.h>

#define settingsFile @"/var/mobile/Library/Preferences/BatteryStats-prefs.plist"

static NSTimer *timer;

@interface SpringBoard (BatteryStats)

-(void)batteryLevelChanged;
-(void)batteryStateChanged:(NSNotification *)notification;

@end

#include <logos/logos.h>
#include <substrate.h>
@class SBAwayController; @class SpringBoard; 
static void (*_logos_orig$_ungrouped$SpringBoard$_performDeferredLaunchWork)(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$_performDeferredLaunchWork(SpringBoard*, SEL); static void _logos_method$_ungrouped$SpringBoard$batteryStateChanged$(SpringBoard*, SEL, NSNotification *); static void _logos_method$_ungrouped$SpringBoard$batteryLevelChanged(SpringBoard*, SEL); static void (*_logos_orig$_ungrouped$SBAwayController$undimScreen$)(SBAwayController*, SEL, BOOL); static void _logos_method$_ungrouped$SBAwayController$undimScreen$(SBAwayController*, SEL, BOOL); static void (*_logos_orig$_ungrouped$SBAwayController$undimScreen)(SBAwayController*, SEL); static void _logos_method$_ungrouped$SBAwayController$undimScreen(SBAwayController*, SEL); 

#line 16 "/Users/Matt/iOS/Projects/BatteryStats/BatteryStats/BatteryStats.xm"



static void _logos_method$_ungrouped$SpringBoard$_performDeferredLaunchWork(SpringBoard* self, SEL _cmd) {
    _logos_orig$_ungrouped$SpringBoard$_performDeferredLaunchWork(self, _cmd);
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:settingsFile];
    if (!fileExists) {
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        
        [data setObject:[NSNumber numberWithFloat:30] forKey:@"refreshRate"];
        
        [data writeToFile:settingsFile atomically:YES];
        [data release];
    }

    NSDictionary *settings = [[[NSDictionary alloc] initWithContentsOfFile:settingsFile] autorelease];
    double interval = [[settings objectForKey:@"refreshRate"] doubleValue];
    
    
    timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(batteryLevelChanged) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:) name:@"UIDeviceBatteryStateDidChangeNotification" object:[UIDevice currentDevice]];
}

 
static void _logos_method$_ungrouped$SpringBoard$batteryStateChanged$(SpringBoard* self, SEL _cmd, NSNotification * notification) {
    
    int m = [UIDevice currentDevice].batteryState; 
    NSString *state = nil;
    switch (m) {
        case UIDeviceBatteryStateUnplugged: {
            state = @"State: Unplugged";
            break;
        }
        case UIDeviceBatteryStateCharging: {
            state = @"State: Charging";
            break;
        }
        case UIDeviceBatteryStateFull: {
            state = @"State: Fully charged";
            break;
        }
        default: {
            state = @"State: Unknown";
            break;
        }
    }
    
    
    
    NSError *error;
    NSString *filePath = @"/var/mobile/Library/BatteryStats.txt";
    
    



    
    NSString *fileString = [NSString stringWithContentsOfFile:filePath
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    
    NSMutableArray *lines = [NSMutableArray arrayWithArray:[fileString componentsSeparatedByString:@"\n"]];
    
    
    [lines removeObjectAtIndex:1];
    [lines insertObject:state atIndex:1];
    
    NSString *write = [lines componentsJoinedByString:@"\n"];
    
    [write writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    
}


static void _logos_method$_ungrouped$SpringBoard$batteryLevelChanged(SpringBoard* self, SEL _cmd) {
    
    
    
    int percent = [(SBUIController*)[objc_getClass("SBUIController") sharedInstance] displayBatteryCapacityAsPercentage];
    
    NSString *finalLevel = [@"Level: " stringByAppendingString:[NSString stringWithFormat:@"%d",percent]];
    
    NSError *error;
    NSString *filePath = @"/var/mobile/Library/BatteryStats.txt";
    
    NSString *fileString = [NSString stringWithContentsOfFile:filePath
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    
    NSMutableArray *lines = [NSMutableArray arrayWithArray:[fileString componentsSeparatedByString:@"\n"]];
    
    
    [lines removeObjectAtIndex:0];
    [lines insertObject:finalLevel atIndex:0];
    
    NSString *write = [lines componentsJoinedByString:@"\n"];
    
    [write writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}






static void _logos_method$_ungrouped$SBAwayController$undimScreen$(SBAwayController* self, SEL _cmd, BOOL arg1) {
    _logos_orig$_ungrouped$SBAwayController$undimScreen$(self, _cmd, arg1);
    
    
    [(SpringBoard*)[UIApplication sharedApplication] batteryLevelChanged];
    [(SpringBoard*)[UIApplication sharedApplication] batteryStateChanged:nil];
}


static void _logos_method$_ungrouped$SBAwayController$undimScreen(SBAwayController* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBAwayController$undimScreen(self, _cmd);
    
    
    [(SpringBoard*)[UIApplication sharedApplication] batteryLevelChanged];
    [(SpringBoard*)[UIApplication sharedApplication] batteryStateChanged:nil];
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(_performDeferredLaunchWork), (IMP)&_logos_method$_ungrouped$SpringBoard$_performDeferredLaunchWork, (IMP*)&_logos_orig$_ungrouped$SpringBoard$_performDeferredLaunchWork);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSNotification *), strlen(@encode(NSNotification *))); i += strlen(@encode(NSNotification *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(batteryStateChanged:), (IMP)&_logos_method$_ungrouped$SpringBoard$batteryStateChanged$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(batteryLevelChanged), (IMP)&_logos_method$_ungrouped$SpringBoard$batteryLevelChanged, _typeEncoding); }Class _logos_class$_ungrouped$SBAwayController = objc_getClass("SBAwayController"); MSHookMessageEx(_logos_class$_ungrouped$SBAwayController, @selector(undimScreen:), (IMP)&_logos_method$_ungrouped$SBAwayController$undimScreen$, (IMP*)&_logos_orig$_ungrouped$SBAwayController$undimScreen$);MSHookMessageEx(_logos_class$_ungrouped$SBAwayController, @selector(undimScreen), (IMP)&_logos_method$_ungrouped$SBAwayController$undimScreen, (IMP*)&_logos_orig$_ungrouped$SBAwayController$undimScreen);} }
#line 144 "/Users/Matt/iOS/Projects/BatteryStats/BatteryStats/BatteryStats.xm"
