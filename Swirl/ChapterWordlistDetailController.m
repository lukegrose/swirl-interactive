//
//  ChapterWordlistDetailController.m
//  Swirl
//
//  Created by Alex Shaykevich on 10/11/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "ChapterWordlistDetailController.h"
#import "WordList.h"
#import "WordCell.h"
#import "Word.h" 
#import "Flurry.h"

#define ROW_HEIGHT 67

@interface ChapterWordlistDetailController ()
@property(nonatomic, retain) NSArray* keys;
@property(nonatomic, retain) NSMutableDictionary* wListMap;

@end

@implementation ChapterWordlistDetailController
@synthesize tableView;
@synthesize wList;
@synthesize dict;
@synthesize keys;
@synthesize wListMap;

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
    self.title = @"Word Match";
    
    [Flurry logEvent:@"ENTER_CHAPTER_WORDLIST_DETAIL"];
    
    NSMutableArray* _keys = [NSMutableArray arrayWithArray:[dict allKeys]];
    //[_keys sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    [_keys sortUsingComparator:(NSComparator)^(id obj1, id obj2){
        NSString *key1 = (NSString*)obj1;
        NSString *key2 = (NSString*)obj2;
        
        NSNumber* val1 = [dict objectForKey:key1];
        NSNumber* val2 = [dict objectForKey:key2];
        
        return -1*[val1 compare:val2];
    }];
    
    self.keys = [NSArray arrayWithArray:_keys];
    
    self.wListMap = [NSMutableDictionary dictionary];
    // generate the WordList map
    for(Word* word in self.wList.words) {
        [wListMap setObject:word forKey:word.word];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate methods
#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dict count];
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
    NSString* key = [self.keys objectAtIndex:indexPath.row];
    Word* word = [self.wListMap objectForKey:key];    
    cell.word = word;
    
    NSNumber* n = [dict objectForKey:word.word];
    cell.mainLabel.text = [NSString stringWithFormat:@"%@ - %i occurrences", word.word, [n intValue]];
    
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

@end
