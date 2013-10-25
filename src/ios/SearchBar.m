#import "SearchBar.h"

@implementation SearchBar

@synthesize nativeSearchBar;

#pragma mark - Constants

/* Duration of slide animations. */
static double const ANIMATION_DURATION = 0.4;

/* Determines if Cordova WebView should "shrink" underneith the SearchBar.
 * Set to NO to overlay SearchBar atop the WebView. */
static BOOL const RESIZE_WEBVIEW = YES;

/* Determines if we should offset the top of the view when device is at or above iOS7.
 * This will allow the status bar to properly display. Set to NO to use fullscreen. */
static BOOL const OFFSET_IOS7 = YES;

/* Determines if user is allowed to hit the "Search" button if they have NOT entered data.
 * Set to NO to ensure user has entered at least one character before search. */
static BOOL const ALLOW_EMPTY_SEARCH = YES;

# pragma mark - Initialization

-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView {
    isShowing = false;
    return (SearchBar*)[super initWithWebView:theWebView];
}

-(void)setupSearchBar:(CDVInvokedUrlCommand *)command {
    float barHeight = 44.0; // 44.0 is the standard height in px for iOS UISearchBar.
    // Setting y-offset to -height since we will be sliding-in the view.
    nativeSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, -barHeight, self.webView.superview.bounds.size.width, barHeight)];
    nativeSearchBar.delegate = self;
    
    if (ALLOW_EMPTY_SEARCH) {
        [self enableEmptySearch];
    }
}
    
-(void)enableEmptySearch {
    UITextField* searchField = [self getTextField];
    if (searchField) {
        searchField.enablesReturnKeyAutomatically = NO;
    }
}
    


# pragma mark - Bridge Methods

-(void)show:(CDVInvokedUrlCommand *)command {
    if (isShowing) {
        return;
    }
    
    if (nativeSearchBar == nil) {
        [self setupSearchBar:nil];
    }
    
    isShowing = true;
    [self.webView.superview addSubview:nativeSearchBar];
    [self slideDown];
}

-(void)hide:(CDVInvokedUrlCommand *)command {
    if (!isShowing || nativeSearchBar == nil) {
        return;
    }

    isShowing = false;
    [nativeSearchBar resignFirstResponder];
    [self slideUp];
}

#pragma mark - Helper Methods

/* Slides the SearchBar into view from the top. Assumes SearchBar is already part of the drawn view. */
-(void)slideDown {
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^ {
                         [nativeSearchBar setFrame:CGRectOffset([nativeSearchBar frame], 0,
                                                                nativeSearchBar.frame.size.height + [self getOffset])];
                         if (RESIZE_WEBVIEW) [self shrinkWebView];
                     }];
}

/* Slides the SearchBar up and out of view. Removes the SearchBar from the superview after the animation. */
-(void)slideUp {
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^ {
                         [nativeSearchBar setFrame:CGRectOffset([nativeSearchBar frame], 0,
                                                                -(nativeSearchBar.frame.size.height + [self getOffset]))];
                         if (RESIZE_WEBVIEW) [self restoreWebView];
                     }
                     completion:^(BOOL finished) {
                         [nativeSearchBar removeFromSuperview];
                     }];
}

/* Adjusts the height of the WebView to account for the SearchBar. */
-(void)shrinkWebView {
    defaultWebViewFrame = self.webView.frame;
    
    CGRect newFrame = CGRectMake(defaultWebViewFrame.origin.x,
                                 nativeSearchBar.frame.size.height + [self getOffset],
                                 defaultWebViewFrame.size.width,
                                 defaultWebViewFrame.size.height - nativeSearchBar.frame.size.height);
    
    [self.webView setFrame:newFrame];
}

/* Restores the height of the WebView to its pre-SearchBar state. */
-(void)restoreWebView {
    [self.webView setFrame:defaultWebViewFrame];
}

/* Returns the y-axis offset needed for SearchBar based on OS version. */
-(CGFloat)getOffset {
    if (!OFFSET_IOS7) return 0.0;
    
    if ([self isiOS7]) {
        return 20.0; // Amount of offset required for versions at or above iOS 7.0
    }
    return 0.0;
}

    
// Returns YES if device is at or above iOS7.
-(BOOL)isiOS7 {
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
    if ([sysVersion compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        return YES;
    }
    return NO;
}

// Returns the UITextField associated with this search bar.
-(UITextField *)getTextField {
    if ([self isiOS7]) {
        // iOS7 requires iterating into an extra level of subviews.
        return [self getTextFieldiOS7];
    }
        
    for (UIView *subview in nativeSearchBar.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            return (UITextField *) subview;
        }
    }
    return nil;
}

// Returns the UITextField associated with this search bar. (iOS7+ devices)
-(UITextField *)getTextFieldiOS7 {
    for (UIView *subView in nativeSearchBar.subviews) {
        for (UIView *subSubView in subView.subviews) {
            if ([subSubView isKindOfClass:[UITextField class]]) {
                return (UITextField *) subSubView;
            }
        }
    }
    return nil;
}

#pragma mark - UISearchBar Delegate Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self writeJavascript:[NSString stringWithFormat:@"cordova.fireDocumentEvent('searchEvent', {text:'%@'})", searchBar.text]];
    [searchBar resignFirstResponder];
}

@end
