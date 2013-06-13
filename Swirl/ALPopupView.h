/***************************************************************
 //  ALPopupView.h
 //  ALPopupViewDemo
 //
 //  This software is provided AS IS. 
 //  AnguriaLab grants you the right to use and modify this 
 //  code for commercial use as part of your software.
 //
 //  Any distribution of this source code or of any library 
 //  containing this source code is strictly prohibited.
 //
 //  For any support, contact us at support@mobilebricks.com
 //
 //  Looking for another component or piece of code? We can help! 
 //  Get in touch at http://www.mobilebricks.com 
 //
 //  Copyright 2011 AnguriaLab LLC. All rights reserved.
 ****************************************************************/

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define ALPOPUP_CLOSE @"kgmodalclose"

#define kTransitionDuration     0.3
#define kTitleBarText           @"Title"
#define kBorderWidth            8
#define kCornerRadius           10
#define kBorderAlpha            0.5
#define kBorderColor            [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8]
#define kTitleBarTextColor      [UIColor colorWithRed:0.922 green:0.933 blue:0.961 alpha:1]
#define kButtonHeight           36
#define kButtonWidth            105
#define kButtonMinVMargin       5
#define kButtonMinHMargin       5
#define kButtonsPadding         10

typedef enum {
    ALPopupViewButtonsAlignmentLeft,
    ALPopupViewButtonsAlignmentRight,
    ALPopupViewButtonsAlignmentCenter
} ButtonAlignment;

@protocol ALPopupViewDelegate;

/**
 * @mainpage
 *
 * ALPopupView is a very flexible and customizable popup view.
 * 
 * It is composed by a titleBar with a default button used to close the popup, a fully customizable content view and
 * an optional buttons bar at the bottom.
 *
 * It can be wrapped within a border with custom width, radius and color.
 *
 * The user can close it automatically just tapping outside and a delegate will be notified when a button is pressed.
 *
 * Also, the duration of transition can be selected.
 */

@interface ALPopupView : UIView {
    float _transitionDuration;
    
    int _borderWidth;
    int _cornerRadius;
    float _borderAlpha;
    UIColor *_borderColor;
    
    UIColor *_outsideBackcolor;
    float _outsideAlpha;
    BOOL _closeOnTapOutside;
    
    UIView *_titleBarView;
    UIColor *_titleBarBackColor;
    UILabel *_titleBarLabel;
    NSString *_titleBarText;
    UIColor *_titleBarTextColor;
    UIFont *_titleBarFont;
    float _titleBarHeight;
    BOOL _titleBarCloseButtonVisible;
    BOOL _titleBarVisible;
    
    BOOL _buttonsViewVisible;
    UIView* _buttonsView;                
    float _buttonsViewHeight;           
    float _buttonHeight;               
    float _buttonWidth;
    float _buttonsPadding;
    ButtonAlignment _buttonsAlignment;
    UIColor *_buttonsViewBackColor;    
    UIFont* _buttonFont;               
    UIColor *_buttonTextColor;         
    NSMutableArray *_buttonsTitleList; 
    NSMutableArray *_buttonsList;      
    
    
    UIButton *_closeButton;
    
    UIView *_border;           
    UIView *_outsideView;      
    UIButton *_tapButton;      
    
    UIView *_parentView;       
      
    
    UIView *_contentView;      
         
      
    
    id<ALPopupViewDelegate> _delegate;
}

#pragma mark -
#pragma mark Properties

/**
 *  The length of the show and hide animation (default 0.3)
 */
@property(nonatomic) float transitionDuration;
/**
 *  The width of the external border of the popup (default 8)
 */
@property(nonatomic) int borderWidth;
/**
 *  The corners radius of the external border (default 10)
 */
@property(nonatomic) int cornerRadius;
/**
 *  Alpha value of the border (default = 0.5)
 */
@property(nonatomic) float borderAlpha;
/**
 *  The border color (default [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8] )
 */
@property(nonatomic,retain) UIColor *borderColor;
/**
 *  When the popup is displayed, a view is added between the superView and the popup.
 *  It's possible to set the background color of this view (default [UIColor clearColor] )
 */
@property(nonatomic,retain) UIColor *outsideBackcolor;
/**
 *  The alpha value of the outsite view (default 1.0)
 */
@property(nonatomic) float outsideAlpha;
/**
 *  If YES, the popup will close when the user tap outside of it (default NO)
 */
@property(nonatomic) BOOL closeOnTapOutside;
/**
 *  A read only reference of the title view situated on the top of the popup
 */
@property(nonatomic,readonly) UIView *titleBarView;
/**
 *  The background color of the title bar (default [UIColor colorWithWhite:0.192 alpha:1.000])
 */
@property(nonatomic,retain) UIColor *titleBarBackColor;
/**
 *  If the title view is displayed, a label is added to the title view 
 *  (default: its frame is the same of title bar view frame)
 */
@property(nonatomic,readonly) UILabel *titleBarLabel;
/**
 *  The text displayed in the title bar (default @"Title")
 */
@property(nonatomic,retain) NSString *titleBarText;
/**
 *  The text color of the title bar (default [UIColor colorWithRed:0.922 green:0.933 blue:0.961 alpha:1])
 */
@property(nonatomic,retain) UIColor *titleBarTextColor;
/**
 *  The font of the title bar (default [UIFont boldSystemFontOfSize:12])
 */
@property(nonatomic,retain) UIFont *titleBarFont;
/**
 *  It's possibile to set a custom height for title bar view (default height is 7% of the entire popup (boreder excluded) )
 */
@property(nonatomic) float titleBarHeight;
/**
 *  If YES, the title view will show its default close button
 */
@property(nonatomic) BOOL titleBarCloseButtonVisible;
/**
 *  If YES, the title bar is showed (default YES)
 */
@property(nonatomic) BOOL titleBarVisible;
/**
 *  A read only reference of the buttons view on the bottom of the popup
 */
@property(nonatomic,readonly) UIView *buttonsView;
/**
 *  It's possibile to set a custom height for buttons view (default height is 12% of the entire popup (border excluded) )
 */
@property(nonatomic) float buttonsViewHeight;
/**
 *  The background color of the buttons view (default [UIColor whiteColor])
 */
@property(nonatomic,retain) UIColor *buttonsViewBackColor;
/**
 *  The height of a single button added to the buttons view (default 36)
 */
@property(nonatomic) float buttonHeight;
/**
 *  The width of a single button added to the buttons view (default 105)
 */
@property(nonatomic) float buttonWidth;
/**
 *  The pixel distance between the buttons and the internal border of popup
 */
@property(nonatomic) float buttonsPadding;
/**
 *  The alignment of the buttons inside the button view.
 *  Possible values: ALPopupViewButtonsAlignmentLeft, ALPopupViewButtonsAlignmentRight,
 *  ALPopupViewButtonsAlignmentCenter (default)
 */
@property(nonatomic) ButtonAlignment buttonsAlignment;
/**
 *  The font of a single button added to the buttons view (default [UIFont boldSystemFontOfSize:11])
 */
@property(nonatomic,retain) UIFont* buttonFont;
/**
 *  This is an NSArray* o NSString* . The user can set this array of strings and for each string added, a button 
 *  will be shown inside the buttons view. The buttons are added in the same order of 
 *  the strings inside this array
 */
@property(nonatomic,retain) NSMutableArray* buttonsTitleList;
/**
 *  This is a reference of the buttons added inside the button view. If you want to customize every single button,
 *  you can retrieve each ref from this array
 */
@property(nonatomic,readonly) NSMutableArray* buttonsList;
/**
 *  If YES, the buttons bar is showed (default NO)
 */
@property(nonatomic) BOOL buttonsViewVisible;
/**
 *  A read only reference of the content view. The content view, is the entire view inside the popup, excluding
 *  borders, title view and buttons view
 */
@property(nonatomic,readonly) UIView *contentView;
/**
 *  The delegate that will receive the events of this component
 */
@property(nonatomic,assign) id<ALPopupViewDelegate> delegate;

#pragma mark -
#pragma mark Public Methods

/**
 *  Init the popup view.
 *
 *  @param[in]  frame   is the entire frame of the popup (borders included)
 *  @param[in]  parent  is the superView in which this popup will be added
 */
-(id) initWithFrame:(CGRect)frame withParentView:(UIView*) parent;
/**
 *  This method shows the popup with the setted animation duration (default 0.3 seconds)
 */
-(void) show;
/**
 *  This method hides the popup with the setted animation duration (default 0.3 seconds)
 */
-(void) hide;
/**
 *  Show the popup.
 *  @param[in]  animation   if YES, the popup is showed with the animation
 *  @param[in]  duration    if animation is YES, this parameter sets the animation duration (in seconds)
 */
-(void) showWithAnimation:(BOOL) animation withDuration:(float) duration;
/**
 *  Hide the popup.
 *  @param[in]  animation   if YES, the popup is hided with the animation
 *  @param[in]  duration    if animation is YES, this parameter sets the animation duration (in seconds)
 */
-(void) hideWithAnimation:(BOOL) animation withDuration:(float) duration; 
/**
 *  This methos must be called each time you finish customizing the popup attributes.
 *  Every time you make a change (colors - font - seizes - change screen orientation - etc ..) 
 *  you need to call this method to reload the popup layout before showing
 */
-(void) buildLayout; 

@end

#pragma mark -
#pragma mark Protocol

@protocol ALPopupViewDelegate<NSObject>
@optional
/**
 *  Raised when the user tap outside the content view
 *  @param[in]  popup   reference of the popup which sends the event
 */
-(void) popupDidTapOutside:(ALPopupView*) popup;
/**
 *  Raised after the popup appears on screen, and after the animation completes
 *  @param[in]  popup   reference of the popup which sends the event
 */
-(void) popupDidAppear:(ALPopupView*) popup; 
/**
 *  Raised after the popup disappears from screen, and after the animation completes
 *  @param[in]  popup   reference of the popup which sends the event
 */
-(void) popupDidDisappear:(ALPopupView*) popup;
/**
 *  Raised before the popup appears on the screen
 *  @param[in]  popup   reference of the popup which sends the event
 */
-(void) popupWillAppear:(ALPopupView*) popup; 
/**
 *  Raised when the button with index 'buttonIndex' was pressed
 *  @param[in]  popup   reference of the popup which sends the event
 */
-(void) popup:(ALPopupView*) popup didSelectButtonAtIndex:(int) buttonIndex; 
@end
