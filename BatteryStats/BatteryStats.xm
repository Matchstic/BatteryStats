#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBAwayController.h>

#define settingsFile @"/var/mobile/Library/Preferences/BatteryStats-prefs.plist"

static NSTimer *timer;

%hook SpringBoard

// Breakage point with iOS releases, good for iOS 5.0+, not for 4.3.x
-(void)_performDeferredLaunchWork {
    %orig;
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    
    // Check if prefs exists
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:settingsFile];
    if (!fileExists) {
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        
        [data setObject:[NSNumber numberWithFloat:30] forKey:@"refreshRate"];
        
        [data writeToFile:settingsFile atomically:YES];
        [data release];
    }

    NSDictionary *settings = [[[NSDictionary alloc] initWithContentsOfFile:settingsFile] autorelease];
    double interval = [[settings objectForKey:@"refreshRate"] doubleValue];
    
    // potential breakage point?
    timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(batteryLevelChanged) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:) name:@"UIDeviceBatteryStateDidChangeNotification" object:[UIDevice currentDevice]];
}

%new 
- (void)batteryStateChanged:(NSNotification *)notification {
    // Get charging state
    int m = [UIDevice currentDevice].batteryState; // iOS 3.0+
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
    
    // Write to txt file
    // We should load the contents of the file into an array, edit as appropriate, then write the resulting strings to the file.
    NSError *error;
    NSString *filePath = @"/var/mobile/Library/BatteryStats.txt";
    
    /*NSMutableArray *lines = [[NSString stringWithContentsOfFile:filePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil]
                             componentsSeparatedByString:@"\n"];*/
    
    NSString *fileString = [NSString stringWithContentsOfFile:filePath
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    
    NSMutableArray *lines = [NSMutableArray arrayWithArray:[fileString componentsSeparatedByString:@"\n"]];
    
    // Crashes here
    [lines removeObjectAtIndex:1];
    [lines insertObject:state atIndex:1];
    
    NSString *write = [lines componentsJoinedByString:@"\n"];
    
    [write writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    // Done!
}

%new
-(void)batteryLevelChanged {
    // Get battery value
    
    // breakage point, good for iOS 4.3+
    int percent = [(SBUIController*)[objc_getClass("SBUIController") sharedInstance] displayBatteryCapacityAsPercentage];
    
    NSString *finalLevel = [@"Level: " stringByAppendingString:[NSString stringWithFormat:@"%d",percent]];
    
    NSError *error;
    NSString *filePath = @"/var/mobile/Library/BatteryStats.txt";
    
    NSString *fileString = [NSString stringWithContentsOfFile:filePath
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    
    NSMutableArray *lines = [NSMutableArray arrayWithArray:[fileString componentsSeparatedByString:@"\n"]];
    
    // Crashes here
    [lines removeObjectAtIndex:0];
    [lines insertObject:finalLevel atIndex:0];
    
    NSString *write = [lines componentsJoinedByString:@"\n"];
    
    [write writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

%end

%hook SBAwayController

-(void)undimScreen:(BOOL)arg1 {
    %orig;
    
    // Let's set our new levels/states when coming out of sleep!
    [(SpringBoard*)[UIApplication sharedApplication] batteryLevelChanged];
    [(SpringBoard*)[UIApplication sharedApplication] batteryStateChanged:nil];
}

%end