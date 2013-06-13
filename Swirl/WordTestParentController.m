//
//  WordTestParentController.m
//  Swirl
//
//  Created by Alex Shaykevich on 23/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "WordTestParentController.h"
#import "WordTestController.h"
#import "WordList.h"
#import "Word.h"

@interface WordTestParentController ()

@end

@implementation WordTestParentController
@synthesize wList;
@synthesize word;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    WordTestController* wtc = [[WordTestController alloc] initWithNibName:nil bundle:nil];
    wtc.word = word;
    wtc.wList = wList;
    [self pushViewController:wtc animated:NO];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
