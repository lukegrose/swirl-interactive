//
//  Chapter.h
//  Swirl
//
//  Created by Alex Shaykevich on 21/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chapter : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * anchor;

@end
