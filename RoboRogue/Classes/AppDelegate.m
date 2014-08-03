//
//  AppDelegate.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/14.
//  Copyright 山本政徳 2014年. All rights reserved.
//
// -----------------------------------------------------------------------

#import "AppDelegate.h"
#import "RRGGameScene.h"

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

@implementation AppDelegate

// 
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if DEBUG
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#endif
	// This is the only app delegate method you need to implement when inheriting from CCAppDelegate.
	// This method is a good place to add one time setup code that only runs when your app is first launched.
	
	// Setup Cocos2D with reasonable defaults for everything.
	// There are a number of simple options you can change.
	// If you want more flexibility, you can configure Cocos2D yourself instead of calling setupCocos2dWithOptions:.
	[self setupCocos2dWithOptions:@{
#if DEBUG
		// Show the FPS and draw call label.
		CCSetupShowDebugStats: @(YES),
#endif
		
		// More examples of options you might want to fiddle with:
		// (See CCAppDelegate.h for more information)
		
		// Use a 16 bit color buffer: 
//		CCSetupPixelFormat: kEAGLColorFormatRGB565,
		// Use a simplified coordinate system that is shared across devices.
//		CCSetupScreenMode: CCScreenModeFixed,
		// Run in portrait mode.
//		CCSetupScreenOrientation: CCScreenOrientationPortrait,
		// Run at a reduced framerate.
//		CCSetupAnimationInterval: @(1.0/30.0),
		// Run the fixed timestep extra fast.
//		CCSetupFixedUpdateInterval: @(1.0/180.0),
		// Make iPad's act like they run at a 2x content scale. (iPad retina 4x)
		CCSetupTabletScale2X: @(YES),
        CCSetupDepthFormat: @(GL_DEPTH24_STENCIL8_OES),
	}];
	
	return YES;
}

-(CCScene *)startScene
{
	// This method should return the very first scene to be run when your app starts.
	CCLOG(@"%s", __PRETTY_FUNCTION__);
    
    //preload images
    for (NSInteger i = 1; i <= 4; i++) {
        CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:
         [NSString stringWithFormat:@"sprites%zd.plist", i]];
        
        /*CCTexture* texture = */
        [CCTexture textureWithFile:
         [NSString stringWithFormat:@"sprites%zd.pvr.ccz", i]];
    }
    
    //CCLOG(@"frameCache = %@", frameCache.description);
    //CCLOG(@"textureCache = %@", textureCache.description);
    
    //preload sounds
    
    //preload particle
    
	// This method should return the very first scene to be run when your app starts.
	return sharedGameScene;
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    //[sharedGameScene saveLevel];
    [super applicationDidEnterBackground:application];
}
-(void)applicationWillTerminate:(UIApplication *)application
{
    //[sharedGameScene saveLevel];
    [super applicationWillTerminate:application];
}
@end