//
//  PHSMyScene.h
//  FoggyFrog
//

//  Copyright (c) 2013 Patel, Amit. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class PHSViewController;

@interface PHSMyScene : SKScene <UIGestureRecognizerDelegate>

@property (strong, nonatomic) PHSViewController* controller;
-(void) cleanup;
-(void) startTimer;
-(void) stopTimer;
@end
