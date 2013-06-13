//
//  WordTestParentController.h
//  Swirl
//
//  Created by Alex Shaykevich on 23/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WordList;
@class Word;

@interface WordTestParentController : UINavigationController

@property(nonatomic, strong) Word* word;
@property(nonatomic, strong) WordList* wList;

@end
