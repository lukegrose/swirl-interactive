//
//  WordTestController.m
//  Swirl
//
//  Created by Alex Shaykevich on 23/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "WordTestController.h"
#import "AppDelegate.h"
#import "WordList.h"
#import "Word.h"
#import "MeaningTestController.h"
#import "SpellingTestController.h"
#import "Flurry.h"

@interface WordTestController ()

@property(nonatomic, strong) AVAudioPlayer* player;
@end

@implementation WordTestController
@synthesize word;
@synthesize wList;
@synthesize meaningButton, spellingButton;
@synthesize wordLabel, meaningTF;
@synthesize player;
@synthesize meaningLabel;
@synthesize spellingLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    NSDictionary *eventParams =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"Wordlist", word.word,
     nil];
    
    [Flurry logEvent:@"ENTER_ACTIVITY_MENU" withParameters:eventParams];
    
    // apply the correct state to the buttons
    UIImage* meaningImage = [word.meaningComplete boolValue] ? [UIImage imageNamed:@"greencheck"] : [UIImage imageNamed:@"redx"];
    UIImage* spellingImage = [word.spellingComplete boolValue] ? [UIImage imageNamed:@"greencheck"] : [UIImage imageNamed:@"redx"];
    
    [meaningButton setImage:meaningImage forState:UIControlStateNormal];
    [spellingButton setImage:spellingImage forState:UIControlStateNormal];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spellingLabelTap)];
    [tapGesture setNumberOfTapsRequired:1];
    spellingLabel.userInteractionEnabled = YES;
    spellingLabel.gestureRecognizers = [NSArray arrayWithObject:tapGesture];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(meaningLabelTap)];
    [tapGesture setNumberOfTapsRequired:1];
    meaningLabel.userInteractionEnabled = YES;
    meaningLabel.gestureRecognizers = [NSArray arrayWithObject:tapGesture];
}

-(void)spellingLabelTap {
    [self spellingAction];
}

-(void)meaningLabelTap {
    [self meaningAction];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // load the player
    NSString* dir = [[AppDelegate getWordlistDirPath] stringByAppendingPathComponent:wList.basePath];
    NSString* path = [AppDelegate getAudioPathForWord:word.word dir:dir];
    if(path != nil) {
        NSURL* url = [NSURL fileURLWithPath:path];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [self.player prepareToPlay];
    }
    wordLabel.textColor = [UIColor blueColor];
    wordLabel.text = word.word;
    meaningTF.text = word.meaning;
    
    meaningTF.layer.borderWidth = 5.0f;
    meaningTF.layer.borderColor = [[UIColor grayColor] CGColor];
    
    UILabel* label = (UILabel*)[self.view viewWithTag:21];
    //label.font = [UIFont fontWithName:@"Bella K. Mad Font" size:21];
    label = (UILabel*)[self.view viewWithTag:22];
    label.font = [UIFont fontWithName:@"Bella K. Mad Font" size:21];
    label = (UILabel*)[self.view viewWithTag:23];
    label.font = [UIFont fontWithName:@"Bella K. Mad Font" size:21];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)meaningAction {
    MeaningTestController* mtc = [[MeaningTestController alloc] initWithNibName:nil bundle:nil];
    mtc.word = word;
    [self.navigationController pushViewController:mtc animated:YES];
}

-(IBAction)spellingAction {
    SpellingTestController* stc = [[SpellingTestController alloc] initWithNibName:nil bundle:nil];
    stc.word = word;
    stc.player = player;
    [self.navigationController pushViewController:stc animated:YES];
}

-(IBAction)playAction {
    [Flurry logEvent:@"LISTEN_ACTIVITY_MENU"];
    [player play];
}

@end
