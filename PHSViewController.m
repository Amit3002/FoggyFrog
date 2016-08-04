//
//  PHSViewController.m
//  FoggyFrog
//
//  Created by Patel, Amit on 12/30/13.
//  Copyright (c) 2013 Patel, Amit. All rights reserved.
//

#import "PHSViewController.h"
#import "PHSMyScene.h"
#import "PHSGameDataModel.h"
#import "PHSSettingsViewController.h"


@interface PHSViewController()
{
    BOOL levelCleared;
}
-(void) resetCounters;
@end

@implementation PHSViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.dataModel = [[PHSGameDataModel alloc] init];
        NSUserDefaults* storedLevelValue = [NSUserDefaults standardUserDefaults];
        NSInteger intValue = [storedLevelValue integerForKey:kLevelKey];
        if (intValue > 0)
        {
            NSNumber* lvl = [[NSNumber alloc] initWithInteger:intValue];
            [self.dataModel setGameLevel:(lvl)];
        }
        else
        {
            self.dataModel.gameLevel = [[NSNumber alloc] initWithInteger:1];
        }
        self.dataModel.killCount = [[NSNumber alloc] initWithInteger:0];
        levelCleared = NO;
    }
    return self;
    
}

- (void) dealloc
{
    [self removeObserver:self forKeyPath:@"dataModel.gameLevel" context:NULL];
    [self removeObserver:self forKeyPath:@"dataModel.killCount" context: NULL];
    [self removeObserver:self forKeyPath:@"dataModel.timesUpCount" context:NULL];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addObserver:self forKeyPath:@"dataModel.gameLevel" options:/*NSKeyValueObservingOptionInitial |*/ NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"dataModel.killCount" options:/*NSKeyValueObservingOptionInitial |*/ NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"dataModel.timesUpCount" options:NSKeyValueObservingOptionNew context:NULL];
    
    // Configure the view.
    CGRect mainRect = [[UIScreen mainScreen] bounds];
//    CGRect frame = CGRectMake(0.0f, 0.0f, 320.0f, 528.0f);
    SKView * skView = [[SKView alloc] initWithFrame:mainRect];

    skView.showsFPS = NO;
    skView.showsNodeCount = NO;

    self.view = skView;
    // Create and configure the scene.
    self.scene = [PHSMyScene sceneWithSize:skView.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.scene.controller = self;
    
    // Present the scene.
    [skView presentScene:self.scene];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    levelCleared = NO;
    [self.scene startTimer];
}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.scene stopTimer];
    NSNumber* isLevelFailed = nil;
    if (levelCleared == YES)
    {
        if (self.navigationController != nil)
        {
            [self resetCounters];
            NSInteger currentGamelevel = [self.dataModel.gameLevel integerValue] + 1;
            [self.dataModel setValue:[NSNumber numberWithInteger:currentGamelevel] forKey:@"gameLevel"];
            isLevelFailed = [NSNumber numberWithBool:NO];

        }
    }
    else
    {
        [self resetCounters];
        isLevelFailed = [NSNumber numberWithBool:YES];
    }
    NSNumber* newGameLevel = [NSNumber numberWithInteger:[self.dataModel.gameLevel integerValue]];
    [self.dataModel setValue:newGameLevel forKey:@"gameLevel"];
    UINavigationController* navigationController = self.navigationController;
    NSArray * controllers = [navigationController viewControllers];
    for (UIViewController *topController in controllers) {
        if ([topController isKindOfClass:[PHSSettingsViewController class]]) {
            [topController setValue:newGameLevel forKey:@"level"];
            [topController setValue:isLevelFailed forKey:@"isLevelFailed"];
            break;
        }
    }
}

-(void) resetCounters
{
    [self.scene cleanup];
    // reset the killcount
    NSNumber* eatenDragonFlys = [NSNumber numberWithInteger:0];
    NSNumber* timesUpCount = [NSNumber numberWithInteger:0];
    [self.dataModel setValue:eatenDragonFlys forKey:@"killCount"];
    [self.dataModel setValue:timesUpCount forKey:@"timesUpCount"];
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"dataModel.gameLevel"])
    {
        id pNew = [change objectForKey:NSKeyValueChangeKindKey];
        if ([pNew isKindOfClass:[NSNumber class]])
        {
            ;

        }
    }
    if ([keyPath isEqualToString:@"dataModel.timesUpCount"])
    {
        id pNew = [change objectForKey:NSKeyValueChangeKindKey];
        if ([pNew isKindOfClass:[NSNumber class]])
        {
            NSNumber* timesUpCount = [change objectForKey:NSKeyValueChangeNewKey];
            
            NSInteger timesUp = [timesUpCount integerValue];
            if (timesUp > 0)
            {
                // level cleared
                levelCleared = NO;
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        
    }
    if ([keyPath isEqualToString:@"dataModel.killCount"])
    {
        id pNew = [change objectForKey:NSKeyValueChangeKindKey];
        if ([pNew isKindOfClass:[NSNumber class]])
        {
            NSNumber* killCount = [change objectForKey:NSKeyValueChangeNewKey];
            
            NSInteger eatenDragonFlysCount = [killCount integerValue];
            NSLog(@"kill count is %ld", (long)eatenDragonFlysCount);
            NSInteger levelTest = ([self.dataModel.gameLevel integerValue]/2);
            if (levelTest < 0)
                levelTest = 1;
            if (eatenDragonFlysCount >= levelTest)
            {
                // level cleared
                levelCleared = YES;
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

@end
