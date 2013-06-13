//
//  WordList.m
//  Swirl
//
//  Created by Alex Shaykevich on 22/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "WordList.h"
#import "Word.h"


@implementation WordList

@dynamic title;
@dynamic basePath;
@dynamic words;
@dynamic zipOrigin;

-(NSComparisonResult)compare:(WordList*)list {
    return [self.title caseInsensitiveCompare:list.title];
}

@end
