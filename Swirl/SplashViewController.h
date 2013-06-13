//
//  WordListController.h
//  Swirl
//
//  Created by Alex Shaykevich on 22/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Ebook;
@interface SplashViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) IBOutlet UITableView* tableView;
@property(nonatomic, retain) Ebook* ebook;
@property(nonatomic, retain) NSMutableArray* wordLists;
@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end
