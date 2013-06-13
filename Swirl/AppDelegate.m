//
//  AppDelegate.m
//  Swirl
//
//  Created by Alex Shaykevich on 19/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NSString+HTML.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Flurry.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[Flurry startSession:@"CX453NHVD2B446J3V8JZ"]; // Swirl Interactive
    //[Flurry startSession:@"ZBNNZ7Q3N7NF5RWG5SSH"]; // Swirl Interactive - PROD
    [Flurry logAllPageViews:_navigationController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    OSStatus err = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                           sizeof(sessionCategory),
                                           &sessionCategory);
    AudioSessionSetActive(TRUE);
    if (err) {
        NSLog(@"AudioSessionSetProperty kAudioSessionProperty_AudioCategory failed: %d", err);
    }
        
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController_iPhone" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        self.window.rootViewController = self.navigationController;
        masterViewController.managedObjectContext = self.managedObjectContext;
        
    } else {
        MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController_iPad" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        self.window.rootViewController = self.navigationController;
        masterViewController.managedObjectContext = self.managedObjectContext;
        /*
        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" bundle:nil];
        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    	
    	masterViewController.detailViewController = detailViewController;
        
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = detailViewController;
        self.splitViewController.viewControllers = @[masterNavigationController, detailNavigationController];
        self.window.rootViewController = self.splitViewController;
         
        masterViewController.managedObjectContext = self.managedObjectContext;
         */
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

+(NSManagedObjectContext*)globalManagedObjectContext {
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return app.managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Swirl" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[AppDelegate applicationLibraryDirectory] URLByAppendingPathComponent:@"Swirl.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
+(NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+(NSURL *)applicationLibraryDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

+(NSString *)getDocDirPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}


+(NSString *)getLibraryDirPath {
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES); // commented by lgrose
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); // modified by lgrose
    NSString *libraryDirectory = [paths objectAtIndex:0];
    return libraryDirectory;
}

+(NSString *)getEpubDirPath {
    
    NSString* path = [[AppDelegate getLibraryDirPath] stringByAppendingPathComponent:@"epub"];
    //NSLog(@"Swirl Epub Directory path [%@]", path);
    NSFileManager* fManager = [NSFileManager defaultManager];
    if([fManager fileExistsAtPath:path] == NO) {
		// need to create it
		BOOL success = [fManager createDirectoryAtPath:path attributes:nil];
	}

    return path;
}

+(NSString *)getWordlistDirPath {
    NSString* path = [[AppDelegate getLibraryDirPath] stringByAppendingPathComponent:@"wordlist"];
    //NSLog(@"Swirl Wordlist Directory path [%@]", path);
    NSFileManager* fManager = [NSFileManager defaultManager];
    if([fManager fileExistsAtPath:path] == NO) {
		// need to create it
		BOOL success = [fManager createDirectoryAtPath:path attributes:nil];
	}
    
    return path;
}

// http://www.tech-recipes.com/rx/3418/cocoa-explode-break-nsstring-into-individual-words/
+(NSArray*)htmlToWords:(NSString*)html {
    NSString* cleanString = [AppDelegate stringByStrippingHTML:html];
    NSMutableCharacterSet *separators = [NSMutableCharacterSet punctuationCharacterSet];
    [separators formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return [cleanString componentsSeparatedByCharactersInSet:separators];
}

+(NSString *) stringByStrippingHTML:(NSString*)string {
    return [string stringByConvertingHTMLToPlainText];
    
}

+(NSString*)findFile:(NSString*)fileName inDir:(NSString*)dir {
    // Enumerators are recursive
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:dir];
    
    NSString *filePath;
    while ((filePath = [enumerator nextObject]) != nil) {
        NSString* lastPath = [[filePath lastPathComponent] lowercaseString];
        if([lastPath isEqualToString:[fileName lowercaseString]]) {
            return [dir stringByAppendingPathComponent:filePath];
        }
    }
    
    return nil;
}

+(NSString*)getAudioPathForWord:(NSString*)word dir:(NSString*)dir {
    NSArray* exts = [NSArray arrayWithObjects:@"mp3",@"m4a",@"wav",@"caf",@"aac", nil];
    for(NSString* ext in exts) {
        NSString* testPath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", word, ext]];
        if([[NSFileManager defaultManager] fileExistsAtPath:testPath]) {
            return testPath;
        }
    }
    
    return nil;
}


@end
