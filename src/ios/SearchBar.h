#import <Cordova/CDVPlugin.h>

@interface SearchBar : CDVPlugin <UISearchBarDelegate> {
    CGRect defaultWebViewFrame; // Original frame taken up by WebView
}

@property (nonatomic, strong) UISearchBar *nativeSearchBar;

@end
