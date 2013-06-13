//
//  SwirlProduct.h
//  Swirl
//
//  Created by Luke Grose on 10/05/13.
//  Copyright (c) 2013 Alex Shaykevich. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kProductIdentifierDolchPrePrimer @"com.interactive.Swirl.dolchPrePrimer"
#define kProductIdentifierDolchPrimer @"com.interactive.Swirl.dolchPrimer"
#define kProductIdentifierDolchGrade1 @"com.interactive.Swirl.dolchgrade1"
#define kProductIdentifierDolchGrade2 @"com.interactive.Swirl.dolchgrade2"
#define kProductIdentifierDolchGrade3 @"com.interactive.Swirl.dolchgrade3"
#define kProductIdentifierDolchNouns @"com.interactive.Swirl.dolchnouns"
#define kProductIdentifierFrequentlyRequested01 @"com.interactive.Swirl.frequentlyrequested01"
#define kProductIdentifierFrequentlyRequested02 @"com.interactive.Swirl.frequentlyrequested02"
#define kProductIdentifierThemedFood01 @"com.interactive.Swirl.themedfood01"
#define kProductIdentifierThemedHalloween01 @"com.interactive.Swirl.themedhalloween01"

@interface SwirlProduct : NSObject

@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *productId;
@property (nonatomic) BOOL available;

- (id)initWithProductName:(NSString *)productName productId:(NSString *)productId available:(BOOL)available;

@end


