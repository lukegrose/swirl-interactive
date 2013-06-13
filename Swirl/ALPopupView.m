/***************************************************************
 //  ALPopupView.m
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

#import "ALPopupView.h"

#pragma mark -
#pragma mark Private Interface

@interface ALPopupView (Private)
- (void) firstStepStop;
- (void) secondStepStop;
- (void) showAnimationEnded;
- (void) postDismissCleanup;
- (void) dismiss:(BOOL)animated;
- (void) buildPopUp;
- (void) buildButtons;
- (void) localButtonPressed:(UIButton*) button;
- (void) contentTap;
@end

@implementation ALPopupView

@synthesize transitionDuration=_transitionDuration;
@synthesize borderWidth=_borderWidth;
@synthesize cornerRadius=_cornerRadius;
@synthesize borderAlpha=_borderAlpha;
@synthesize borderColor=_borderColor;
@synthesize outsideBackcolor=_outsideBackcolor;
@synthesize outsideAlpha=_outsideAlpha;
@synthesize closeOnTapOutside=_closeOnTapOutside;
@synthesize titleBarVisible=_titleBarVisible;
@synthesize titleBarBackColor=_titleBarBackColor;
@synthesize titleBarTextColor=_titleBarTextColor;
@synthesize titleBarFont=_titleBarFont;
@synthesize titleBarText=_titleBarText;
@synthesize titleBarHeight=_titleBarHeight;
@synthesize titleBarCloseButtonVisible=_titleBarCloseButtonVisible;
@synthesize delegate=_delegate;
@synthesize contentView=_contentView;
@synthesize titleBarView=_titleBarView;
@synthesize titleBarLabel=_titleBarLabel;
@synthesize buttonsViewVisible=_buttonsViewVisible;
@synthesize buttonsViewHeight=_buttonsViewHeight;
@synthesize buttonsViewBackColor=_buttonsViewBackColor;
@synthesize buttonHeight=_buttonHeight;
@synthesize buttonWidth=_buttonWidth;
@synthesize buttonsPadding = _buttonsPadding;
@synthesize buttonsAlignment = _buttonsAlignment;
@synthesize buttonFont=_buttonFont;
@synthesize buttonsTitleList=_buttonsTitleList;
@synthesize buttonsList=_buttonsList;
@synthesize buttonsView=_buttonsView;

#pragma mark -
#pragma mark Private Methods
///////////////////////////////////////////////////////////////////////////////////////////////////
// private

/*
 *  Called when the first of the animations ends
 */
- (void) firstStepStop {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:_transitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(secondStepStop)];
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
    [UIView commitAnimations];
}
/*
 *  Called when the second of the animatiosn ends
 */
- (void) secondStepStop {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:_transitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showAnimationEnded)];
    self.transform =CGAffineTransformIdentity;
    [UIView commitAnimations];
}
/*
 *  Called when the entire animation ends
 */
- (void) showAnimationEnded{
    if ([_delegate respondsToSelector:@selector(popupDidAppear:)])
        [_delegate popupDidAppear:self];
}
/*
 *  Called to remove all the popup components from the parent view and to notify the delegate with the 
 *  popupDidDisappear method
 */
- (void) postDismissCleanup {
    [self removeFromSuperview];
    [_outsideView removeFromSuperview];
    [_tapButton removeFromSuperview];
    
    if ([_delegate respondsToSelector:@selector(popupDidDisappear:)])
        [_delegate popupDidDisappear:self];
}
/*
 *  Called to start the hide animation if animation==YES. Otherwise, this method calls directly postDismissCleanup.
 */
- (void) dismiss:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:_transitionDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(postDismissCleanup)];
        self.alpha = 0;
        _outsideView.alpha=0;
        [UIView commitAnimations];
    } 
    else
        [self postDismissCleanup];
}
/*
 *  This method intercepts the taps on the view placed between the parent view and the popup view. 
 *  If _closeOnTapOutside property is set to YES, the popup will disappear
 */
- (void) contentTap{
    if ([_delegate respondsToSelector:@selector(popupDidTapOutside:)])
        [_delegate popupDidTapOutside:self];
    if (_closeOnTapOutside){
        [self hide];
    }
}
/*
 *  Builds every component's frame of the popup
 */
- (void) buildPopUp{
    self.alpha = 1;
    /************************************************************************************/
    //Build and add components to the window
    _border.backgroundColor=_borderColor;
    _border.alpha=_borderAlpha;
    _border.layer.cornerRadius=_cornerRadius;
    
    _outsideView.backgroundColor=_outsideBackcolor;
    _outsideView.frame=_parentView.bounds;
    _outsideView.alpha=_outsideAlpha;
    
    _tapButton.frame=_outsideView.frame;
    
    if (_titleBarVisible){
        _titleBarView.frame=CGRectMake(self.bounds.origin.x+_borderWidth, 
                                       self.bounds.origin.y+_borderWidth, 
                                       self.bounds.size.width-2*_borderWidth, 
                                       _titleBarHeight);
        _titleBarView.backgroundColor=_titleBarBackColor;
        
        
        _titleBarLabel.frame=_titleBarView.frame;
        _titleBarLabel.backgroundColor=[UIColor clearColor];
        _titleBarLabel.textAlignment=UITextAlignmentCenter;
        _titleBarLabel.text=_titleBarText;
        _titleBarLabel.textColor=_titleBarTextColor;
        _titleBarLabel.font=_titleBarFont;
        
    }
    else{
        _titleBarView.frame=CGRectZero;
        _titleBarLabel.frame=CGRectZero;
    }
    
    if (_titleBarVisible && _buttonsViewVisible)    
        _contentView.frame=CGRectMake(self.bounds.origin.x+_borderWidth, 
                                      self.bounds.origin.y+_borderWidth+_titleBarHeight, 
                                      self.bounds.size.width-2*_borderWidth, 
                                      self.bounds.size.height-2*_borderWidth-_titleBarHeight-_buttonsViewHeight);
    else if (_titleBarVisible && !_buttonsViewVisible)
        _contentView.frame=CGRectMake(self.bounds.origin.x+_borderWidth, 
                                      self.bounds.origin.y+_borderWidth+_titleBarHeight, 
                                      self.bounds.size.width-2*_borderWidth, 
                                      self.bounds.size.height-2*_borderWidth-_titleBarHeight);
    else if (!_titleBarVisible && _buttonsViewVisible)
        _contentView.frame=CGRectMake(self.bounds.origin.x+_borderWidth, 
                                      self.bounds.origin.y+_borderWidth, 
                                      self.bounds.size.width-2*_borderWidth, 
                                      self.bounds.size.height-2*_borderWidth-_buttonsViewHeight);
    else
        _contentView.frame=CGRectMake(self.bounds.origin.x+_borderWidth, 
                                      self.bounds.origin.y+_borderWidth, 
                                      self.bounds.size.width-2*_borderWidth, 
                                      self.bounds.size.height-2*_borderWidth);
    
    UIImage* closeImage = [UIImage imageNamed:@"close.png"];
    UIColor* color = [UIColor colorWithRed:167.0/255 green:184.0/255 blue:216.0/255 alpha:1];
    
    [_closeButton setImage:closeImage forState:UIControlStateNormal];
    [_closeButton setTitleColor:color forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(dismiss:)
           forControlEvents:UIControlEventTouchUpInside];
    // To be compatible with OS 2.x
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_2_2
    _closeButton.font = [UIFont boldSystemFontOfSize:12];
#else
    _closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
#endif
    
    if (_titleBarVisible)
        _closeButton.frame=CGRectMake(self.bounds.origin.x+self.bounds.size.width-(2*_borderWidth)-15,
                                      self.bounds.origin.y+_borderWidth+(_titleBarHeight-20)/2,
                                      20, 20);
    else
        _closeButton.frame=CGRectMake(self.bounds.origin.x+self.bounds.size.width-(2*_borderWidth)-15,
                                      self.bounds.origin.y+_borderWidth+10,
                                      20, 20);
    
    _closeButton.showsTouchWhenHighlighted = YES;
    _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    if (_buttonsViewVisible) {
        _buttonsView.frame=CGRectMake(self.bounds.origin.x+_borderWidth, 
                                      self.bounds.origin.y+_borderWidth+_titleBarHeight+_contentView.frame.size.height, 
                                      self.bounds.size.width-2*_borderWidth, 
                                      _buttonsViewHeight);
        _buttonsView.backgroundColor=_buttonsViewBackColor;
        [self buildButtons];
    }
    else
        _buttonsView.frame=CGRectZero;
    
    /************************************************************************************/
    [self bringSubviewToFront:_contentView];
    [self bringSubviewToFront:_closeButton];
    [_parentView bringSubviewToFront:self];
}
/*
 *  Builds the buttons of the buttonview, according to the setted properties (if values are defaults, there is an automatic calculation of sizes and margins of the buttons)
 */
- (void) buildButtons{
    for (int i=0;i<[_buttonsList count];i++)
        [(UIButton*)[_buttonsList objectAtIndex:i] removeFromSuperview];
    [_buttonsList removeAllObjects];
    
    if ([_buttonsTitleList count] == 0)
        return;
    
    float height;
    float width;
    float marginX=0;
    
    if (_buttonHeight == 0) {
        float tempHeight = (_buttonsViewHeight - (kButtonMinVMargin * 2));
        if (kButtonHeight<tempHeight)
            height = kButtonHeight;
        else
            height = tempHeight;
    }
    else
        height=_buttonHeight;
    
    //Calculation of buttons width
    if (_buttonWidth == 0) {
        float totalMaring = kButtonMinHMargin * ([_buttonsTitleList count]-1) + _buttonsPadding*2;
        float minWidth = (_buttonsView.frame.size.width - totalMaring )/[_buttonsTitleList count];
        if (kButtonWidth<minWidth)
            width = kButtonWidth;
        else
            width = minWidth;
    }
    else
        width=_buttonWidth;
    //Calculation of buttons horizontal margins to center the buttons
    marginX=(_buttonsView.frame.size.width - _buttonsPadding*2 - [_buttonsTitleList count] * width ) /  ([_buttonsTitleList count]+1);
    
    UIButton *btn;
    
    for (int i=0;i<[_buttonsTitleList count];i++) {
        btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag=i;
        if (_buttonsAlignment == ALPopupViewButtonsAlignmentCenter)
            btn.frame=CGRectMake(marginX*(i+1)+width*i+_buttonsPadding, (_buttonsView.frame.size.height-height)/2 , width, height);
        else if(_buttonsAlignment == ALPopupViewButtonsAlignmentLeft)
            btn.frame=CGRectMake(kButtonMinHMargin*i+width*i+_buttonsPadding, (_buttonsView.frame.size.height-height)/2 , width, height);
        else
            btn.frame=CGRectMake(_buttonsView.frame.size.width-(_buttonsPadding + ([_buttonsTitleList count]-(i+1) )*kButtonMinHMargin + width*([_buttonsTitleList count]-i) )  , (_buttonsView.frame.size.height-height)/2 , width, height);
        [btn setTitle:(NSString*)[_buttonsTitleList objectAtIndex:i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(localButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[[UIImage imageNamed:@"popupBtn.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
        [btn setTitleColor:_buttonTextColor forState:UIControlStateNormal];
        btn.titleLabel.font=_buttonFont;
        [btn.titleLabel adjustsFontSizeToFitWidth];
        [_buttonsList addObject:btn];
        [_buttonsView addSubview:btn];
    }
}
/*
 *  The event which intercepts a tap event on a button of the button view.
 *  It makes a call to delegate method, passing the index the tapped button (the order is: from left to right )
 */
- (void) localButtonPressed:(UIButton*) button{
    if ([_delegate respondsToSelector:@selector(popup:didSelectButtonAtIndex:)])
        [_delegate popup:self didSelectButtonAtIndex:button.tag];
}
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Override Methods
- (id)initWithFrame:(CGRect)frame withParentView:(UIView*) parent
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _borderWidth=kBorderWidth;
        _cornerRadius=kCornerRadius;
        
        _borderAlpha=kBorderAlpha;
        _borderColor=[kBorderColor retain];

        _outsideBackcolor=[[UIColor clearColor] retain];
        _outsideAlpha=1;
        _closeOnTapOutside=NO;
        
        _titleBarVisible=YES;
        _titleBarText=[[NSString alloc] initWithString:kTitleBarText];
        
        self.backgroundColor=[UIColor clearColor];
        
        _parentView=parent;
        
        _titleBarHeight=ceilf( (self.frame.size.height-2*_borderWidth) * 0.072 );    
        _titleBarBackColor=[[UIColor colorWithWhite:0.192 alpha:1.000] retain];
        _titleBarTextColor=[kTitleBarTextColor retain];
        _titleBarFont=[[UIFont boldSystemFontOfSize:12] retain];
        
        _border=[[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_border];
                
        _titleBarView=[[UIView alloc] init];
        [self addSubview:_titleBarView];
        
        _titleBarLabel=[[UILabel alloc] init];
        [self addSubview:_titleBarLabel];   
        
        
        _contentView=[[UIView alloc] init];
        _contentView.backgroundColor=[UIColor colorWithWhite:0.918 alpha:1.000];
        [self addSubview:_contentView];
        
        _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [self addSubview:_closeButton];
        
        _buttonsViewVisible=NO;
        _buttonsViewHeight=ceilf( (self.frame.size.height-2*_borderWidth) * 0.126 );
            
        _buttonHeight=0;
        _buttonWidth=0;
        _buttonsPadding=kButtonsPadding;
        _buttonsAlignment=ALPopupViewButtonsAlignmentCenter;
        
        _buttonFont=[[UIFont boldSystemFontOfSize:11] retain];
        _buttonTextColor=[[UIColor blackColor] retain];
        _buttonsViewBackColor=[[UIColor whiteColor] retain];
        _buttonsList=[[NSMutableArray alloc] init];
        _buttonsTitleList=[[NSMutableArray alloc] init];
        _buttonsView=[[UIView alloc] init];
        [self addSubview:_buttonsView];
        
        //Components to add in the parentView
        _outsideView=[[UIView alloc] init];
        _tapButton=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _tapButton.backgroundColor=[UIColor clearColor];
        [_tapButton addTarget:self action:@selector(contentTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
- (void)dealloc
{
    if (_border)
        [_border release];
    if(_closeButton)
        [_closeButton release];    
    if(_contentView)
        [_contentView release];
    if(_titleBarView)
        [_titleBarView release];
    if(_titleBarText)
        [_titleBarText release];
    if(_tapButton)
        [_tapButton release];
    if(_outsideView)
        [_outsideView release];
    if (_borderColor)
        [_borderColor release];
    if(_outsideBackcolor)
        [_outsideBackcolor release];
    if (_titleBarBackColor)
        [_titleBarBackColor release];
    if (_titleBarTextColor)
        [_titleBarTextColor release];
    if(_buttonFont)
        [_buttonFont release];
    if(_buttonsList)
        [_buttonsList release];
    if(_buttonsTitleList)
        [_buttonsTitleList release];
    if(_buttonsView)
        [_buttonsView release];
    if(_buttonsViewBackColor)
        [_buttonsViewBackColor release];
    if(_titleBarFont)
        [_titleBarFont release];
    if(_buttonTextColor)
        [_buttonTextColor release];
    if(_titleBarLabel)
        [_titleBarLabel release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(void) show{
    [self showWithAnimation:YES withDuration:kTransitionDuration];
}
-(void) hide{
    [self hideWithAnimation:YES withDuration:kTransitionDuration];
    [[NSNotificationCenter defaultCenter] postNotificationName:ALPOPUP_CLOSE object:nil];
}

-(void) showWithAnimation:(BOOL) animation withDuration:(float) duration{
    //if popup already added, don't show again
    if (self.superview) 
        return;
    
    if ([_delegate respondsToSelector:@selector(popupWillAppear:)])
        [_delegate popupWillAppear:self];
    
    _transitionDuration=duration;
    [self buildPopUp];
    
    //Add the external view (and relative button) which fill the parent view in the space outside the popup
    [_parentView addSubview:_outsideView];
    //[_parentView sendSubviewToBack:_outsideView];
    [_parentView addSubview:_tapButton];
    //Add the popup to the parentview
	[_parentView addSubview:self];
    
	self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:_transitionDuration/1.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(firstStepStop)];
	self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
	[UIView commitAnimations];
    
}
-(void) hideWithAnimation:(BOOL) animation withDuration:(float) duration{
    //if popup is hidden, don't hide again
    if (!self.superview) 
        return;
    _transitionDuration=duration;
    [self dismiss:animation];
    
}

-(void) buildLayout{
    if ([self superview]) {
        if ([_tapButton superview])
            [_tapButton removeFromSuperview];
        if ([_outsideView superview])
            [_outsideView removeFromSuperview];
    }
    [self buildPopUp];
}


@end
