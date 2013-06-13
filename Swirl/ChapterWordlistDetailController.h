//
//  ChapterWordlistDetailController.h
//  Swirl
//
//  Created by Alex Shaykevich on 10/11/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WordList;
@interface ChapterWordlistDetailController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) IBOutlet UITableView* tableView;
@property(nonatomic, retain) WordList* wList;
@property(nonatomic, retain) NSDictionary* dict;

@end
