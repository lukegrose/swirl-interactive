//
//  WordTestController.h
//  Swirl
//
//  Created by Alex Shaykevich on 23/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class WordList;
@class Word;
@interface WordTestController : UIViewController

@property(nonatomic, strong) Word* word;
@property(nonatomic, strong) WordList* wList;
@property(nonatomic, strong) IBOutlet UILabel* wordLabel;
@property(nonatomic, strong) IBOutlet UITextView* meaningTF;
@property(nonatomic, retain) IBOutlet UIButton* meaningButton;
@property(nonatomic, retain) IBOutlet UIButton* spellingButton;
@property(nonatomic, retain) IBOutlet UILabel* meaningLabel;
@property(nonatomic, retain) IBOutlet UILabel* spellingLabel;


-(IBAction)meaningAction;
-(IBAction)spellingAction;
-(IBAction)playAction;

@end
