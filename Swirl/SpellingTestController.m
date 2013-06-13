//
//  SpellingTestController.m
//  Swirl
//
//  Created by Alex Shaykevich on 24/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "SpellingTestController.h"
#import "Word.h"
#import "Flurry.h"
@interface SpellingTestController ()
@property(nonatomic, strong) AVAudioPlayer* bellPlayer;
@property(nonatomic, strong) AVAudioPlayer* wrongPlayer;
@end

@implementation SpellingTestController
@synthesize word;
@synthesize player;
@synthesize retryView;
@synthesize bellPlayer;
@synthesize wrongPlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // load the player
    NSString* path = [[NSBundle mainBundle] pathForResource:@"onbell" ofType:@"mp3"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSError* error;
    self.bellPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self.bellPlayer prepareToPlay];
    
    path = [[NSBundle mainBundle] pathForResource:@"menu_wrong_1" ofType:@"mp3"];
    url = [NSURL fileURLWithPath:path];
    self.wrongPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self.wrongPlayer prepareToPlay];
    

    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap)];
    //[self.view addGestureRecognizer:singleFingerTap];
    
    self.textField.placeholder = @"Type Here";
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionRight;
    //swipeLeft.delegate = self;
    [self.view addGestureRecognizer:swipeLeft];
    
    self.textField.layer.borderWidth = 5.0f;
    self.textField.layer.borderColor = [[UIColor grayColor] CGColor];
    
    UILabel* label = (UILabel*)[self.view viewWithTag:21];
    label.font = [UIFont fontWithName:@"Bella K. Mad Font" size:21];
    label = (UILabel*)[self.view viewWithTag:22];
    label.font = [UIFont fontWithName:@"Bella K. Mad Font" size:21];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [Flurry logEvent:@"ENTER_SPELLING_ACTIVITY"];
    
}

-(void)swipeLeftAction {
    [self backAction];
}

-(IBAction)handleSingleTap {
    [self.textField resignFirstResponder];
    [self.view becomeFirstResponder];
    
    [self checkSpelling];
//    NSString* text = [self.textField.text lowercaseString];
//    if(self.textField.userInteractionEnabled && text != nil && [text isEqualToString:@""] == NO) {
//        self.textField.userInteractionEnabled = NO;
//
//        // test it
//        if([text isEqualToString:[word.word lowercaseString]]) {
//            [bellPlayer play];
//            word.spellingComplete = [NSNumber numberWithBool:YES];
//        } else {
//            self.retryView.hidden = NO;
//            word.spellingComplete = [NSNumber numberWithBool:NO];
//            [self.wrongPlayer play];
//        }
//    }
}

- (void)checkSpelling {
    NSString* text = [self.textField.text lowercaseString];
    if(self.textField.userInteractionEnabled && text != nil && [text isEqualToString:@""] == NO) {
        self.textField.userInteractionEnabled = NO;
        
        // test it
        if([text isEqualToString:[word.word lowercaseString]]) {
            [Flurry logEvent:@"SPELLING_ACTIVITY_RIGHT"];
            [bellPlayer play];
            word.spellingComplete = [NSNumber numberWithBool:YES];
        } else {
            self.retryView.hidden = NO;
            word.spellingComplete = [NSNumber numberWithBool:NO];
            [Flurry logEvent:@"SPELLING_ACTIVITY_WRONG"];
            [self.wrongPlayer play];
        }
    } else {
        
        [Flurry logEvent:@"SPELLING_ACTIVITY_INCOMPLETE"];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backAction {
    
    [self checkSpelling];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)retryAction {
    self.retryView.hidden = YES;
    self.textField.text = nil;
    self.textField.placeholder = @"Type Here";
    self.textField.userInteractionEnabled = YES;

    [self.textField becomeFirstResponder];
}

-(IBAction)playAction {
    [Flurry logEvent:@"LISTEN_SPELLING_ACTIVITY"];
    [player play];
}

- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
    [self checkSpelling];
}

@end
