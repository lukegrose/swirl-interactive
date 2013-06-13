//
//  MasterViewController.m
//  Swirl
//
//  Created by Alex Shaykevich on 19/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ZipArchive.h"
#import "AppDelegate.h"
#import "TBXML.h"
#import "Ebook.h"
#import "Chapter.h"
#import "MBProgressHUD.h"
#import "WordList.h"
#import "Word.h"
#import "Ebook.h"
#import "WordListController.h"
#import "SplashViewController.h"
#import "Flurry.h"


#define FREE_KEY @"freekey"

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (NSString*)unzipAndSaveFile:(NSString*)epubPath;
-(NSString*)pathForContentsXML:(NSString*)basePath;
-(NSString*)pathForOPFFileFromContentsXML:(NSString*)contentsPath;
-(void)showProgress;
-(void)hideProgress;
-(void)processWordList:(NSString*)pathToList;
-(void)processEpub:(NSString*)epubName;
-(void)processEpub:(NSString*)epubName dir:(NSString*)dir;
-(void)loadEpubs;
-(void)syncWithDocDir;
-(void)customiseAppearance;
-(BOOL)isEpubAvailable;
-(BOOL)isWordlistAvailable;

@property(nonatomic, strong) DirectoryWatcher* watcher;
@end

@implementation MasterViewController
@synthesize watcher;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [Flurry logEvent:@"ENTER_BOOKSHELF"];
    
    if(firstAppearance) {
        // add the directory watcher
        
//#if !FREE
        self.watcher = [DirectoryWatcher watchFolderWithPath:[AppDelegate getDocDirPath] delegate:self];
//#endif
        
//#if !TARGET_IPHONE_SIMULATOR && !FREE
        //[self syncWithDocDir];
//#endif
        
        
//#ifdef FREE
        
        BOOL loaded = NO;
        
        // commented to >>here by lgrose
        // 1. Are complete words removed with each restart of the application?
        // 2. Will new lists be added correctly?
        // 3. Will change from NSLibraryDirectory to NSCachesDirectory be seamless for those with existing installations?
        // NB: 'path' field in epub will point to a different dir altogether so can't just delete and replace
        // NB1: Don't be so sure about the path comment above. The Wordlist / Word data and the Epub / Chapter data
        //      are maintained separately. I may well be able to clear the Epub / Chapter directory completely, regenerate
        //      the dirs each time. But, then, how to do the Wordlist / Word data? zipOrigin might be the key there too.
        //      If zip file name == Wordlist.zipOrigin, do not recreate. This will be the best way me thinks. Even better,
        //      this will be the way I'm going to do it, so just do it already!
        
        /*NSNumber* n = [[NSUserDefaults standardUserDefaults] objectForKey:FREE_KEY];
        if(n != nil) {
            loaded = [n boolValue];
        }*/
        
        //<<here
        
        if(! loaded) {
            
            
            NSString* path = [[NSBundle mainBundle] pathForResource:@"ebooks" ofType:nil];
            NSString* wListPath = [[NSBundle mainBundle] pathForResource:@"wordlists" ofType:nil];
            
            [self showProgress];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //[self testoWords];
                
                NSArray* paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
                for(NSString* p in paths) {
                    NSString* ext = [p pathExtension];
                    if([ext isEqualToString:@"epub"] == NO) {
                        continue;
                    }
                    
                    //lgrose, method call here to check
                    //lgrose, if ( ! [self ebookExists:p] ) {
                    //lgrose,    [self processEpub:p dir:path];
                    //lgrose, }
                    //[self isEpubAvailable:p]; //lgrose
                
                    // process it
                    [self processEpub:p dir:path];
                }
                
                paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:wListPath error:nil];
                for(NSString* p in paths) {
                    NSString* ext = [p pathExtension];
                    if([ext isEqualToString:@"zip"] == NO) {
                        continue;
                    }
                    
                    //lgrose, method call here to check
                    //lgrose, if ( ! [self wordlistExists:p] ) {
                    //lgrose,     [self processWordList:[wListPath stringByAppendingPathComponent:p]];
                    //lgrose, }
                    
                    // process it
                    [self processWordList:[wListPath stringByAppendingPathComponent:p]];
                }
                
                // finish up
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // save everything
                    NSError* error = nil;
                    if(! [[AppDelegate globalManagedObjectContext] save:&error]) {
                        NSLog(@"Error: %@", [error description]);
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:FREE_KEY];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self hideProgress];
                    
                    [self loadEpubs];
                    [self.tableView reloadData];
                });
            });
            
        }
//#endif
        
        firstAppearance = NO;
        return;
    }
    
    
//#if !TARGET_IPHONE_SIMULATOR && !FREE
    if(markedForChange) {
        [self syncWithDocDir];
        markedForChange = NO;
    }
//#endif
    
}

-(void)syncWithDocDir {
    // sync with documents directory
    [self showProgress];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString* docDir = [AppDelegate getDocDirPath];
        NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docDir error:nil];
        NSMutableArray* toDelete = [NSMutableArray array];
        NSMutableArray* toAdd = [NSMutableArray array];
        
        // check which ones to delete
        for(Ebook* book in self.ebooks) {
            BOOL found = NO;
            for(NSString* file in contents) {
                if([[file pathExtension] isEqualToString:@"epub"] == NO) {
                    continue;
                }
                if([book.epubName isEqualToString:file]) {
                    found = YES;
                    break;
                }
            }
            if(! found) {
                // mark for deletion
                [toDelete addObject:book];
            }
        }
        
        // check which ones to add
        for(NSString* file in contents) {
            if([[file pathExtension] isEqualToString:@"epub"] == NO) {
                continue;
            }
            
            BOOL found = NO;
            for(Ebook* book in self.ebooks) {
                if([book.epubName isEqualToString:file]) {
                    found = YES;
                    break;
                }
            }
            if(! found) {
                [toAdd addObject:file];
            }
        }
        
        // delete stuff
        for(Ebook* book in toDelete) {
            NSString* path = [[AppDelegate getEpubDirPath] stringByAppendingPathComponent:book.basePath];
            [[AppDelegate globalManagedObjectContext] deleteObject:book];
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        
        // add stuff
        for(NSString* epubFileName in toAdd) {
            [self processEpub:epubFileName];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self hideProgress];

            if([toAdd count] > 0 || [toDelete count] > 0) {
                
                NSError* error;
                if(! [[AppDelegate globalManagedObjectContext] save:&error]) {
                    NSLog(@"%@", [error description]);
                }
                
                 // need to reload the epub list
                [self loadEpubs];
                [self.tableView reloadData];
            }
        });
    });

}

-(void)loadEpubs {
    // load all the ebooks
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
//#ifdef FREE
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
//#endif
    
    NSManagedObjectContext* context = [AppDelegate globalManagedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ebook" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
    NSError *error = nil;
	NSArray *_list = [context executeFetchRequest:fetchRequest error:&error];
    if(error ) {
        NSLog(@"Error:%@", [error description]);
    }
    self.ebooks = [NSMutableArray arrayWithArray:_list];
    [self.ebooks sortedArrayUsingSelector:@selector(compare:)];
}

- (void)customiseAppearance {
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                                                          UITextAttributeTextColor,
                                                          [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
                                                          UITextAttributeTextShadowColor,
                                                          [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                          UITextAttributeTextShadowOffset, 
                                                          [UIFont fontWithName:@"Trebuchet MS" size:0.0], 
                                                          UITextAttributeFont, 
                                                          nil]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar-Wood"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor brownColor]];
    [self customiseAppearance];
    
    markedForChange = NO;
#if TARGET_IPHONE_SIMULATOR && !FREE
    //[self testo];
#endif
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    self.title = @"SWIRL";
    firstAppearance = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    [self loadEpubs];
            
    /*
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
     */
    
    UIButton *modalViewButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[modalViewButton addTarget:self action:@selector(modalViewAction:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *modalBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:modalViewButton];
	self.navigationItem.rightBarButtonItem = modalBarButtonItem;
	    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ebooks count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        /*
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
         */
    }

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Ebook* book = [self.ebooks objectAtIndex:indexPath.row];
    WordListController* wlc = [[WordListController alloc] initWithNibName:nil bundle:nil];
    wlc.ebook = book;
    
    [self.navigationController pushViewController:wlc animated:YES];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.font = [UIFont fontWithName:@"Bella K. Mad Font" size:28];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Bella K. Mad Font" size:18];
    cell.detailTextLabel.textColor = [UIColor blueColor];
    
    Ebook* book = [self.ebooks objectAtIndex:indexPath.row];
    cell.textLabel.text = book.title;
    cell.detailTextLabel.text = book.author;
}

#pragma mark - Epub unpacking and parsing
-(void)processEpub:(NSString *)epubName {
    [self processEpub:epubName dir:nil];
}

-(void)processEpub:(NSString*)epubName dir:(NSString*)dir {
    
    //lgrose, it looks like there is a few locations for this method to be called
    //lgrose, I will call [self isEpubAvailable] from here and return
    if( [self isEpubAvailable:epubName] ) {
        return;
    }
    
    if([epubName isEqualToString:@"thewonderfulwizardofoz.epub"]) {
        NSLog(@"Oz");
    }
    
    NSString* epubPath = [[AppDelegate getDocDirPath] stringByAppendingPathComponent:epubName];
    if(dir != nil) {
        epubPath = [dir stringByAppendingPathComponent:epubName];
    }
    
    NSString* newDir = [self unzipAndSaveFile:epubPath];
    if(newDir == nil || [[NSFileManager defaultManager] fileExistsAtPath:newDir] == NO) {
        // didn't work
        return;
    }
    
    // container.xml
    NSString* containerPath = [self pathForContentsXML:newDir];
    if(containerPath == nil) {
        return;
    }
    
    // get the opf file
    NSString* opfPath = [self pathForOPFFileFromContentsXML:containerPath];
    if(opfPath == nil) {
        // epub must have an opf file
        return;
    }
    
    // get things like title and author from the opf file
    NSString* xmls = [NSString stringWithContentsOfFile:opfPath encoding:NSUTF8StringEncoding error:nil];
    NSError* error;
    TBXML* opfXML = [TBXML newTBXMLWithXMLString:xmls error:&error];
    if(error) {
        NSLog(@"OPF Error: %@", [error description]);
        return;
    }
    
    TBXMLElement* metadata = [TBXML childElementNamed:@"metadata" parentElement:opfXML.rootXMLElement];
    if(! metadata) {
        return;
    }
    TBXMLElement* useMeta = metadata;
    
    TBXMLElement* dcmetadata = [TBXML childElementNamed:@"dc-metadata" parentElement:metadata];
    if(dcmetadata) {
        useMeta = dcmetadata;
    }
    TBXMLElement* etitle = [TBXML childElementNamed:@"dc:title" parentElement:useMeta];
    if(! etitle) {
        return;
    }
    TBXMLElement* ecreator = [TBXML childElementNamed:@"dc:creator" parentElement:useMeta];
    
    /*
    __block Ebook* ebook;
    dispatch_sync(dispatch_get_main_queue(), ^{
        ebook = (Ebook*)[NSEntityDescription insertNewObjectForEntityForName:@"Ebook" inManagedObjectContext:[AppDelegate globalManagedObjectContext]];
        ebook.title = [TBXML textForElement:etitle];
        ebook.author = [TBXML textForElement:ecreator];
        ebook.epubName = epubName;
        ebook.basePath = [newDir lastPathComponent];
    });
     */
    
    Ebook *ebook = (Ebook*)[NSEntityDescription insertNewObjectForEntityForName:@"Ebook" inManagedObjectContext:[AppDelegate globalManagedObjectContext]];
    ebook.title = [TBXML textForElement:etitle];
    ebook.author = [TBXML textForElement:ecreator];
    ebook.epubName = epubName;
    ebook.basePath = [newDir lastPathComponent];
    
    // go straight to the NCX file if present
    NSString* ncxPath = [self pathForNCXFile:newDir];
    NSString* ncxBasePath = [ncxPath stringByDeletingLastPathComponent];
    
    if(ncxPath != nil) {
        xmls = [NSString stringWithContentsOfFile:ncxPath encoding:NSUTF8StringEncoding error:nil];
        TBXML* ncxXML = [TBXML newTBXMLWithXMLString:xmls error:&error];
        if(error) {
            NSLog(@"NCX Error: %@", [error description]);
            [[AppDelegate globalManagedObjectContext] deleteObject:ebook];
            return;
        }
        TBXMLElement* navMap = [TBXML childElementNamed:@"navMap" parentElement:ncxXML.rootXMLElement];
        
        [self recursiveNavPointLookup:ebook parent:navMap];
        
        /*
        TBXMLElement* navPoint;
        for (navPoint = [TBXML childElementNamed:@"navPoint" parentElement:navMap];
             navPoint;
             navPoint = [TBXML nextSiblingNamed:@"navPoint" searchFromElement:navPoint])
        {
            
            
            TBXMLElement* navLabel = [TBXML childElementNamed:@"navLabel" parentElement:navPoint];
            TBXMLElement* text = [TBXML childElementNamed:@"text" parentElement:navLabel];
            NSString* title = [TBXML textForElement:text];
            TBXMLElement* content = [TBXML childElementNamed:@"content" parentElement:navPoint];
            NSString* src = [TBXML valueOfAttributeNamed:@"src" forElement:content];
            
            NSString* base = [src stringByDeletingPathExtension];
            NSString* ext = [[src pathExtension] lowercaseString];
            NSRange r = [ext rangeOfString:@"html"];
            
            if(r.location != NSNotFound) {
                src = [NSString stringWithFormat:@"%@.html", base];
            } else {
                r = [ext rangeOfString:@"htm"];
                if(r.location != NSNotFound) {
                    src = [NSString stringWithFormat:@"%@.htm", base];
                }                
            }
            
            Chapter *chapter = (Chapter*)[NSEntityDescription insertNewObjectForEntityForName:@"Chapter" inManagedObjectContext:[AppDelegate globalManagedObjectContext]];
            chapter.title = title;
            chapter.path = src;
            [ebook addChaptersObject:chapter];            
        }
         */
    } else {
        // get evertyhing from the opf path
        TBXMLElement* manifest = [TBXML childElementNamed:@"manifest" parentElement:opfXML.rootXMLElement];
        TBXMLElement* item;
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        for (item = [TBXML childElementNamed:@"item" parentElement:manifest];
             item;
             item = [TBXML nextSiblingNamed:@"item" searchFromElement:item])
        {
            NSString* itemID = [TBXML valueOfAttributeNamed:@"id" forElement:item];
            NSString* href = [TBXML valueOfAttributeNamed:@"href" forElement:item];
            [dict setObject:href forKey:itemID];
        }

        TBXMLElement* spline = [TBXML childElementNamed:@"spline" parentElement:opfXML.rootXMLElement];
        for (item = [TBXML childElementNamed:@"itemref" parentElement:spline];
             item;
             item = [TBXML nextSiblingNamed:@"itemref" searchFromElement:item])
        {
            NSString* idref = [TBXML valueOfAttributeNamed:@"idref" forElement:item];
            // name of file
            NSString* src = [dict objectForKey:idref];
            
            NSArray* parts = [src componentsSeparatedByString:@"#"];
            NSString* anchor = nil;
            if([parts count] > 1) {
                anchor = [parts objectAtIndex:1];
            }
            
            NSString* base = [src stringByDeletingPathExtension];
            NSString* ext = [[src pathExtension] lowercaseString];
            NSRange r = [ext rangeOfString:@"html"];
            
            if(r.location != NSNotFound) {
                src = [NSString stringWithFormat:@"%@.html", base];
            } else {
                r = [ext rangeOfString:@"htm"];
                if(r.location != NSNotFound) {
                    src = [NSString stringWithFormat:@"%@.htm", base];
                }
            }
            
            Chapter *chapter = (Chapter*)[NSEntityDescription insertNewObjectForEntityForName:@"Chapter" inManagedObjectContext:[AppDelegate globalManagedObjectContext]];
            chapter.title = idref;
            chapter.path = src;
            if(anchor != nil) {
                chapter.anchor = anchor;
            }
            [ebook addChaptersObject:chapter];
            
            /*
            dispatch_sync(dispatch_get_main_queue(), ^{
                Chapter *chapter = (Chapter*)[NSEntityDescription insertNewObjectForEntityForName:@"Chapter" inManagedObjectContext:[AppDelegate globalManagedObjectContext]];
                chapter.title = idref;
                chapter.path = href;
                
                [ebook addChaptersObject:chapter];
            });
            */
        }
    }
    
}

-(void)recursiveNavPointLookup:(Ebook*)ebook parent:(TBXMLElement*)parent {
    
    TBXMLElement* navPoint;
    for (navPoint = [TBXML childElementNamed:@"navPoint" parentElement:parent];
         navPoint;
         navPoint = [TBXML nextSiblingNamed:@"navPoint" searchFromElement:navPoint])
    {
        
        // process the nav point
        TBXMLElement* navLabel = [TBXML childElementNamed:@"navLabel" parentElement:navPoint];
        TBXMLElement* text = [TBXML childElementNamed:@"text" parentElement:navLabel];
        NSString* title = [TBXML textForElement:text];
        title = [AppDelegate stringByStrippingHTML:title];
        
        TBXMLElement* content = [TBXML childElementNamed:@"content" parentElement:navPoint];
        NSString* src = [TBXML valueOfAttributeNamed:@"src" forElement:content];
        
        NSArray* parts = [src componentsSeparatedByString:@"#"];
        NSString* anchor = nil;
        if([parts count] > 1) {
            anchor = [parts objectAtIndex:1];
        }
        
        NSString* base = [src stringByDeletingPathExtension];
        NSString* ext = [[src pathExtension] lowercaseString];
        NSRange r = [ext rangeOfString:@"html"];
        
        if(r.location != NSNotFound) {
            src = [NSString stringWithFormat:@"%@.html", base];
        } else {
            r = [ext rangeOfString:@"htm"];
            if(r.location != NSNotFound) {
                src = [NSString stringWithFormat:@"%@.htm", base];
            }
        }
        
        Chapter *chapter = (Chapter*)[NSEntityDescription insertNewObjectForEntityForName:@"Chapter" inManagedObjectContext:[AppDelegate globalManagedObjectContext]];
        chapter.title = title;
        chapter.path = src;
        if(anchor != nil) {
            chapter.anchor = anchor;
        }
        [ebook addChaptersObject:chapter];

        // process children of the element
        [self recursiveNavPointLookup:ebook parent:navPoint];
    }
    
}

// lgrose, has this wordlist already been processed?
- (BOOL)isWordlistAvailable:(NSString *)zipOrigin {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext* context = [AppDelegate globalManagedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"WordList" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
    NSError *error = nil;
	NSArray *_list = [context executeFetchRequest:fetchRequest error:&error];
    
    if(error ) {
        NSLog(@"Error:%@", [error description]);
    }
    
    NSMutableArray *availableWordLists = [NSMutableArray arrayWithArray:_list];
    
    for(WordList* wlist in availableWordLists) {
        
        if ( [wlist.zipOrigin isEqualToString:zipOrigin] ) {
            
            NSLog(@"zipOrigin of the loaded Wordlist is [%@], zipOrigin of the new WordList is [%@]", wlist.zipOrigin, zipOrigin);
            return YES;
            
        }
        
    }

    return NO;
    
}

// Method added by lgrose
// There needs to be a way to check that the NSCachesDirectory already had an extracted
// epub for each file in the epub dir
- (BOOL)isEpubAvailable:(NSString *)epubName {
    
    // Blatantly copied from loadEpubs by lgrose
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext* context = [AppDelegate globalManagedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ebook" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	NSError *error = nil;
	NSArray *_list = [context executeFetchRequest:fetchRequest error:&error];
    
    if(error ) {
        NSLog(@"Error:%@", [error description]);
    }
    
    NSMutableArray *availableEbooks = [NSMutableArray arrayWithArray:_list];
    
    for(Ebook* availableEbook in availableEbooks) {
        
        if ( [availableEbook.epubName isEqualToString:epubName] ) {
        
            NSLog(@"Available ebook.epubName is [%@], epubName to be loaded is [%@]", availableEbook.epubName, epubName);
            return YES;
            
        }
    }
    
    return NO;
}

- (NSString*)unzipAndSaveFile:(NSString*)epubPath {
	
    ZipArchive* za = [[ZipArchive alloc] init];
    NSString* newDir = nil;
	if( [za UnzipOpenFile:epubPath] ){
		
        // timestamp unique identifier
        NSString* newDirName = [NSString stringWithFormat:@"%f", CFAbsoluteTimeGetCurrent()];
        newDir = [[AppDelegate getEpubDirPath] stringByAppendingPathComponent:newDirName];
        
		//Delete all the previous files, shouldn't be necessary
		NSFileManager *filemanager=[[NSFileManager alloc] init];
		if ([filemanager fileExistsAtPath:newDir]) {
			NSError *error;
			[filemanager removeItemAtPath:newDir error:&error];
		}

		//start unzip
		BOOL ret = [za UnzipFileTo:[NSString stringWithFormat:@"%@/",newDir] overWrite:YES];
		if( NO==ret ){
            NSLog(@"Error unzipping");
            return nil;
            /*
			// error handler here
			UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
														  message:@"An unknown error occured"
														 delegate:self
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
			[alert show];
             */
		}
		[za UnzipCloseFile];
	}
    return newDir;
}

-(NSString*)pathForContentsXML:(NSString*)basePath {
    NSString* path = [basePath stringByAppendingPathComponent:@"META-INF/container.xml"];
    if([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        return nil;
    }
    return path;
}

-(NSString*)pathForOPFFileFromContentsXML:(NSString*)contentsPath {
    NSString* basePath = [[contentsPath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];

    // Enumerators are recursive
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:basePath];
    
    NSString *filePath;
    while ((filePath = [enumerator nextObject]) != nil) {
        NSString* ext = [filePath pathExtension];
        if([ext isEqualToString:@"opf"]) {
            return [basePath stringByAppendingPathComponent:filePath];
        }
    }
    
    return nil;

}

-(NSString*)pathForOPFFileFromContentsXML2:(NSString*)contentsPath {
    // need to open it up and look for the root file
    NSString* xmls = [NSString stringWithContentsOfFile:contentsPath encoding:NSASCIIStringEncoding error:nil];
    NSError* error;
    TBXML* tbxml = [TBXML newTBXMLWithXMLString:xmls error:&error];
    if(error) {
        NSLog(@"%@", [error description]);
        return nil;
    }
    TBXMLElement* rootFiles = [TBXML childElementNamed:@"rootfiles" parentElement:tbxml.rootXMLElement];
    if(rootFiles == nil) {
        return nil;
    }
    
    TBXMLElement* rootFile = [TBXML childElementNamed:@"rootfile" parentElement:rootFiles];
    if(rootFile == nil) {
        return nil;
    }
    
    NSString* path = [TBXML valueOfAttributeNamed:@"full-path" forElement:rootFile];
    if(path == nil) {
        return nil;
    }
    
    NSString* baseDir = [[contentsPath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    NSString* opfPath = [baseDir stringByAppendingPathComponent:path];
    if([[NSFileManager defaultManager] fileExistsAtPath:opfPath] == NO) {
        return nil;
    }
    
    return opfPath;
}

-(NSString*)pathForNCXFile:(NSString*)basePath {
    // Enumerators are recursive
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:basePath];
    
    NSString *filePath;
    while ((filePath = [enumerator nextObject]) != nil) {
        NSString* ext = [filePath pathExtension];
        if([ext isEqualToString:@"ncx"]) {
            return [basePath stringByAppendingPathComponent:filePath];
        }
    }
    
    return nil;
}


#pragma mark - UI Blocking Progress
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

#pragma mark - Processing Wordlists
-(void)processWordList:(NSString*)pathToList {
    
    if ( [self isWordlistAvailable:[pathToList lastPathComponent]] ) {
        return;
    }
    
    NSString* dir = [AppDelegate getWordlistDirPath];
    NSString* newName = [NSString stringWithFormat:@"%f", CFAbsoluteTimeGetCurrent()];
    NSString* newDir = [dir stringByAppendingPathComponent:newName];
    
    ZipArchive* za = [[ZipArchive alloc] init];
	if( [za UnzipOpenFile:pathToList] ){
		
		//Delete all the previous files, shouldn't be necessary
		NSFileManager *filemanager=[[NSFileManager alloc] init];
		if ([filemanager fileExistsAtPath:newDir]) {
			NSError *error;
			[filemanager removeItemAtPath:newDir error:&error];
		}
        
		//start unzip
		BOOL ret = [za UnzipFileTo:[NSString stringWithFormat:@"%@/",newDir] overWrite:YES];
		if( NO==ret ){
            NSLog(@"Error unzipping");
            return;
            /*
             // error handler here
             UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
             message:@"An unknown error occured"
             delegate:self
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil];
             [alert show];
             */
		}
		[za UnzipCloseFile];
	}

    // now it's unzipped, get the wordlist.xml
    NSString* xmlFile = [newDir stringByAppendingPathComponent:@"wordlist.xml"];
    if([[NSFileManager defaultManager] fileExistsAtPath:xmlFile] == NO) {
        return;
    }
    
    NSString* xmls = [NSString stringWithContentsOfFile:xmlFile encoding:NSASCIIStringEncoding error:nil];
    NSError* error;
    TBXML* xml = [TBXML newTBXMLWithXMLString:xmls error:&error];
    if(error) {
        NSLog(@"%@", [error description]);
        return;
    }
    
    NSString* name = [TBXML valueOfAttributeNamed:@"name" forElement:xml.rootXMLElement];
    
    WordList* wList = [NSEntityDescription insertNewObjectForEntityForName:@"WordList" inManagedObjectContext:[AppDelegate globalManagedObjectContext]];
    wList.basePath = newName;
    wList.title = name;
    wList.zipOrigin = [pathToList lastPathComponent];
    
    TBXMLElement* eword;
    for (eword = [TBXML childElementNamed:@"word" parentElement:xml.rootXMLElement];
         eword;
         eword = [TBXML nextSiblingNamed:@"word" searchFromElement:eword])
    {
        TBXMLElement* ename = [TBXML childElementNamed:@"name" parentElement:eword];
        TBXMLElement* emeaning = [TBXML childElementNamed:@"meaning" parentElement:eword];
        TBXMLElement* echoice1 = [TBXML childElementNamed:@"choice1" parentElement:eword];
        TBXMLElement* echoice2 = [TBXML childElementNamed:@"choice2" parentElement:eword];
        TBXMLElement* echoice3 = [TBXML childElementNamed:@"choice3" parentElement:eword];
        
        Word* word = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:[AppDelegate globalManagedObjectContext]];
        word.word = [TBXML textForElement:ename];
        word.meaning = [TBXML textForElement:emeaning];
        word.choice1 = [TBXML textForElement:echoice1];
        word.choice2 = [TBXML textForElement:echoice2];
        word.choice3 = [TBXML textForElement:echoice3];
        
        //lgrose, or I could do the final check here
        //lgrose, pro's for here? less code change, no datamodel change
        //lgrose, con's for here? process the entire zip for nothing
        [wList addWordsObject:word];
    }
    
    if(![[AppDelegate globalManagedObjectContext] save:&error]) {
        NSLog(@"%@", [error description]);
        return;
    }
    
}

#pragma mark - DirectoryWatcherDelegate 
- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher {
    
    // only allow this if we're on the page itself
    if (self.isViewLoaded && self.view.window) {
        markedForChange = NO;
        int64_t delayInSeconds = 1.;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self syncWithDocDir];
        });
    } else {
        markedForChange = YES;
    }
    
}

// This is only for testing to make life easier with the simulator
-(void)testoWords {
    // delete old word lists
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext* context = [AppDelegate globalManagedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"WordList" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
    NSError *error = nil;
	NSArray *_list = [context executeFetchRequest:fetchRequest error:&error];
    for(WordList* wList in _list) {
        [[AppDelegate globalManagedObjectContext] deleteObject:wList];
    }
    [[AppDelegate globalManagedObjectContext] save:nil];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"Wordlist1" ofType:@"zip"];
    [self processWordList:path];
}

-(void)testo {
    
    // delete old word lists
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext* context = [AppDelegate globalManagedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"WordList" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
    NSError *error = nil;
	NSArray *_list = [context executeFetchRequest:fetchRequest error:&error];
    for(WordList* wList in _list) {
        [[AppDelegate globalManagedObjectContext] deleteObject:wList];
    }
    [[AppDelegate globalManagedObjectContext] save:nil];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"Wordlist1" ofType:@"zip"];
    [self processWordList:path];
    
    
    fetchRequest = [[NSFetchRequest alloc] init];
	entity = [NSEntityDescription entityForName:@"Ebook" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	_list = [context executeFetchRequest:fetchRequest error:&error];
    for(Ebook* ebook in _list) {
        [[AppDelegate globalManagedObjectContext] deleteObject:ebook];
    }
    
    path = [[NSBundle mainBundle] pathForResource:@"peterpan" ofType:@"epub"];
    [self processEpub:[path lastPathComponent] dir:[path stringByDeletingLastPathComponent]];
    
    if(![[AppDelegate globalManagedObjectContext] save:&error]) {
        NSLog(@"%@", [error description]);
        return;
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

- (IBAction)modalViewAction:(id)sender
{
//    if (self.myModalViewController == nil)
//        self.myModalViewController = [[ModalViewController alloc] initWithNibName:
//                                       NSStringFromClass([ModalViewController class]) bundle:nil];
//    
//	[self.navigationController presentModalViewController:self.myModalViewController animated:YES];

    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //Ebook* book = [self.ebooks objectAtIndex:indexPath.row];
    SplashViewController* svc = [[SplashViewController alloc] initWithNibName:nil bundle:nil];
    //wlc.ebook = book;
    [self.navigationController pushViewController:svc animated:YES];

}



@end
