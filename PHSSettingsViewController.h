//
//  PHSSettingsViewController.h
//  FoggyFrog
//
//  Created by Patel, Amit on 9/21/13.
//  Copyright (c) 2013 Patel, Amit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <iAd/iAd.h>
#import <AVFoundation/AVFoundation.h>


extern NSString* const kLevelKey;

@interface PHSSettingsViewController : UIViewController <UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate, ADBannerViewDelegate, AVAudioPlayerDelegate, UIAlertViewDelegate>

@property (readwrite, nonatomic) NSNumber* level;
@property (readwrite, nonatomic) NSNumber* isLevelFailed;

@property (weak, nonatomic) IBOutlet UIImageView *frogView;

@property (weak, nonatomic) IBOutlet UIButton *playButton;




- (IBAction)help:(id)sender;

- (IBAction)post:(id)sender;

- (IBAction)rate:(id)sender;

- (IBAction)about:(id)sender;

- (IBAction)play:(id)sender;

- (IBAction)share:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@property (strong, nonatomic) AVAudioPlayer* player;

@end
