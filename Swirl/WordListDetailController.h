//
//  WordListDetailController.h
//  Swirl
//
//  Created by Alex Shaykevich on 22/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WordList;
@interface WordListDetailController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property(nonatomic, retain) IBOutlet UITableView* tableView;
@property(nonatomic, retain) WordList* wList;

-(IBAction)reset;

@end
