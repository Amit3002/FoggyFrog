//
//  PHSAboutViewController.m
//  MoneyRain
//
//  Created by Patel, Amit on 10/26/13.
//  Copyright (c) 2013 Patel, Amit. All rights reserved.
//

#import "PHSAboutViewController.h"

const NSInteger kNumberOfLiveApps = 6;
const NSInteger kAppStoreIconHeight = 80;

@interface PHSAboutViewController ()
{
    NSArray* _apps;
}

@end

@implementation PHSAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"LiveApps" ofType:@"plist"];
        _apps = [[NSArray alloc] initWithContentsOfFile:filePath];
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    if (self.navigationController)
        [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfLiveApps;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kAppStoreIconHeight;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AppCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    NSDictionary* dictItem = [_apps objectAtIndex:indexPath.row];
    [cell.textLabel setText:[dictItem valueForKey:@"AppName"]];
    UIImage* img = [UIImage imageNamed:[dictItem valueForKey:@"AppIcon"]];
    [cell.imageView setImage:img];
    
//    [cell.textLabel setText:item];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [aTableView cellForRowAtIndexPath:indexPath];
    if (cell)
    {
        if ([cell.textLabel.text compare:@"Money Rain"] == NSOrderedSame)
        {
            NSString* url = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/money-rain-time-music-love/id769045835?ls=1&mt=8"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        if ([cell.textLabel.text compare:@"Find The Gap"] == NSOrderedSame)
        {
            NSString* url = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/find-the-gap/id689510423?ls=1&mt=8"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        else if ([cell.textLabel.text compare:@"Wasp Wacker"] == NSOrderedSame)
        {
            NSString* url = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/wasp-wacker/id802180392?ls=1&mt=8"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        else if ([cell.textLabel.text compare:@"Wacker Plus"] == NSOrderedSame)
        {
            NSString* url = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/wasp-wacker-plus/id817021884?ls=1&mt=8"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        else if ([cell.textLabel.text compare:@"Pop7"] == NSOrderedSame)
        {
            NSString* url = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/pop-7/id873944744?ls=1&mt=8"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        else if ([cell.textLabel.text compare:@"1000 Suns"] == NSOrderedSame)
        {
            NSString* url = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/1000-suns/id898653279?ls=1&mt=8"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        cell.selected = YES;
    }
}

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.textColor = [UIColor blueColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];

}




@end
