//
//  TodayViewController.m
//  FannyWidget
//
//  Created by Daniel Storm on 1/26/16.
//  Copyright © 2016 Daniel Storm. All rights reserved.
//  https://itunes.apple.com/us/developer/daniel-storm/id432169230?
//
//  Licensed under the GNU General Public License.
// 

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding> {
    // NSTextField
    __weak IBOutlet NSTextField *temperatureTextField;
    __weak IBOutlet NSTextField *fanRPMTextField;
    //__weak IBOutlet NSTextField *fanTarTextField;
    //__weak IBOutlet NSTextField *fanMinTextField;
    //__weak IBOutlet NSTextField *fanMaxTextField;
    
    // NSTimer
    NSTimer *updateWidgetTimer;
    
    // Int
    int fanToDisplay;
    int numberOfFans;
    
    // NSButton
    NSButton *radioButton;
    
    // Float
    float staticPadding;
}

@end

@implementation TodayViewController

-(void)viewWillDisappear {
    //NSLog(@"viewWillDisappear");
}

-(IBAction)radioButtonClicked:(id)sender {
    // Cast sender as NSButton
    NSButton *tempButton = (NSButton *)sender;
    
    // Get tag number so we know which fan to display // Starts at 0
    fanToDisplay = (int)[tempButton tag];
    //NSLog(@"radio button clicked with tag: %d", (int)[tempButton tag]);
    
    // Update stats with fan selected
    [self updateWidget];
}

-(void)viewDidLoad {
    NSLog(@"viewDidLoad");
    // Get stats
    [self updateWidget];
    
    // Get number of fans
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"TodayExtensionSharingDefaults"];
    numberOfFans = (int)[defaults integerForKey:@"numberOfFans"];
    //NSLog(@"Number of fans: %d", numberOfFans);
    
    // Set padding between buttons
    staticPadding = 30;
    
    // Set fan to first fan
    fanToDisplay = 0;
}

-(void)viewDidAppear {
    //NSLog(@"viewDidAppear");
    // Get stats timer
    [updateWidgetTimer invalidate];
    updateWidgetTimer = nil;
    updateWidgetTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                         target:self
                                                       selector:@selector(updateWidget)
                                                       userInfo:nil
                                                        repeats:YES];
    
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.DanielStorm.Fanny"] count] > 1) {
        // Terminate old app
        NSLog(@"more than one app running");
        for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
            //            NSLog(@"\n\nApp: %@", app);
            if ([app.bundleIdentifier isEqualToString:@"com.DanielStorm.Fanny"]) {
                NSLog(@"\n\nterminated: %@", app);
                // Does not work due to the widget being sandboxed
                //                [app forceTerminate];
                //                if ([app forceTerminate]) {
                //                    NSLog(@"\n\n********\n\nForce Terminated: %@", app);
                //                }
            }
        }
    }
    
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.DanielStorm.Fanny"] count] < 1) {
        // Open app
        //NSLog(@"app not running");
        
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"Fanny://"]];
    }
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.DanielStorm.Fanny"] count] == 1) {
        // App running // Do nothing
        //NSLog(@"app running");
    }
    
    // Create radio buttons
    // Need to fix this logic
    for (int i = numberOfFans - 1; i >= 0; i--) { // (int i = 0; i < numberOfFans; i++)
        radioButton = [NSButton new];
        [radioButton setButtonType: NSRadioButton]; // Set button type
        [radioButton setTag: (i - numberOfFans + 1) * -1]; // Set tag to fan number // Starts at 0
        [radioButton setControlSize:NSControlSizeMini]; // Make mini
        [radioButton setFrame:CGRectMake(self.view.frame.size.width - (i * staticPadding + 36), self.view.frame.size.height - 23, 22, 26)]; // Set frame
        [radioButton setTarget:self];
        [radioButton setAction:@selector(radioButtonClicked:)]; // Add action
        [self.view addSubview:radioButton]; // Add button to view
        
        // Set first radio button as selected
        if (i == numberOfFans - 1) {
            [radioButton setNextState];
        }
    }
}

-(void)updateWidget {
    // Setup NSUserDefaults
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"TodayExtensionSharingDefaults"];
    
    // Update temperature
    int temperatureFloat = roundf([defaults floatForKey:@"temperature"]);
    [temperatureTextField setStringValue:[NSString stringWithFormat:@"%d °",temperatureFloat]];
    
    // Update fan actual
    int fanRPMInt = (int)[defaults integerForKey:[NSString stringWithFormat:@"fan%dActual", fanToDisplay]];
    [fanRPMTextField setStringValue:[NSString stringWithFormat:@"%d RPM",fanRPMInt]];
    
    // Update fan target
    //int fanTarInt = (int)[defaults integerForKey:[NSString stringWithFormat:@"fan%dTarget", fanToDisplay]];
    //[fanTarTextField setStringValue:[NSString stringWithFormat:@"%d RPM",fanTarInt]];
    
    // Update fan minimum
    //int fanMinInt = (int)[defaults integerForKey:[NSString stringWithFormat:@"fan%dMin", fanToDisplay]];
    //[fanMinTextField setStringValue:[NSString stringWithFormat:@"%d RPM",fanMinInt]];
    
    // Update fan maximum
    //int fanMaxInt = (int)[defaults integerForKey:[NSString stringWithFormat:@"fan%dMax", fanToDisplay]];
    //[fanMaxTextField setStringValue:[NSString stringWithFormat:@"%d RPM",fanMaxInt]];
}

-(void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    
    [self updateWidget];
    
    //NSLog(@"NCUpdateResultNewData");
    completionHandler(NCUpdateResultNewData);
}

- (IBAction)clicked:(id)sender {
}
@end

