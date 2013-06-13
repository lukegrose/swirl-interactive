//
//  Ebook.m
//  Swirl
//
//  Created by Alex Shaykevich on 21/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "Ebook.h"
#import "Chapter.h"


@implementation Ebook

@dynamic title;
@dynamic author;
@dynamic basePath;
@dynamic thumbnailPath;
@dynamic chapters;
@dynamic epubName;

-(UIImage*)getThumbnailImage {
    if(self.thumbnailPath == nil) {
        return nil;
    }
    
    NSString* path = [self.basePath stringByAppendingPathComponent:self.thumbnailPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        return nil;
    }
    
    return [UIImage imageWithContentsOfFile:path];
}

-(NSComparisonResult)compare:(Ebook*)book {
    return [self.title caseInsensitiveCompare:book.title];
}

@end
