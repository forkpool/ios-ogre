//
//         DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
//                     Version 2, December 2004
//
//  Copyright (C) 2013 Clodéric Mars <cloderic.mars@gmail.com>
//
//  Everyone is permitted to copy and distribute verbatim or modified
//  copies of this license document, and changing it is allowed as long
//  as the name is changed.
//
//             DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
//    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
//
//   0. You just DO WHAT THE FUCK YOU WANT TO.

#ifndef __AppDelegate_H__
#define __AppDelegate_H__

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class ViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate>
{
    // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
    // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
    // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
    // isn't available.
    id mDisplayLink;
    NSDate *mDate;
    double mLastFrameTime;
    double mStartTime;
}

- (void)renderOneFrame:(id)sender;

@property (nonatomic) double mLastFrameTime;
@property (nonatomic) double mStartTime;

@property (strong, nonatomic) UIWindow* mWindow;
@property (strong, nonatomic) ViewController* mViewController;

@end

#endif
