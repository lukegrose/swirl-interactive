//
//  WordListController.h
//  Swirl
//
//  Created by Alex Shaykevich on 22/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@class Ebook;
@interface WordListController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property(nonatomic, retain) IBOutlet UITableView* tableView;
@property(nonatomic, retain) Ebook* ebook;
@property(nonatomic, retain) NSMutableArray* wordLists;
@property(strong, nonatomic) UIAlertView *purchaseRequestAlert;

-(BOOL)isWordListPurchased:(NSString*)name;

@end
