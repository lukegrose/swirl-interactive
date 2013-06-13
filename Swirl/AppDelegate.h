//
//  AppDelegate.h
//  Swirl
//
//  Created by Alex Shaykevich on 19/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
+(NSURL *)applicationDocumentsDirectory;
+(NSURL *)applicationLibraryDirectory;
+(NSManagedObjectContext*)globalManagedObjectContext;
+(NSString *)getLibraryDirPath;
+(NSString *)getDocDirPath;
+(NSString *)getEpubDirPath;
+(NSString *)getWordlistDirPath;
+(NSArray*)htmlToWords:(NSString*)html;
+(NSString *) stringByStrippingHTML:(NSString*)string;
+(NSString*)findFile:(NSString*)fileName inDir:(NSString*)dir;
+(NSString*)getAudioPathForWord:(NSString*)word dir:(NSString*)dir;


@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UISplitViewController *splitViewController;


@end
