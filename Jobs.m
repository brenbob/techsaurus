//
//  Jobs.m
//  techlingo
//
//  Created by Brenden West on 7/6/14.
//  Copyright (c) 2014 Brenden West. All rights reserved.
//

#import "Jobs.h"
#import "AppDelegate.h"

@interface Jobs ()

@end

@implementation Jobs
//@synthesize webView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Jobs";
	self.webView.delegate = self;	// setup the delegate as the web view is shown
    [self loadJobs:_btnJobsSites];
}

- (IBAction)loadJobs:(id)sender {
    NSString *url = nil;
    if ([sender selectedSegmentIndex] == 0) {
        url = [NSString stringWithFormat:@"http://careers.stackoverflow.com/jobs?searchTerm=%@",self.selectedTag];
    } else {
        url = [NSString stringWithFormat:@"http://www.simplyhired.com/k-%@-jobs.html",self.selectedTag];
    }
    NSLog(@"url = %@",url);
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];

}


- (void)viewWillDisappear:(BOOL)animated
{
    [self.webView stopLoading];	// in case the web view is still loading its content
	self.webView.delegate = nil;	// disconnect the delegate as the webview is hidden
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// report the error inside the webview
	NSString* errorString = [NSString stringWithFormat:
							 @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
							 error.localizedDescription];
	[self.webView loadHTMLString:errorString baseURL:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	self.webView.delegate = nil;
	
}

@end
