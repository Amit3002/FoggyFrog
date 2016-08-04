//
//  PHSAppDelegate.h
//  FoggyFrog
//
//  Created by Patel, Amit on 12/30/13.
//  Copyright (c) 2013 Patel, Amit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHSSettingsViewController.h"

@interface PHSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (strong, nonatomic) PHSSettingsViewController *viewController;

@property (strong, nonatomic) UINavigationController* rootNavigationController;
@end
