//
//  Word.h
//  Swirl
//
//  Created by Alex Shaykevich on 22/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSString * meaning;
@property (nonatomic, retain) NSString * choice1;
@property (nonatomic, retain) NSString * choice2;
@property (nonatomic, retain) NSString * choice3;
@property (nonatomic, retain) NSNumber * meaningComplete;
@property (nonatomic, retain) NSNumber * spellingComplete;

@property BOOL dirty;

-(BOOL)complete;


@end
