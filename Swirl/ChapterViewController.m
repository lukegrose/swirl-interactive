//
//  ChapterViewController.m
//  Swirl
//
//  Created by Alex Shaykevich on 23/10/12.
//  Copyright (c) 2012 Alex Shaykevich. All rights reserved.
//

#import "ChapterViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "Ebook.h"
#import "Chapter.h"
#import "WordList.h"
#import "Word.h"
#import "KGModal.h"
#import "WordTestParentController.h"
#import "WordTestController.h"
#import "ALPopupView.h"
#import "Flurry.h"
#import "HTMLNode.h"
#import "HTMLParser.h"

@interface ChapterViewController ()
-(void)showProgress;
-(void)hideProgress;
-(NSString*)processText;
-(void)reprocessText;
-(NSString*)parseText;
//-(NSString*)recurseText:(HTMLParser*)parser forNode:(HTMLNode*)node andContent:(NSString*)content ;
-(NSString*)recurseText;


@property(nonatomic, strong) NSMutableDictionary* wordMap;
@property(nonatomic, strong) UINavigationController* testController;
@end

@implementation ChapterViewController
@synthesize webView;
@synthesize originalText;
@synthesize ebook;
@synthesize wList;
@synthesize index;
@synthesize wordMap;
@synthesize chosenWord;
@synthesize testController;

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
    [self showProgress];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString* baseDir = [[AppDelegate getEpubDirPath] stringByAppendingPathComponent:ebook.basePath];
        Chapter* chapter = [ebook.chapters objectAtIndex:index];
        
        NSDictionary *eventParams =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"Wordlist", chapter.title,
         nil];
        
        [Flurry logEvent:@"ENTER_CHAPTER" withParameters:eventParams timed:YES];
        
        NSString* chapterPath = [AppDelegate findFile:chapter.path inDir:baseDir];
        if(chapterPath) {
            self.originalText = [NSString stringWithContentsOfFile:chapterPath encoding:NSUTF8StringEncoding error:nil];
            
            NSString* newText = [self processText];
            //[self parseText];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSString* chapterBase = [chapterPath stringByDeletingLastPathComponent];
                NSURL* url = [NSURL fileURLWithPath:chapterBase];
                
                [self.webView loadHTMLString:newText baseURL:url];
                
                /*
                [self.webView loadData:[newText dataUsingEncoding:NSUTF8StringEncoding]
                         MIMEType:@"text/html"
                 textEncodingName:@"UTF-8"
                          baseURL:url];
                 */
                [self hideProgress];
            });
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.webView loadHTMLString:@"<b>Content not found.</b>" baseURL:nil];
                [self hideProgress];
            });
        }
    });
    
}

-(void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:YES];
    [Flurry endTimedEvent:@"ENTER_CHAPTER" withParameters:Nil];
    
}

-(void)reprocessText {
    [self showProgress];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSString* newText = [self processText];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString* baseDir = [[AppDelegate getEpubDirPath] stringByAppendingPathComponent:ebook.basePath];
            Chapter* chapter = [ebook.chapters objectAtIndex:index];
            NSString* chapterPath = [AppDelegate findFile:chapter.path inDir:baseDir];
            
            NSString* chapterBase = [chapterPath stringByDeletingLastPathComponent];
            NSURL* url = [NSURL fileURLWithPath:chapterBase];
            
            // save the offsets so we return to the same position later
            CGPoint offset = self.webView.scrollView.contentOffset;
            NSLog(@"Offset in dispatch_sync is x = %f, y = %f", offset.x, offset.y);
            savedOffsetX = offset.x;
            savedOffsetY = offset.y;
            self.webView.hidden = YES;
            [self.webView loadHTMLString:newText baseURL:url];
            [self hideProgress];
        });
    });
    CGPoint offset = self.webView.scrollView.contentOffset;
    NSLog(@"Offset in reprocessText is x = %f, y = %f", offset.x, offset.y);
    savedOffsetX = offset.x;
    savedOffsetY = offset.y;
}

-(NSString*)processText {
    
    NSString* newText = originalText;
    for(Word* _word in wList.words) {
        
        NSString* word = _word.word;
        NSString* findTemplate = [NSString stringWithFormat:@"\\b%@\\b", word];
        //NSString* replaceTemplate = [NSString stringWithFormat:@"<a href=\"%@\" style='color:#ff0000'>%@</a>", word, word];
        
        NSString* color = [_word complete] ? @"#0000ff" : @"#ff0000"; //blue : red
        NSString* replaceTemplate = [NSString stringWithFormat:@"<a href=\"$0\" style='text-decoration:none;color:%@'>$0</a>", color];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:findTemplate options:NSRegularExpressionCaseInsensitive error:nil];
        
        @try {
            newText = [regex stringByReplacingMatchesInString:newText options:0 range:NSMakeRange(0, [newText length]) withTemplate:replaceTemplate];
        }
        @catch (NSException *exception) {
            //...
        }
        @finally {
            //...
        }
    }
    
    //NSLog(@"FROM PROCESS TEXT [%@]", newText);

    return newText;
}

- (NSString *) parseText {
    
    NSLog(@"Implement text parsing here to appease cthulhu");
    
    NSString* newText = originalText;
    NSError* error = nil;
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString:newText error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSString *finalResult = [self recurseText:parser forNode:bodyNode currentNodeText:nil];
    
    NSLog(@"FROM Parse TEXT [%@]", finalResult);
    
    //NSArray *iNodes = [bodyNode findChildTags:@"i"];
    
    //for (HTMLNode *iNode in iNodes) {
       // NSLog(@"rawContents %@", [iNode rawContents]);
       // NSLog(@"contents %@", [iNode contents]);
    //}
    
    NSString *content = [bodyNode contents];
    //NSLog(@"%@", content);
    
    
    
    return @"";
    
}

- (NSString*) recurseText:(HTMLParser*)parser forNode:(HTMLNode*)node currentNodeText:(NSString*)currentNodeText {
    
    NSError* error = nil;
    
    if (parser == NULL) {
        parser = [[HTMLParser alloc] initWithString:originalText error:&error];
    }
    
    if (currentNodeText == NULL) {
        currentNodeText = @"";
    }
    
    if (error) {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    NSLog(@"*************************");
    NSLog(@"tagName [%@]", [node tagName]);
    NSLog(@"rawContents [%@]", [node rawContents]);
    NSLog(@"contents [%@]", [node contents]);
    NSLog(@"allContents [%@]", [node allContents]);
    NSLog(@"currentNodeText [%@]", currentNodeText);
    //NSLog(@"element ONLY??? [%@]", [node setValue:node forKey:currentNodeText]);
    //[node setValue:node forKey:currentNodeText];
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^");
    
    if ( [[node children] count] > 0 ) {
        
        for (HTMLNode *child in [node children]) {
            
            currentNodeText = [self recurseText:parser forNode:child currentNodeText:currentNodeText];
            //NSLog(@"currentNodeText [%@]", currentNodeText);
            
        }
        
    } else {
       
        if ( [@"text" isEqualToString:[node tagName]] ) {
            
            NSString *newText = [node rawContents];
            
            for(Word* _word in wList.words) {
                    
                NSString* word = _word.word;
                NSString* findTemplate = [NSString stringWithFormat:@"\\b%@\\b", word];
                    
                NSString* color = [_word complete] ? @"#9b30ff" : @"#ff1cae"; //purple : spicy ping
                NSString* replaceTemplate = [NSString stringWithFormat:@"<a href=\"$0\" style='text-decoration:none;color:%@'>$0</a>", color];
                    
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:findTemplate options:NSRegularExpressionCaseInsensitive error:nil];
                    
                @try {
                        
                    newText = [regex stringByReplacingMatchesInString:newText options:0 range:NSMakeRange(0, [newText length]) withTemplate:replaceTemplate];
                        
                }
                @catch (NSException *exception) {
                    //...
                }
                @finally {
                    //...
                }
            }
            
            //NSLog(@"newText [%@]", newText);
            
            return [currentNodeText stringByAppendingString:newText];
            
        } else {
            
            return [currentNodeText stringByAppendingString:[node rawContents]];
            
        }
    }
    
    return currentNodeText;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    savedOffsetX = -1;
    savedOffsetY = -1;
    self.webView.delegate = self;
    Chapter* chapter = [self.ebook.chapters objectAtIndex:index];
    
    //modified by lgrose, 201302230541
    //self.title = chapter.title;
    self.title = self.ebook.title;
    
    //added by lgrose, 201302200500
    //UIBarButtonItem* resetButton = [[UIBarButtonItem alloc]	initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target:self action:@selector(doneEditingAction)];
    //self.navigationController.navigationBar.topItem.rightBarButtonItem = resetButton;
    //self.navigationItem.rightBarButtonItem = resetButton;
    //end lgrose
    
    
    
    // we'll need this later to react to hyperlinks
    self.wordMap = [NSMutableDictionary dictionary];
    for(Word* word in wList.words) {
        [wordMap setObject:word forKey:word.word];
    }
    
    // set up the swipes
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightAction)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    //swipeRight.delegate = self;
    [self.webView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionRight;
    //swipeLeft.delegate = self;
    [self.webView addGestureRecognizer:swipeLeft];
    
    UIPinchGestureRecognizer* pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self.webView addGestureRecognizer:pinch];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modalClosed) name:ALPOPUP_CLOSE object:nil];
    
    textFontSize = 100;
    NSString* key = [NSString stringWithFormat:@"textsize_%@", ebook.basePath];
    NSNumber* n = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if(n != nil) {
        textFontSize = [n intValue];
    }
    
    
}


-(void)pinchAction:(UIPinchGestureRecognizer*)sender {
    float currentScale = mCurrentScale + [sender scale] - mLastScale;
    if(currentScale > mCurrentScale) {
        textFontSize = (textFontSize < 180) ? textFontSize +2 : textFontSize;
    } else if(currentScale < mCurrentScale) {
        textFontSize = (textFontSize > 80) ? textFontSize -2 : textFontSize;
    }
    
    mCurrentScale = currentScale;
    mLastScale = [sender scale];
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        mLastScale = 1.0;
    }
    
    [self adjustFontSize:textFontSize];
    
    NSString* key = [NSString stringWithFormat:@"textsize_%@", ebook.basePath];
    NSNumber* n = [NSNumber numberWithInt:textFontSize];
    [[NSUserDefaults standardUserDefaults] setObject:n forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



-(void)adjustFontSize:(int)fontSize {
    //NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.fontSize = '%i'", fontSize];
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", fontSize];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

-(void)swipeRightAction {
    int newIndex = index + 1;
    if(newIndex < [self.ebook.chapters count]) {
        // can advance to next one
        // open up the ebook with this wordlist
        ChapterViewController* cvc = [[ChapterViewController alloc] initWithNibName:nil bundle:nil];
        cvc.index = newIndex;
        cvc.ebook = ebook;
        cvc.wList = wList;
        [self.navigationController pushViewController:cvc animated:YES];
    }
}

-(void)swipeLeftAction {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)modalClosed {
    
    [Flurry endTimedEvent:@"ACTIVITY_MODAL_CLOSED" withParameters:Nil];
    
    if(self.chosenWord && self.chosenWord.dirty) {
        NSError* error;
        if([[AppDelegate globalManagedObjectContext] save:&error]) {
            self.chosenWord.dirty = NO;
            [self reprocessText];
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // what word did they click?
    NSURL* url = request.mainDocumentURL;
    NSString* target = [[url lastPathComponent] lowercaseString];
    
    // it's possible that this is a link to a different chapter, so
    // need to take a look
    NSString* lastPath = [target lastPathComponent];
    NSArray* parts = [[url relativeString] componentsSeparatedByString:@"#"];
    NSString* anchor = nil;
    if([parts count] > 1) {
        anchor = [parts objectAtIndex:1];
    }
    
    for(Chapter* ch in ebook.chapters) {
        NSString* chPath = ch.path;
        NSString* chAnchor = ch.anchor;
        
        if(anchor != nil && [ch.path isEqualToString:lastPath] && [ch.anchor isEqualToString:anchor]) {
            
            // need to load this one
            int newIndex = [ebook.chapters indexOfObject:ch];
            ChapterViewController* cvc = [[ChapterViewController alloc] initWithNibName:nil bundle:nil];
            cvc.index = newIndex;
            cvc.ebook = ebook;
            cvc.wList = wList;
            [self.navigationController pushViewController:cvc animated:YES];
            
            return YES;
        } else if(anchor == nil && [ch.path isEqualToString:lastPath] && ch.anchor == nil) {
            
            int newIndex = [ebook.chapters indexOfObject:ch];
            ChapterViewController* cvc = [[ChapterViewController alloc] initWithNibName:nil bundle:nil];
            cvc.index = newIndex;
            cvc.ebook = ebook;
            cvc.wList = wList;
            [self.navigationController pushViewController:cvc animated:YES];
            
            return YES;
        } else if([ch.path isEqualToString:lastPath]) {
            return NO;
        }
    }
    
    Word* word = [self.wordMap objectForKey:target];
    if(word == nil) {
        return YES;
    }
    self.chosenWord = word;
    
    //WordTestParentController* wtp = [[WordTestParentController alloc] initWithNibName:nil bundle:nil];
    //wtp.wList = wList;
    //wtp.word = word;
    WordTestController* wtc = [[WordTestController alloc] initWithNibName:nil bundle:nil];
    wtc.wList = wList;
    wtc.word = word;
    self.testController = [[UINavigationController alloc] initWithRootViewController:wtc];
    testController.view.frame = wtc.view.frame;
    
    /*
    [wtc viewWillAppear:YES];
    [[KGModal sharedInstance] setShowCloseButton:YES];
    [[KGModal sharedInstance] showWithContentView:testController.view andAnimated:YES];
    [wtc viewDidAppear:YES];
    */
    
    float x = (self.view.frame.size.width - (testController.view.frame.size.width + 10.))/2.;
    float y = (self.view.frame.size.height - (testController.view.frame.size.height + 10.))/2.;
    
    ALPopupView* settingsPopup =
        [[ALPopupView alloc] initWithFrame:CGRectMake(x, y, testController.view.frame.size.width + 10, testController.view.frame.size.height + 10) withParentView:self.view];
    
    [settingsPopup.contentView clipsToBounds];
    settingsPopup.borderWidth=5;
    settingsPopup.cornerRadius=5;
    settingsPopup.closeOnTapOutside=YES;
    settingsPopup.titleBarVisible=NO;
    settingsPopup.titleBarText = @"Settings";
    //settingsPopup.borderColor=[UIColor clearColor];
    settingsPopup.borderAlpha=0.8;
    settingsPopup.outsideBackcolor=[UIColor blackColor];
    settingsPopup.outsideAlpha=0.5;
    settingsPopup.buttonsViewVisible=NO;
    settingsPopup.buttonsViewBackColor=[UIColor blackColor];
    settingsPopup.titleBarCloseButtonVisible = NO;
    [settingsPopup buildLayout];
    
    [settingsPopup.contentView addSubview:testController.view];
    [settingsPopup buildLayout];
	[settingsPopup show];
    
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {    
    //[self adjustFontSize:textFontSize];
    
    // This seems to do the trick, let everything finish
    // loading
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        
        [NSThread sleepForTimeInterval:.1];
        [self adjustFontSize:textFontSize];
        
        // jump to the correct anchor
        Chapter* chapter = [ebook.chapters objectAtIndex:index];
        NSString* anchor = chapter.anchor;
        if(anchor != nil) {
            NSString* js = [NSString stringWithFormat:@"document.getElementById('%@').scrollIntoView(true)", anchor];
            [self.webView stringByEvaluatingJavaScriptFromString:js];
        }
        
        self.webView.hidden = NO;
    
        if(savedOffsetY > 0) {
           [self.webView.scrollView setContentOffset:CGPointMake(savedOffsetX, savedOffsetY)];
        }
    
    });
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

// http://stackoverflow.com/questions/2890673/iphone-uiwebview-width-does-not-fit-after-zooming-operation-uiinterfaceorienta
// https://gist.github.com/834907
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGFloat ratioAspect = self.webView.bounds.size.width/self.webView.bounds.size.height;
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
            // Going to Portrait mode
            for (UIScrollView *scroll in [self.webView subviews]) { //we get the scrollview
                // Make sure it really is a scroll view and reset the zoom scale.
                if ([scroll respondsToSelector:@selector(setZoomScale:)]){
                    scroll.minimumZoomScale = scroll.minimumZoomScale/ratioAspect;
                    scroll.maximumZoomScale = scroll.maximumZoomScale/ratioAspect;
                    [scroll setZoomScale:(scroll.zoomScale/ratioAspect) animated:YES];
                }
            }
            break;
        default:
            // Going to Landscape mode
            for (UIScrollView *scroll in [self.webView subviews]) { //we get the scrollview
                // Make sure it really is a scroll view and reset the zoom scale.
                if ([scroll respondsToSelector:@selector(setZoomScale:)]){
                    scroll.minimumZoomScale = scroll.minimumZoomScale *ratioAspect;
                    scroll.maximumZoomScale = scroll.maximumZoomScale *ratioAspect;
                    [scroll setZoomScale:(scroll.zoomScale*ratioAspect) animated:YES];
                }
            }
            break;
    }
}

@end
