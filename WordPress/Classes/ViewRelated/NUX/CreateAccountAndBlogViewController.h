#import <UIKit/UIKit.h>
#import "CreateAccountAndBlogViewController.h"
#import <EmailChecker/EmailChecker.h>
#import <QuartzCore/QuartzCore.h>
#import "SupportViewController.h"
#import "WordPressComApi.h"
#import "WPNUXBackButton.h"
#import "WPNUXMainButton.h"
#import "WPPostViewController.h"
#import "WPWalkthroughTextField.h"
#import "WPAsyncBlockOperation.h"
#import "WPComLanguages.h"
#import "WPWalkthroughOverlayView.h"
#import "SelectWPComLanguageViewController.h"
#import "WPNUXUtility.h"
#import "WPWebViewController.h"
#import "WPStyleGuide.h"
#import "WPFontManager.h"
#import "UILabel+SuggestSize.h"
#import "WPAccount.h"
#import "Blog.h"
#import "WordPressComOAuthClient.h"
#import "WordPressComServiceRemote.h"
#import "AccountService.h"
#import "BlogService.h"
#import "ContextManager.h"
#import "NSString+XMLExtensions.h"
#import "Constants.h"

extern CGFloat const CreateAccountAndBlogTextFieldWidth;

@interface CreateAccountAndBlogViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) WPNUXBackButton *backButton;
@property (nonatomic, strong) UIButton *helpButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *TOSLabel;
@property (nonatomic, strong) UILabel *siteAddressWPComLabel;
@property (nonatomic, strong) WPWalkthroughTextField *emailField;
@property (nonatomic, strong) WPWalkthroughTextField *usernameField;
@property (nonatomic, strong) WPWalkthroughTextField *passwordField;
@property (nonatomic, strong) UIButton *onePasswordButton;
@property (nonatomic, strong) WPNUXMainButton *createAccountButton;
@property (nonatomic, strong) WPWalkthroughTextField *siteAddressField;
    
@property (nonatomic, strong) NSOperationQueue *operationQueue;
    
@property (nonatomic, assign) BOOL authenticating;
@property (nonatomic, assign) BOOL keyboardVisible;
@property (nonatomic, assign) BOOL shouldCorrectEmail;
@property (nonatomic, assign) BOOL userDefinedSiteAddress;
@property (nonatomic, assign) CGFloat keyboardOffset;
@property (nonatomic, assign) NSString *defaultSiteUrl;
    
@property (nonatomic, strong) NSDictionary *currentLanguage;
    
@property (nonatomic, strong) WPAccount *account;

- (void)configurePasswordField:(CGFloat)x y:(CGFloat)y textFieldHeight:(CGFloat)textFieldHeight;
- (BOOL)isPasswordFilled;
- (BOOL)isUsernameUnderFiftyCharacters;
- (BOOL)isEmailedFilled;
- (void)createBlog;
- (void)actionNow;


@end
