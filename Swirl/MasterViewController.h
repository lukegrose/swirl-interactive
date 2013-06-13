//
//  MasterViewController.h
//  Swirl
//
//  Created by Alex Shaykevich on 19/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DirectoryWatcher.h"
@class DetailViewController;

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, DirectoryWatcherDelegate> {
    BOOL firstAppearance;
    BOOL markedForChange;
}

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property(strong, nonatomic) NSMutableArray* ebooks;

@end
