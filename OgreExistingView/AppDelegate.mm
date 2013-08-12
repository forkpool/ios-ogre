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

#import "AppDelegate.h"

#import "ViewController.h"
#import "OgreView.h"

#include "OgreFramework.h"
#include "OgreDemoApp.h"

// private category
@interface AppDelegate ()
{
    DemoApp demo;
}
@end

@implementation AppDelegate

@dynamic mLastFrameTime;
@dynamic mStartTime;

- (double)mLastFrameTime
{
    return mLastFrameTime;
}

- (void)setLastFrameTime:(double)frameInterval
{
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1)
    {
        mLastFrameTime = frameInterval;
    }
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    self.mWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    self.mViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];

    UIView* view = self.mViewController.view;
    unsigned int width  = view.frame.size.width;
    unsigned int height = view.frame.size.height;
    
    OgreView* ogreView = [[OgreView alloc] initWithFrame:CGRectMake(0,0,width,height)];
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    mLastFrameTime = 1;
    mStartTime = 0;
    
    try
    {
        demo.startDemo(self.mWindow, ogreView, self.mViewController, width, height);
        
        Ogre::Root::getSingleton().getRenderSystem()->_initRenderTargets();
        
        // Clear event times
		Ogre::Root::getSingleton().clearEventTimes();
    }
    catch( Ogre::Exception& e )
    {
        std::cerr << "An exception has occurred: " <<
        e.getFullDescription().c_str() << std::endl;
    }
    
    // Call made here to override Ogre set view controller (cf. http://www.ogre3d.org/forums/viewtopic.php?f=2&t=71508&p=468814&hilit=externalviewhandle#p468814)
    self.mWindow.rootViewController = self.mViewController;
    [view addSubview:ogreView];
    
    // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
    // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
    // not be called in system versions earlier than 3.1.
    mDate = [[NSDate alloc] init];
    mLastFrameTime = -[mDate timeIntervalSinceNow];
    
    mDisplayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(renderOneFrame:)];
    [mDisplayLink setFrameInterval:mLastFrameTime];
    [mDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    [pool release];
    
    [self.mWindow makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    Ogre::Root::getSingleton().queueEndRendering();
    
    [mDate release];
    mDate = nil;
    
    [mDisplayLink invalidate];
    mDisplayLink = nil;

    [[UIApplication sharedApplication] performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    Ogre::Root::getSingleton().saveConfig();
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)renderOneFrame:(id)sender
{
    if(!OgreFramework::getSingletonPtr()->isOgreToBeShutDown() &&
       Ogre::Root::getSingletonPtr() && Ogre::Root::getSingleton().isInitialised())
    {
		if(OgreFramework::getSingletonPtr()->m_pRenderWnd->isActive())
		{
			mStartTime = OgreFramework::getSingletonPtr()->m_pTimer->getMillisecondsCPU();
            
			OgreFramework::getSingletonPtr()->m_pMouse->capture();
            
			OgreFramework::getSingletonPtr()->updateOgre(mLastFrameTime);
			OgreFramework::getSingletonPtr()->m_pRoot->renderOneFrame();
            
			mLastFrameTime = OgreFramework::getSingletonPtr()->m_pTimer->getMillisecondsCPU() - mStartTime;
		}
    }
    else
    {
        [mDate release];
        mDate = nil;
        
        [mDisplayLink invalidate];
        mDisplayLink = nil;

        [[UIApplication sharedApplication] performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
    }
}

@end
