

#import <UIKit/UIKit.h>

@interface BrowserViewController : UIViewController<UIWebViewDelegate,
UIDocumentInteractionControllerDelegate>{
    IBOutlet UIWebView* _browser;
    IBOutlet UIProgressView* _progressView;

    NSTimer* _timer;
    BOOL theBool;
    UIWebView *wvPopUp;
    UIView *vwPopUpContainer;
    UIButton *btnClosePopup;
    UIButton *btnPrintPopup;
   
}

@end
