//
//  AppDelegate.h
//  Minutes
//
//  Created by Filip Jakobsen on 02/01/14.
//  Copyright (c) 2014 stronger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@class DragViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    AVAudioPlayer *audioPlayer;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) IBOutlet DragViewController *viewController;

@end
