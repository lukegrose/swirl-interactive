//
//  Word.m
//  Swirl
//
//  Created by Alex Shaykevich on 22/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "Word.h"


@implementation Word

@dynamic word;
@dynamic meaning;
@dynamic choice1;
@dynamic choice2;
@dynamic choice3;
@synthesize meaningComplete;
@synthesize spellingComplete;

@synthesize dirty;

-(BOOL)complete {
    return [self.meaningComplete boolValue] && [self.spellingComplete boolValue];
}

-(void)setMeaningComplete:(NSNumber *)mc {
    
    if([self.meaningComplete boolValue] != [mc boolValue]) {
        meaningComplete = mc;
        dirty = YES;

        [self willChangeValueForKey:@"meaningComplete"];
        [self setPrimitiveValue:meaningComplete forKey:@"meaningComplete"];
        [self didChangeValueForKey:@"meaningComplete"];
    }
}

-(void)setSpellingComplete:(NSNumber *)sp {
    if([self.spellingComplete boolValue] != [sp boolValue]) {
        spellingComplete = sp;
        dirty = YES;

        [self willChangeValueForKey:@"meaningComplete"];
        [self setPrimitiveValue:meaningComplete forKey:@"meaningComplete"];
        [self didChangeValueForKey:@"meaningComplete"];
    }
}

@end
