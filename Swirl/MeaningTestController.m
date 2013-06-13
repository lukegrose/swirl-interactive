//
//  MeaningTestController.m
//  Swirl
//
//  Created by Alex Shaykevich on 23/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "MeaningTestController.h"
#import "Word.h"
#import <AVFoundation/AVFoundation.h>
#import "Flurry.h"

@interface MeaningTestController ()
- (void)shuffle:(NSMutableArray*)arr;

@property(nonatomic, strong) AVAudioPlayer* bellPlayer;
@property(nonatomic, strong) AVAudioPlayer* wrongPlayer;
@property(nonatomic, strong) NSMutableArray* data;
@end

@implementation MeaningTestController
@synthesize word;
@synthesize bellPlayer;
@synthesize data;
@synthesize retryView;
@synthesize wordLabel;
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
    
    if(error) {
        NSLog(@"%@", [error description]);
    }
    
    self.data = [NSMutableArray array];
    [data addObject:word.meaning];
    [data addObject:word.choice1];
    [data addObject:word.choice2];
    [data addObject:word.choice3];
    // randomize
    [self shuffle:data];

    // assign to labels
    for(int i=0; i< [data count]; i++) {
        UILabel* l = (UILabel*)[self.view viewWithTag:i+1];
        l.text = [data objectAtIndex:i];
    }
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionRight;
    //swipeLeft.delegate = self;
    [self.view addGestureRecognizer:swipeLeft];
    
    wordLabel.text = word.word;
    
    // apply font
    UIFont* font = [UIFont fontWithName:@"Bella K. Mad Font" size:16];
    for(UIView* v in [self.view subviews]) {
        if(v == wordLabel) {
            continue;
        }
        if([v isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)v;
            label.font = font;
        } else if([v isKindOfClass:[UIButton class]]) {
            UIButton* b = (UIButton*)v;
            //b.titleLabel.font = font;
        }
    }
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [Flurry logEvent:@"ENTER_MEANING_ACTIVITY"];
    
}

-(void)swipeLeftAction {
    [self backAction];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shuffle:(NSMutableArray*)arr
{
    NSUInteger count = [arr count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [arr exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}


-(IBAction)backAction {
 
    //This will only work before any attempt is made to answer the question
    BOOL complete = NO;
    
    for (int i=1; i<=4; i++) {
        
        UIButton* b = (UIButton*)[self.view viewWithTag:i+10];
        
        if ( b.imageView.image != nil ) {
            
            complete = YES;
            break;
             
        }
    }
    
    if ( ! complete ) {
        
        [Flurry logEvent:@"MEANING_ACTIVITY_INCOMPLETE"];
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setButtonEnabledState:(BOOL)enabled {
    for(UIView* v in [self.view subviews]) {
        if([v isKindOfClass:[UIButton class]] && v.tag != 0) {
            UIButton* b = (UIButton*)v;
            b.enabled = enabled;
        }
    }
}

-(IBAction)buttonAction:(UIButton*)b {
    
    int tag = b.tag;
    int index = tag - 1 - 10;

    [b setTitle:nil forState:UIControlStateNormal];
    
    NSString* item = [self.data objectAtIndex:index];
    if([item isEqualToString:word.meaning]) {
        [Flurry logEvent:@"MEANING_ACTIVITY_RIGHT"];
        [bellPlayer play];
        [b setImage:[UIImage imageNamed:@"greencheck"] forState:UIControlStateNormal];
        
        word.meaningComplete = [NSNumber numberWithBool:YES];
        
        for(int i=11; i<=14; i++) {
            UIButton* button = (UIButton*)[self.view viewWithTag:i];
            button.enabled = NO;
        }
    } else {
        // mark with red x
        [b setImage:[UIImage imageNamed:@"redx"] forState:UIControlStateNormal];
        word.meaningComplete = [NSNumber numberWithBool:NO];
        
        retryView.hidden = NO;
        [Flurry logEvent:@"MEANING_ACTIVITY_WRONG"];
        [self.wrongPlayer play];
        [self setButtonEnabledState:NO];
    }
}

-(void)resetButtonTitles {
    
    for(int i=1; i<=4; i++) {
    
        UIButton* b = (UIButton*)[self.view viewWithTag:i+10];
        b.imageView.image = nil;
        [b setImage:nil forState:UIControlStateNormal];
        [b setTitle:[NSString stringWithFormat:@"%i", i] forState:UIControlStateNormal];
        
    }
}

-(IBAction)retryAction {
    [self resetButtonTitles];
    retryView.hidden = YES;
    [self setButtonEnabledState:YES];
}

@end
