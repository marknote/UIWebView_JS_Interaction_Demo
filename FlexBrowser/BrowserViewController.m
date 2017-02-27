

#import "BrowserViewController.h"



@implementation BrowserViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    _browser.delegate = self;
    
   
    
    NSURL* baseURL = [NSURL URLWithString:@"https://marknote.github.io"];
    NSString *html = @"<html><script>function popup(){window.open('https://marknote.github.io/InstantCoder/InstantCoder.html')};</script><body><a href='javascript:popup();'>Loaded</a></body></html>";
    [_browser loadHTMLString:html baseURL:baseURL ];
    
}


-(void) webViewDidFinishLoad:(UIWebView*)webView {
    // this is a pop-up window
    
    if (wvPopUp)
    {
        
        NSString *js = @"window.close = function () {window.location.assign(\"back://\" + window.location);};";
         [webView
                                          stringByEvaluatingJavaScriptFromString:js];
    }else {
        [self endProgress];
        
        
        NSString *js = @"window.open = function (url, d1, d2) { window.location = \"open://\" + url;        }";
        [webView
                                              stringByEvaluatingJavaScriptFromString:js];
        
    }
}




- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString* requestURL = request.URL.absoluteString;
    
    
    
    if ([requestURL rangeOfString:@"back://"].location == 0)
    {
        [self closePopup];
        return NO;
    } else if  ([requestURL hasPrefix: @"open://"]){
        
        NSString *newUrl = [requestURL stringByReplacingOccurrencesOfString:@"open://" withString:@""];
        newUrl = [newUrl stringByReplacingOccurrencesOfString:@"https//" withString:@"https://"];
        NSURLRequest *newRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:newUrl]];

       
            UIWebView *wv = [self popUpWebview];
            [wv loadRequest:newRequest];
        
       
        return NO;
    }
    return YES;
    
}
- (void) closePopup {
    
    
    
    if (wvPopUp) {
        NSURL *url = wvPopUp.request.URL;
        NSString *surl = url.absoluteString;
        NSUInteger pos = [surl rangeOfString:@"?"].location;
        NSString *paras = @"";
        if (pos != NSNotFound && pos < [surl length]-1) {
            paras = [surl substringFromIndex:pos + 1];
        }
        
        
        NSString *js = [NSString stringWithFormat: @"refreshData('%@');",paras ];
        __unused NSString *jsOverrides = [_browser
                                          stringByEvaluatingJavaScriptFromString:js];
        
        [wvPopUp removeFromSuperview];
        wvPopUp = nil;
    }
    if(btnClosePopup){
        [btnClosePopup removeFromSuperview];
        btnClosePopup = nil;
    }
    if(btnPrintPopup){
        [btnPrintPopup removeFromSuperview];
        btnPrintPopup = nil;
    }
    if(vwPopUpContainer){
        [vwPopUpContainer removeFromSuperview];
        vwPopUpContainer = nil;
    }
}

- (UIWebView *) popUpWebview
{
    // Create a web view that fills the entire window, minus the toolbar height
    CGRect rect = CGRectMake(_browser.frame.origin.x+20,_browser.frame.origin.y+20,
                             _browser.frame.size.width-40,_browser.frame.size.height-40);
    
    vwPopUpContainer = [[UIView alloc] initWithFrame: rect];
    vwPopUpContainer.backgroundColor = [UIColor grayColor];
    [self.view addSubview:vwPopUpContainer];
    
    CGRect rectBtn = CGRectMake(10, 10, 60, 20);
    btnClosePopup = [[UIButton alloc] initWithFrame:rectBtn];
    //btnClosePopup.titleLabel.text = @"Close";
    [btnClosePopup setTitle:@"Close" forState:UIControlStateNormal];
    [btnClosePopup addTarget:self action:@selector(closePopup) forControlEvents:UIControlEventTouchUpInside];
    [vwPopUpContainer addSubview:btnClosePopup];
    CGRect rectPrintBtn = CGRectMake(90, 10, 60, 20);
    btnPrintPopup = [[UIButton alloc] initWithFrame:rectPrintBtn];
    //btnClosePopup.titleLabel.text = @"Close";
    [btnPrintPopup setTitle:@"Print" forState:UIControlStateNormal];
    [btnPrintPopup addTarget:self action:@selector(printPopup) forControlEvents:UIControlEventTouchUpInside];
    [vwPopUpContainer addSubview:btnPrintPopup];
    
    
    
    CGRect rectWeb = CGRectMake(10, 40, rect.size.width - 20, rect.size.height - 50);
    
    UIWebView *webView = [[UIWebView alloc]
                          initWithFrame: rectWeb];
    
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    // Add to windows array and make active window
    wvPopUp = webView;
   // wvPopUp.delegate = self;
   [vwPopUpContainer addSubview:wvPopUp];
    return webView;
}

-(void) webViewDidStartLoad:(UIWebView*)webView{
    
    [self startProgress];
}

-(void) startProgress {
    _progressView.progress = 0;
    _progressView.hidden = false;
    
    theBool = false;
    //0.01667 is roughly 1/60, so it will update at 60 FPS
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target: self selector:@selector( timerCallback) userInfo: nil repeats: true];
}

- (void)clearTmpDirectory
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}


-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}

-(void) endProgress {
    theBool = true;
}

-(void) timerCallback {
    dispatch_async(dispatch_get_main_queue(), ^(){
        if (theBool) {
            if (_progressView.progress >= 1) {
                _progressView.hidden = true;
                [_timer invalidate];
            }
            else {
                _progressView.progress += 0.1;
            }
        }
        else {
            _progressView.progress += 0.05;
            if (_progressView.progress >= 0.95) {
                _progressView.progress = 0.95;
            }
        }
    });
}

-(IBAction)btnRefreshClicked:(id)sender{
    [_browser stopLoading];
    [_browser reload];
}

-(IBAction)btnBackClicked:(id)sender{
    if ([_browser canGoBack]) {
        [_browser goBack];
    }
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}





-(void)shareByPrinter:(UIWebView*) webView
{
    UIPrintInfo *pi = [UIPrintInfo printInfo];
    pi.outputType = UIPrintInfoOutputGeneral;
    pi.jobName = webView.request.URL.absoluteString;
    pi.orientation = UIPrintInfoOrientationPortrait;
    pi.duplex = UIPrintInfoDuplexLongEdge;
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    pic.printInfo = pi;
    pic.printFormatter = webView.viewPrintFormatter;
    [pic presentFromRect:CGRectMake(self.view.frame.size.width-50, 40, 1, 1) inView:self.view animated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
        
    }];
}

-(IBAction)onMainPrint:(id)sender{
    [self shareByPrinter:_browser];
}

-(void) printPopup {
    if (!wvPopUp) {
        return;
    }
    [self shareByPrinter:wvPopUp];
}



@end
