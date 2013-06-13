//
//  WordCell.m
//  Swirl
//
//  Created by Alex Shaykevich on 22/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "WordCell.h"
#import "Word.h"
#import <QuartzCore/QuartzCore.h>

@implementation WordCell
@synthesize meaningView;
@synthesize spellingView;
@synthesize mainLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self != nil) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = YES;
    }
    return self;
}

-(void)setWord:(Word *)word {
    
    
    mainLabel.text = word.word;
    meaningView.image = [word.meaningComplete boolValue] ? [UIImage imageNamed:@"greencheck"] : [UIImage imageNamed:@"redx"];
    spellingView.image = [word.spellingComplete boolValue] ? [UIImage imageNamed:@"greencheck"] : [UIImage imageNamed:@"redx"];
}

- (NSString *) reuseIdentifier {
    return @"wordCell";
}

@end
