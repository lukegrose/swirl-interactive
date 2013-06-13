//
//  EpubChapterController.m
//  Swirl
//
//  Created by Alex Shaykevich on 22/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "EpubChapterController.h"
#import "Ebook.h"
#import "Chapter.h"
#import "AppDelegate.h"
#import "WordList.h"
#import "Word.h"
#import "MBProgressHUD.h"
#import "ChapterViewController.h"
#import "ChapterWordlistDetailController.h"
#import "Flurry.h"

@interface EpubChapterController ()
-(NSString*)key;
-(NSString*)keyForChapter:(Chapter*)chapter;

@property(nonatomic, retain) NSMutableDictionary* chapterWordMap;
@end

@implementation EpubChapterController
@synthesize tableView;
@synthesize ebook;
@synthesize chapterWordMap;
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
    [super viewDidAppear:animated];
    
    NSDictionary *eventParams =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"Wordlist", wList.title,
     nil];
    
    [Flurry logEvent:@"ENTER_TOC" withParameters:eventParams];
    
    if(self.chapterWordMap == nil) {
        self.chapterWordMap = [NSMutableDictionary dictionary];
        [self showProgress];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString* ebookBase = [[AppDelegate getEpubDirPath] stringByAppendingPathComponent:ebook.basePath];
            
            // look up how many words in each chapter
            int index = 0;
            for(Chapter* chapter in self.ebook.chapters) {
                //NSString* filePath = [[AppDelegate getEpubDirPath] stringByAppendingPathComponent:chapter.path];
                
                NSString* filePath = [AppDelegate findFile:chapter.path inDir:ebookBase];
                
                NSString* html = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
                NSArray* words = [AppDelegate htmlToWords:html];
                
                // create a map to avoid iteration
                NSMutableDictionary* map = [NSMutableDictionary dictionaryWithCapacity:[words count]];
                for(NSString* word in words) {
                    int num = 1;
                    if([map objectForKey:word] != nil) {
                        NSNumber* n = [map objectForKey:word];
                        num = [n intValue] + 1;
                    }
                    [map setObject:[NSNumber numberWithInt:num] forKey:word];
                }
                
                // create a map to hold the number
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                
                // figure out if the word list words occur in the chapter
                int count = 0;
                for(Word* _word in self.wList.words) {
                    NSString* word = _word.word;
                    
                    if([map objectForKey:word] != nil) {
                        count++;
                        
                        NSNumber* howMany = [map objectForKey:word];
                        [dict setObject:howMany forKey:word];
                    }
                    
                    /*
                    for(NSString* s in words) {
                        if([[s lowercaseString] isEqualToString:[word lowercaseString]]) {
                            count++;
                            break;
                        }
                    }
                     */
                }
                
                if([dict count] > 0) {
                    NSDictionary* storeDict = [NSDictionary dictionaryWithDictionary:dict];
                   [[NSUserDefaults standardUserDefaults] setObject:storeDict forKey:[self keyForChapter:chapter]];
                }
                
                [chapterWordMap setObject:[NSNumber numberWithInt:count] forKey:[NSNumber numberWithInt:index++]];
            }

            NSData* d = [NSKeyedArchiver archivedDataWithRootObject:chapterWordMap];
            [[NSUserDefaults standardUserDefaults] setObject:d forKey:[self key]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self hideProgress];
                [self.tableView reloadData];
                
            });
        });        
    }
    
}

-(NSString*)keyForChapter:(Chapter*)chapter {
    return [NSString stringWithFormat:@"%@_%@_%@", ebook.basePath, wList.basePath,  chapter.title];
}

-(NSString*)key {
    return [NSString stringWithFormat:@"%@-%@", ebook.basePath, wList.basePath];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Table of Contents";
    
    NSData* d = [[NSUserDefaults standardUserDefaults] objectForKey:[self key]];
    if(d != nil) {
        self.chapterWordMap = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:d];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.ebook.chapters count];
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
    }
    
    Chapter* chapter = [self.ebook.chapters objectAtIndex:indexPath.row];
    
    NSDictionary* dict = [[NSUserDefaults standardUserDefaults] objectForKey:[self keyForChapter:chapter]];
    cell.accessoryType = [dict count] > 0 ? UITableViewCellAccessoryDetailDisclosureButton: UITableViewCellAccessoryNone;
    
    cell.textLabel.font = [UIFont fontWithName:@"Bella K. Mad Font" size:28];
	cell.textLabel.text = chapter.title;
    NSNumber* _n = [chapterWordMap objectForKey:[NSNumber numberWithInt:indexPath.row]];
    int n = _n != nil ? [_n intValue] : 0;
    
    cell.detailTextLabel.font = [UIFont fontWithName:@"Bella K. Mad Font" size:18];
    cell.detailTextLabel.textColor = [UIColor purpleColor];
    if(n == 1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i word", n];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i words", n];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // open up the ebook with this wordlist
    ChapterViewController* cvc = [[ChapterViewController alloc] initWithNibName:nil bundle:nil];
    cvc.index = indexPath.row;
    cvc.ebook = ebook;
    cvc.wList = wList;
    [self.navigationController pushViewController:cvc animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    Chapter* chapter = [self.ebook.chapters objectAtIndex:indexPath.row];
    NSDictionary* dict = [[NSUserDefaults standardUserDefaults] objectForKey:[self keyForChapter:chapter]];
    
    ChapterWordlistDetailController* cwd = [[ChapterWordlistDetailController alloc] initWithNibName:nil bundle:nil];
    cwd.dict = dict;
    cwd.wList = self.wList;
    [self.navigationController pushViewController:cwd animated:YES];
    
    /*
    // want to just show the whole word list
    WordList* wList = [self.wordLists objectAtIndex:indexPath.row];
    WordListDetailController* wdc = [[WordListDetailController alloc] initWithNibName:nil bundle:nil];
    wdc.wList = wList;
    [self.navigationController pushViewController:wdc animated:YES];
     */
}

-(void)showProgress {
    if (self.isViewLoaded && self.view.window) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

-(void)hideProgress {
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
