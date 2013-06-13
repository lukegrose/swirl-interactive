//
//  MeaningTestController.h
//  Swirl
//
//  Created by Alex Shaykevich on 23/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Word;
@interface MeaningTestController : UIViewController


@property(nonatomic, strong) Word* word;
@property(nonatomic, strong) IBOutlet UIView* retryView;
@property(nonatomic, strong) IBOutlet UILabel* wordLabel;

-(IBAction)backAction;

@end
