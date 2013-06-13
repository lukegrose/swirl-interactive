//
//  ChapterViewController.h
//  Swirl
//
//  Created by Alex Shaykevich on 23/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Ebook;
@class WordList;
@class Word;
@interface ChapterViewController : UIViewController<UIWebViewDelegate> {
    //int savedOffsetX;
    //int savedOffsetY;
    float savedOffsetX;
    float savedOffsetY;
    
    float mCurrentScale;
    float mLastScale;
    
    int textFontSize;
}

@property(nonatomic, strong) IBOutlet UIWebView* webView;
@property(copy) NSString* originalText;
@property(nonatomic, strong) Ebook* ebook;
@property(nonatomic, strong) WordList* wList;
@property int index;

@property(nonatomic, retain) Word* chosenWord;

@end
