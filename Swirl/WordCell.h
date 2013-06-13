//
//  WordCell.h
//  Swirl
//
//  Created by Alex Shaykevich on 22/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Word;
@interface WordCell : UITableViewCell

@property(nonatomic, retain) IBOutlet UIImageView* meaningView;
@property(nonatomic, retain) IBOutlet UIImageView* spellingView;
@property(nonatomic, retain) IBOutlet UILabel* mainLabel;

@property(nonatomic, retain) Word* word;

@end
