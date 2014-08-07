//
//  webview.h
//  jobagent
//
//  Created by mac on 4/6/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//


@interface WebVC : UIViewController <UITextFieldDelegate, UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UITextField *urlField;
@property (nonatomic, weak) NSString *requestedUrl;

@end
