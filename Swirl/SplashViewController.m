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
#import "SplashViewController.h"
#import "Flurry.h"

@interface SplashViewController ()

@end

@implementation SplashViewController
@synthesize tableView;
@synthesize ebook;
@synthesize wordLists;
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Flurry logEvent:@"ENTER_ABOUT" timed:YES];
    
    self.title = @"About";
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"about" ofType:@"html"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
}

-(void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:YES];
    [Flurry endTimedEvent:@"ENTER_ABOUT" withParameters:Nil];
    
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
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // open up the ebook with this wordlist
    WordList* wList = [self.wordLists objectAtIndex:indexPath.row];
    EpubChapterController* ecc = [[EpubChapterController alloc] initWithNibName:nil bundle:nil];
    ecc.wList = wList;
    ecc.ebook = ebook;
    [self.navigationController pushViewController:ecc animated:YES];
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

@end
