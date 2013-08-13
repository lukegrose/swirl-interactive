//
//  WordListController.m
//  Swirl
//
//  Created by Alex Shaykevich on 22/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "WordListController.h"
#import "WordList.h"
#import "Ebook.h"
#import "AppDelegate.h"
#import "WordListDetailController.h"
#import "EpubChapterController.h"
#import "Flurry.h"
//#import "SFHFKeychainUtils.h"
#import "SwirlProduct.h"

@interface WordListController ()

-(void)setCellDisabled;
-(void)displayInAppPurchase;
@property(nonatomic, strong) NSArray *freeProducts;
@property(nonatomic, strong) NSArray *allProducts;
@property(nonatomic, strong) NSMutableDictionary *products;
@property SwirlProduct *currentlySelectedSwirlProduct;

@end

@implementation WordListController
@synthesize tableView;
@synthesize ebook;
@synthesize wordLists;

#define kStoredData @"com.interactive.Swirl"

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {

        [self populateProducts];
        
    }
    
    return self;
}

-(void)populateProducts {
    
    //lgrose, this is a temporary measure and will need to be replaced by some actual persistence
    self.products = [[NSMutableDictionary alloc] init];
    
    //Dolch Pre Primer
    SwirlProduct *preprimer = [[SwirlProduct alloc] initWithProductName:@"Dolch Pre Primer"
                                                              productId: kProductIdentifierDolchPrePrimer
                                                              available: YES];
    
    [self.products setValue:preprimer forKey:preprimer.productName];
    
    //Dolch Primer
    SwirlProduct *primer = [[SwirlProduct alloc] initWithProductName:@"Dolch Primer"
                                                           productId: kProductIdentifierDolchPrimer
                                                           available: YES];
    
    [self.products setValue:primer forKey:primer.productName];
    
    //Dolch Grade 1
    SwirlProduct *grade1 = [[SwirlProduct alloc] initWithProductName:@"Dolch Grade 1"
                                                           productId: kProductIdentifierDolchPrimer
                                                           available: YES];
    
    [self.products setValue:grade1 forKey:grade1.productName];
    
    //Dolch Grade 2
    SwirlProduct *grade2 = [[SwirlProduct alloc] initWithProductName:@"Dolch Grade 2"
                                                           productId: kProductIdentifierDolchPrimer
                                                           available: YES];
    
    [self.products setValue:grade2 forKey:grade2.productName];
    
    //Dolch Grade 3
    SwirlProduct *grade3 = [[SwirlProduct alloc] initWithProductName:@"Dolch Grade 3"
                                                           productId: kProductIdentifierDolchPrimer
                                                           available: YES];
    
    [self.products setValue:grade3 forKey:grade3.productName];
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    NSDictionary *eventParams =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"Book Title", ebook.title,
     nil];
    
    [Flurry logEvent:@"ENTER_WORDLIST_S" withParameters:eventParams];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Word Lists";

    // load all the wordlists
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    	
    NSManagedObjectContext* context = [AppDelegate globalManagedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"WordList" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
    
#ifdef FREE
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
#endif
    
    NSError *error = nil;
	NSArray *_list = [context executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray* tempWordLists = [[NSMutableArray alloc] init];
    tempWordLists = [NSMutableArray arrayWithArray:_list];
    [tempWordLists sortUsingSelector:@selector(compare:)];
    self.wordLists = tempWordLists;
    
    //self.wordLists = [NSMutableArray arrayWithArray:_list];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.wordLists count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
	
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {
        // Other styles you can try
        // UITableViewCellStyleSubtitle
        // UITableViewCellStyleValue1
        // UITableViewCellStyleValue2s
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier: SimpleTableIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    WordList* wList = [self.wordLists objectAtIndex:indexPath.row];
    
    cell.textLabel.font = [UIFont fontWithName:@"Bella K. Mad Font" size:28];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Bella K. Mad Font" size:18];
    cell.detailTextLabel.textColor = [UIColor blueColor];
    
	cell.textLabel.text = wList.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i words", [wList.words count]];
    
    //if( swirlProduct == nil || ! [swirlProduct available] ) {
    if( ![self isWordListPurchased:wList.title] ) {
        
        [self setCellDisabled:cell];
        
    }
    
    return cell;
}

- (void) setCellDisabled:(UITableViewCell *)cell {
    
    UIView *myView = [[UIView alloc] init];
    //myView.backgroundColor = [UIColor darkGrayColor];
    myView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cyangradient.png"]];
    cell.backgroundView = myView;
    cell.textLabel.backgroundColor = [UIColor darkGrayColor];
    cell.detailTextLabel.backgroundColor = [UIColor darkGrayColor];
    cell.imageView.image = [UIImage imageNamed:@"Padlock_Icon_32.png"];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.;
}

-(BOOL)isWordListPurchased:(NSString*)name {
    
    SwirlProduct *swirlProduct = [self.products objectForKey:name];
    
    if( swirlProduct == nil || ! [swirlProduct available] ) {
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // open up the ebook with this wordlist
    WordList* wList = [self.wordLists objectAtIndex:indexPath.row];
    
    if( ![self isWordListPurchased:wList.title] ) {
        
        SwirlProduct *swirlProduct = [self.products objectForKey:wList.title];
        [self setCurrentlySelectedSwirlProduct:swirlProduct];
        [self displayInAppPurchase:swirlProduct.productName];
        
    } else {
    
        EpubChapterController* ecc = [[EpubChapterController alloc] initWithNibName:nil bundle:nil];
        ecc.wList = wList;
        ecc.ebook = ebook;
        [self.navigationController pushViewController:ecc animated:YES];
        
    }
}

- (void)displayInAppPurchase:(NSString*)listName
{
    dispatch_async(dispatch_get_main_queue(),^ {
        
        NSString *message;
//        switch ([error code])
//        {
//            case kCLErrorGeocodeFoundNoResult:
//                message = @"kCLErrorGeocodeFoundNoResult";
//                break;
//            case kCLErrorGeocodeCanceled:
//                message = @"kCLErrorGeocodeCanceled";
//                break;
//            case kCLErrorGeocodeFoundPartialResult:
//                message = @"kCLErrorGeocodeFoundNoResult";
//                break;
//            default:
//                message = [error description];
//                break;
//        }
        
        NSString *msg = @"\n1. Get rid of the adds\n2. Unlock bonus content.";
        NSString *fullMessage = [listName stringByAppendingString:msg];
        
        self.purchaseRequestAlert =  [[UIAlertView alloc] initWithTitle:@"Available for learning."
                                                          message:@"\n\n\n\n"
                                                         delegate:self
                                                cancelButtonTitle:@"Later"
                                                otherButtonTitles:@"Now",nil];
        
        UILabel *txtField = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 25.0, 260.0, 95.0)];
        [txtField setFont:[UIFont fontWithName:@"Helvetica-Bold" size:(18.0)]];
        txtField.numberOfLines = 4;
        txtField.textColor = [UIColor whiteColor];
        txtField.text = msg;
        txtField.backgroundColor = [UIColor clearColor];
        [self.purchaseRequestAlert addSubview:txtField];
        
        
        [self.purchaseRequestAlert show];
    });
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet == self.purchaseRequestAlert) {

        // the user clicked one of the OK/Cancel buttons
        if (buttonIndex == 0){
            
            NSLog(@"Later pressed");
            
        } else {
            
            NSLog(@"'Now' button pressed, will process payment here");
            
            if ([SKPaymentQueue canMakePayments]) {
            
                NSLog(@"Payments can be made, create and start the request");
                NSString *productId = self.currentlySelectedSwirlProduct.productId;
                
                SKProductsRequest *request =
                [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productId]];
                
                request.delegate = self;
                [request start];
                
            } else {
                
                UIAlertView *tmp = [[UIAlertView alloc]
                                    initWithTitle:@"Prohibited"
                                    message:@"Parental Control is enabled, cannot make a purchase!"
                                    delegate:self
                                    cancelButtonTitle:nil
                                    otherButtonTitles:@"OK", nil];
                
                [tmp show];  
            }
        }
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    // want to just show the whole word list
    WordList* wList = [self.wordLists objectAtIndex:indexPath.row];
    WordListDetailController* wdc = [[WordListDetailController alloc] initWithNibName:nil bundle:nil];
    wdc.wList = wList;
    [self.navigationController pushViewController:wdc animated:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    //return (interfaceOrientation == UIInterfaceOrientationPortrait ||
	//		interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown | UIInterfaceOrientationMaskLandscape;
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchasing: {
                
                // show wait view here
                //lgrose, will need some way of keeping the user informed like this...
                //statusLabel.text = @"Processing...";
                break;
            }
                
            case SKPaymentTransactionStatePurchased: {
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // remove wait view and unlock feature 2
                //lgrose, will need some way of keeping the user informed like this...
                //statusLabel.text = @"Done!";
                UIAlertView *tmp = [[UIAlertView alloc]
                                    initWithTitle:@"Complete"
                                    message:@"You have unlocked Feature 2!"
                                    delegate:self
                                    cancelButtonTitle:nil
                                    otherButtonTitles:@"Ok", nil];
                [tmp show];
                                
                NSError *error = nil;
//                [SFHFKeychainUtils storeUsername:@"IAPNoob01" andPassword:@"whatever" forServiceName:kStoredData updateExisting:YES error:&error];
                
                // apply purchase action  - hide lock overlay and
                //lgrose, not sure what this is needed for...yet
                //[feature2Btn setBackgroundImage:nil forState:UIControlStateNormal];
                
                // do other thing to enable the features
                
                break;
            }
                
            case SKPaymentTransactionStateRestored: {
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // remove wait view here
                //lgrose, will need some way of keeping the user informed like this...
                //statusLabel.text = @"";
                break;
            }
                
            case SKPaymentTransactionStateFailed: {
                
                if (transaction.error.code != SKErrorPaymentCancelled) {
                    NSLog(@"Error payment cancelled");
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // remove wait view here
                //lgrose, will need some way of keeping the user informed like this...
                //statusLabel.text = @"Purchase Error!";
                break;
            }
                
            default: {
                break;
            }
        }
    }
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    // remove wait view here
    //lgrose, will need some way of keeping the user informed like this...
    //statusLabel.text = @"";
    
    SKProduct *validProduct = nil;
    int count = [response.products count];
    
    if ( count > 0 ) {
        
        validProduct = [response.products objectAtIndex:0];
        
        //SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"com.emirbytes.IAPNoob.01"];
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:kProductIdentifierDolchGrade2];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
        
    } else {
        
        UIAlertView *tmp = [[UIAlertView alloc]
                            initWithTitle:@"Not Available"
                            message:@"No products to purchase"
                            delegate:self
                            cancelButtonTitle:nil
                            otherButtonTitles:@"OK", nil];
        [tmp show];
    
    }
    
    
}

-(void)requestDidFinish:(SKRequest *)request {
    //[request release];
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to connect with error: %@", [error localizedDescription]);
}


//I will trigger a lookup to the app store to confirm what's purchased and what's not purchased in the background
//I will store a purchase in the DB (I think the DB get's wiped so look out there)
//I can then confirm that what is purchased really is purchased
//-(BOOL)itemAvailable:(NSString*)title {
    
    //if productMap contains title {
    //    get product
    //    return product available
    //} else {
    //    return NO;
    //}
//}

@end
