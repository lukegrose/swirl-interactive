//
//  WordList.h
//  Swirl
//
//  Created by Alex Shaykevich on 22/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word;

@interface WordList : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * basePath;
@property (nonatomic, retain) NSOrderedSet *words;
@property (nonatomic, retain) NSString * zipOrigin;
@end

@interface WordList (CoreDataGeneratedAccessors)

- (void)insertObject:(Word *)value inWordsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWordsAtIndex:(NSUInteger)idx;
- (void)insertWords:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWordsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWordsAtIndex:(NSUInteger)idx withObject:(Word *)value;
- (void)replaceWordsAtIndexes:(NSIndexSet *)indexes withWords:(NSArray *)values;
- (void)addWordsObject:(Word *)value;
- (void)removeWordsObject:(Word *)value;
- (void)addWords:(NSOrderedSet *)values;
- (void)removeWords:(NSOrderedSet *)values;

-(NSComparisonResult)compare:(WordList*)list;


@end
