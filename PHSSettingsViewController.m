//
//  PHSSettingsViewController.m
//  FoggyFrog
//
//  Created by Patel, Amit on 9/21/13.
//  Copyright (c) 2013 Patel, Amit. All rights reserved.
//

#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "PHSSettingsViewController.h"
#import "PHSViewController.h"
#import "PHSAboutViewController.h"


static NSString* const kAppUrl = @"https://itunes.apple.com/us/app/foggy-frog/id817195884?ls=1&mt=8";

NSString* const kLevelKey = @"levelValue";
static const NSUInteger kPointsPerLevel = 50;
static const short kLevelNeededToShowRateThisAlert = 5;
@interface PHSSettingsViewController ()
{
    PHSViewController* gameController;
    PHSAboutViewController* aboutViewController;
    BOOL hasPlayedOnce;
    NSUInteger pointsScored;
}

-(void) rotateImageView:(UIImageView*)img withDuration:(CFTimeInterval)interval withRotationSpeed:(float)speed doesAutoReverse:(BOOL)reverse;
-(void) showImagesAndAnimate;
-(void) setUpAudioBackgroundMusic;

@end

@implementation PHSSettingsViewController

@synthesize player;


-(void) setUpAudioBackgroundMusic
{
    return;
    
    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource: @"backgroundmusic"
                                    ofType: @"m4a"];
    
    if (soundFilePath != nil)
    {
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    
        AVAudioPlayer *newPlayer =
        [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                           error: nil];
    
        self.player = newPlayer;
    
        self.player.numberOfLoops = -1;
        [player prepareToPlay];
        [player setDelegate: self];
        [player setVolume:0.3f];
        [player play];
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        self.isLevelFailed = [[NSNumber alloc] initWithBool:NO];
        NSUserDefaults* storedLevelValue = [NSUserDefaults standardUserDefaults];
        NSInteger intValue = [storedLevelValue integerForKey:kLevelKey];
        if (intValue > 0)
        {
            NSNumber* lvl = [[NSNumber alloc] initWithInteger:intValue];
            [self setLevel:(lvl)];
        }
        else
        {
            self.level = [[NSNumber alloc] initWithInteger:1];
        }
        pointsScored = 0;
        hasPlayedOnce = NO;
        self.levelLabel.text = [[NSString alloc] initWithFormat:@"Level %ld", (long)[self.level integerValue]];
        self.pointsLabel.text = [[NSString alloc] initWithFormat:@"%lu points", (unsigned long)pointsScored];
        self.levelLabel.hidden = YES;
        self.pointsLabel.hidden = YES;
        if ([self respondsToSelector:@selector(setCanDisplayBannerAds:)])
            self.canDisplayBannerAds = YES;
    }
    return self;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}
- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

-(void) showImagesAndAnimate
{

    CFTimeInterval animateDuration = 0.5;
    [self rotateImageView:self.frogView withDuration:animateDuration withRotationSpeed:2.5 * 4.15 doesAutoReverse:NO];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpAudioBackgroundMusic];


    // Do any additional setup after loading the view from its nib.
    gameController = [[PHSViewController alloc] initWithNibName:nil bundle:nil];
    aboutViewController = [[PHSAboutViewController alloc] initWithNibName:@"PHSAboutViewController" bundle:nil];

    self.frogView.hidden = NO;
    [self showImagesAndAnimate];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [player play];
    if (hasPlayedOnce == NO) {
        return;
    }
    NSInteger gameLevel = [self.level integerValue];
    if ([self.isLevelFailed boolValue] == NO)
    {
        self.levelLabel.textColor = [UIColor greenColor];
        self.levelLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
        self.levelLabel.text = [[NSString alloc] initWithFormat:@"Level %ld cleared!", (long)gameLevel-1];
        self.levelLabel.hidden = NO;
        self.pointsLabel.textColor = [UIColor greenColor];
        self.pointsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
        self.pointsLabel.hidden = NO;
        NSUInteger currentScore = pointsScored;
        pointsScored = (gameLevel * kPointsPerLevel) + currentScore;
        self.pointsLabel.text = [[NSString alloc] initWithFormat:@"You have %lu points!", (unsigned long)pointsScored];
        [self showImagesAndAnimate];
        [self.playButton setTitle:@"Play Again!" forState:UIControlStateNormal];
        if (gameLevel == kLevelNeededToShowRateThisAlert)
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Rate Foggy Frog" message:@"Croak and roll!  Please take a moment and rate Foggy Frog." delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Rate Now", nil];
            [alert show];
        }
    }
    else
    {
        BOOL isLevelReallyFailed = [self.isLevelFailed boolValue];
        if (isLevelReallyFailed == YES)
        {
            self.levelLabel.hidden = NO;
            self.levelLabel.textColor = [UIColor redColor];
            self.levelLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
            self.levelLabel.text = [[NSString alloc] initWithFormat:@"Level %ld failed!", (long)gameLevel];
            [self showImagesAndAnimate];
        }
    }
    NSUserDefaults* storedLevelValue = [NSUserDefaults standardUserDefaults];
    [storedLevelValue setInteger:gameLevel forKey:kLevelKey];
    
}

-(void) rotateImageView:(UIImageView*)img withDuration:(CFTimeInterval)interval withRotationSpeed:(float)speed doesAutoReverse:(BOOL)reverse
{
    img.hidden = NO;
    [UIView animateWithDuration:interval animations:^{
        CABasicAnimation* theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        theAnimation.duration = interval;
        theAnimation.autoreverses = reverse;
        theAnimation.removedOnCompletion = YES;
        theAnimation.fromValue = [NSNumber numberWithFloat: 0];
        theAnimation.toValue = [NSNumber numberWithFloat: speed/*3.5 * 3.15*/ ];
        [img.layer addAnimation: theAnimation forKey: @"rotation"];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)help:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"How to Play" message:@"Help Foggy Frog catch dragon flies!  Single tap to move Foggy Frog!  Double tap to catch dragon flies!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (IBAction)post:(id)sender {
    SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    SLComposeViewControllerCompletionHandler completionBlock = ^(SLComposeViewControllerResult result){
        
        NSLog(@"Done");
    };
    NSString* text = [NSString stringWithFormat:@"I scored %lu points on Foggy Frog.  Croak and roll!",(unsigned long)pointsScored ];
    NSString* url = kAppUrl;
    UIImage *image = [UIImage imageNamed:@"app_icon120.png"];
    
    [vc setCompletionHandler:completionBlock];
    [vc setInitialText:text];
    [vc addURL:[NSURL URLWithString:url]];
    [vc addImage:image];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)rate:(id)sender {

    NSString* url = [NSString stringWithFormat:kAppUrl];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (IBAction)about:(id)sender {
    if (self.navigationController != nil)
    {
        [self.navigationController pushViewController:aboutViewController animated:YES];
    }
}

- (IBAction)play:(id)sender {
    if (self.navigationController != nil)
    {
        [self.navigationController pushViewController:gameController animated:YES];
        hasPlayedOnce = YES;
        self.levelLabel.text = @"";
        self.pointsLabel.text = @"";

    }
}


- (IBAction)share:(id)sender {
     BOOL canSendText = [MFMessageComposeViewController canSendText];
    if (canSendText == YES)
    {
        MFMessageComposeViewController * smsViewController = [[MFMessageComposeViewController alloc] init];
        smsViewController.messageComposeDelegate = self;
        [smsViewController setBody:@"Check out https://itunes.apple.com/us/app/foggy-frog/id817195884?ls=1&mt=8 Croak and roll!"];
        smsViewController.recipients = nil;
        [self presentViewController:smsViewController animated:NO completion:^(void){}];
        smsViewController = nil;
        
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
	UITouch *theTouch = [touches anyObject] ;
	CGPoint touchLocation = [theTouch locationInView: self.frogView];
    if ([self.frogView pointInside:touchLocation withEvent:event] == YES)
    {
        [self play:self];
    }

}




#pragma mark implementation of protocol MFMessageComposeViewControllerDelegate
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{

    if([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}





/* Banner View Delegate */

// This method is invoked when the banner has confirmation that an ad will be presented, but before the ad
// has loaded resources necessary for presentation.
- (void)bannerViewWillLoadAd:(ADBannerView *)banner __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_5_0)
{
    return;
}

// This method is invoked each time a banner loads a new advertisement. Once a banner has loaded an ad,
// it will display that ad until another ad is available. The delegate might implement this method if
// it wished to defer placing the banner in a view hierarchy until the banner has content to display.
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
    // Assumes the banner view is just off the bottom of the screen.
    banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
    [UIView commitAnimations];
}

// This method will be invoked when an error has occurred attempting to get advertisement content.
// The ADError enum lists the possible error codes.
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
    // Assumes the banner view is placed at the bottom of the screen.
    banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
    [UIView commitAnimations];
}

// This message will be sent when the user taps on the banner and some action is to be taken.
// Actions either display full screen content in a modal session or take the user to a different
// application. The delegate may return NO to block the action from taking place, but this
// should be avoided if possible because most advertisements pay significantly more when
// the action takes place and, over the longer term, repeatedly blocking actions will
// decrease the ad inventory available to the application. Applications may wish to pause video,
// audio, or other animated content while the advertisement's action executes.
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    if (player != nil)
    {
        if (YES == [player isPlaying])
            [player pause];
    }
    return YES;
}

// This message is sent when a modal action has completed and control is returned to the application.
// Games, media playback, and other activities that were paused in response to the beginning
// of the action should resume at this point.
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    if (player != nil)
        [player play];
    return;
}


/* Audio Delegate */

/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    return;
    
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    return;
}



/* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    return;
}

/* audioPlayerEndInterruption:withOptions: is called when the audio session interruption has ended and this player had been interrupted while playing. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags NS_AVAILABLE_IOS(6_0)
{
    return;
    
}

/*** UIAlertViewDelegate ****/
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        return;
    if (buttonIndex == 1)
        [self rate:nil];
}

@end
