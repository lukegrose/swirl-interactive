//
//  SwirlProduct.m
//  Swirl
//
//  Created by Luke Grose on 10/05/13.
//  Copyright (c) 2013 Alex Shaykevich. All rights reserved.
//

#import "SwirlProduct.h"

@interface SwirlProduct ()
//- (id)initWithProductName:(NSString *)productName productId:(NSString *)productId available:(BOOL)available;
@end

@implementation SwirlProduct

-(id)initWithProductName:(NSString*)productName productId:(NSString*)productId available:(BOOL)available {
    
    self = [super self];
    
    if(self) {
        
        self.productName = productName;
        self.productId = productId;
        self.available = available;
        
    }
    
    return self;
    
}

@end
