//
//  AppDelegate.m
//  Minutes
//
//  Created by Filip Jakobsen on 02/01/14.
//  Copyright (c) 2014 stronger. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    return YES;
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if ([application applicationState] != UIApplicationStateActive) return;
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], notification.soundName]];
    
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 0;
    
    if (audioPlayer == nil) NSLog(@"Error with sound");
    else [audioPlayer play];
    
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
