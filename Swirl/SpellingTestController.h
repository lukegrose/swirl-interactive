//
//  SpellingTestController.h
//  Swirl
//
//  Created by Alex Shaykevich on 24/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class Word;

@interface SpellingTestController : UIViewController

@property(nonatomic, retain) IBOutlet UITextField* textField;
@property(nonatomic, retain) Word* word;
@property(nonatomic, retain) AVAudioPlayer* player;
@property(nonatomic, strong) IBOutlet UIView* retryView;


-(IBAction)backAction;
-(IBAction)retryAction;

-(IBAction)textFieldDoneEditing:(id)sender;


@end
