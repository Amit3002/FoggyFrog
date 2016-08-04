//
//  PHSGameDataModel.h
//  FoggyFrog
//
//  Created by Patel, Amit on 1/4/14.
//  Copyright (c) 2014 Patel, Amit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHSGameDataModel : NSObject

@property (readwrite, strong) NSNumber* gameLevel;
@property (readwrite, strong) NSNumber* killCount;
@property (readwrite,strong) NSNumber* timesUpCount;

@end
