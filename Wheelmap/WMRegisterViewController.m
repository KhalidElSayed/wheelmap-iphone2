//
//  WMRegisterViewController.m
//  Wheelmap
//
//  Created by npng on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMRegisterViewController.h"
#import "WMWheelmapAPI.h"

@implementation WMRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedString(@"RegisterNew", nil);

    [self.cancelButton setTitle:NSLocalizedString(@"Ready", nil) forState:UIControlStateNormal];
    
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    NSString *baseURL = config[@"apiBaseURL"];
    NSURL *url = [NSURL URLWithString:@"/en/oauth/register_osm" relativeToURL:[NSURL URLWithString:baseURL]];
	[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    self.webView.scrollView.scrollsToTop = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"WebView loading failed: %@",error.localizedDescription);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"WebView finished loading");
}

-(IBAction)pressedCancelButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end

