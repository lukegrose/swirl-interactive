//
//  WordListDetailController.m
//  Swirl
//
//  Created by Alex Shaykevich on 22/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "WordListDetailController.h"
#import "WordList.h"
#import "WordCell.h"
#import "Word.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"

#define ROW_HEIGHT 67

@interface WordListDetailController ()

@end

@implementation WordListDetailController
@synthesize tableView;
@synthesize wList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    UIBarButtonItem* resetButton = [[UIBarButtonItem alloc]	initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target:self action:@selector(reset)];
    self.navigationController.navigationBar.topItem.rightBarButtonItem = resetButton;
    
    [Flurry logEvent:@"ENTER_BOOK_WORDLIST_DETAIL"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = wList.title;
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];

}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate methods
#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int n= [self.wList.words count];
    return [self.wList.words count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *SimpleTableIdentifier = @"wordCell";
	
	
    WordCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    
        
    if (cell == nil) {
        // Other styles you can try
        // UITableViewCellStyleSubtitle
        // UITableViewCellStyleValue1
        // UITableViewCellStyleValue2s
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
        //                              reuseIdentifier: SimpleTableIdentifier];
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"WordCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
        
        /*
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"WordListDetailController" owner:self options:nil];
        for(NSObject* o in topLevelObjects) {
            if([o isKindOfClass:[WordCell class]]) {
                cell = (WordCell*)o;
            }
        }*/
    }

    
    /*
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cell.autoresizesSubviews = YES;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [view.layer insertSublayer:gradient atIndex:0];
    cell.backgroundView = view;
*/
    Word* word = [self.wList.words objectAtIndex:indexPath.row];
    cell.word = word;
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

-(IBAction)reset {
    
    [Flurry logEvent:@"RESET_WORDLIST"];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Reset" message:@"Are you sure you want to reset all the words in this word list?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex != alertView.cancelButtonIndex) {
        for(Word* word in self.wList.words) {
            word.meaningComplete = [NSNumber numberWithBool:NO];
            word.spellingComplete = [NSNumber numberWithBool:NO];
        }
        
        NSError* error;
        if(! [[AppDelegate globalManagedObjectContext] save:&error]) {
            NSLog(@"%@", [error description]);
        }
        
        [self.tableView reloadData];
    }
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

@end
