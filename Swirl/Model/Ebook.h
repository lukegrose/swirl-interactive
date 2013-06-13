//
//  Ebook.h
//  Swirl
//
//  Created by Alex Shaykevich on 21/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Chapter;

@interface Ebook : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * basePath;
@property (nonatomic, retain) NSString * thumbnailPath;
@property (nonatomic, retain) NSOrderedSet *chapters;
@property (nonatomic, retain) NSString * epubName;
@end

@interface Ebook (CoreDataGeneratedAccessors)

- (void)insertObject:(Chapter *)value inChaptersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChaptersAtIndex:(NSUInteger)idx;
- (void)insertChapters:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChaptersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChaptersAtIndex:(NSUInteger)idx withObject:(Chapter *)value;
- (void)replaceChaptersAtIndexes:(NSIndexSet *)indexes withChapters:(NSArray *)values;
- (void)addChaptersObject:(Chapter *)value;
- (void)removeChaptersObject:(Chapter *)value;
- (void)addChapters:(NSOrderedSet *)values;
- (void)removeChapters:(NSOrderedSet *)values;


-(UIImage*)getThumbnailImage;
-(NSComparisonResult)compare:(Ebook*)book;

@end
