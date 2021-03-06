//
//  WMLoginViewController.h
//  Wheelmap
//
//  Created by Michael Thomas on 06.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMDataManagerDelegate.h"


@interface WMLoginViewController : WMViewController <UITextFieldDelegate, WMDataManagerDelegate> {
    
    WMDataManager *dataManager;
    BOOL keyboardIsShown;
}

@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UIScrollView *contentScrollView;

@property (nonatomic, weak) IBOutlet UIButton *doneButton;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *registerButton;
@property (nonatomic, weak) IBOutlet UIButton *forgotPasswordButton;
@property (nonatomic, weak) IBOutlet UITextView *forgotPasswordTextView;
@property (nonatomic, weak) IBOutlet UIButton *webLoginButton;
@property (nonatomic, weak) IBOutlet UILabel *webLoginLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *topTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *middleTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *bottomTextLabel;

- (IBAction)loginPressed:(id)sender;
- (IBAction)donePressed:(id)sender;

@end
