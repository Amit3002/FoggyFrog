//
//  PHSViewController.h
//  FoggyFrog
//

//  Copyright (c) 2013 Patel, Amit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@class PHSGameDataModel;
@class PHSMyScene;

@interface PHSViewController : UIViewController <UINavigationControllerDelegate>

@property (nonatomic, strong) PHSGameDataModel* dataModel;
@property (nonatomic, strong) PHSMyScene * scene;
@end
