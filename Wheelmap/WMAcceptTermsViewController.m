//
//  WMAcceptTermsViewController.m
//  Wheelmap
//
//  Created by npng on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMAcceptTermsViewController.h"

#import "WMDataManager.h"
#import "WMTermsViewController.h"

@interface WMAcceptTermsViewController ()
{
    WMDataManager* dataManager;
}
@end

@implementation WMAcceptTermsViewController

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
    
    dataManager = [[WMDataManager alloc] init];
    
    self.titleLabel.text = NSLocalizedString(@"TermsTitle", nil);
    self.titleLabel.adjustsFontSizeToFitWidth = YES;

    self.textLabel.text = NSLocalizedString(@"TermsText", nil);
    
    self.linkTextView.text = WMTermsURL;
    
    CGSize maximumLabelSize = CGSizeMake(self.textLabel.frame.size.width, FLT_MAX);
    
    CGSize expectedLabelSize = [self.textLabel.text sizeWithFont:self.textLabel.font constrainedToSize:maximumLabelSize lineBreakMode:self.textLabel.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = self.textLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    self.textLabel.frame = newFrame;
    
    self.linkTextView.frame = CGRectMake(self.linkTextView.frame.origin.x, self.textLabel.frame.origin.y + self.textLabel.frame.size.height + 10.0f, self.linkTextView.frame.size.width, self.linkTextView.frame.size.height);
    
    self.interceptButton.frame = self.linkTextView.frame;
    
    [self.acceptButton setTitle:NSLocalizedString(@"TermsAcceptButton", nil) forState:UIControlStateNormal];
    
    [self.declineButton setTitle:NSLocalizedString(@"TermsDeniedButton", nil) forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)pressedAcceptButton:(id)sender {
    
    [dataManager userDidAcceptTerms];
    
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)pressedDeclineButton:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"TermsDeniedText", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    
    [alert show];
    
    [dataManager removeUserAuthentication];
    
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)pressedInterceptButton:(id)sender {
    WMTermsViewController *termsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WMTermsVC"];
    [self presentModalViewController:termsViewController animated:YES];
}

@end