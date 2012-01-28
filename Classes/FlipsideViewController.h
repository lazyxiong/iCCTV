//
//  FlipsideViewController.h
//  cctv
//
//  Created by Alexandre Berman on 12/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "icctv.h"


@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController {
	id <FlipsideViewControllerDelegate> delegate;
	UITextField *emailTo;
	UITextField *emailFrom;
	UITextField *emailFromPassword;
	UITextField *smtpHost;
	UITextField *deviceID;
    UIButton    *testIt;
	UIActivityIndicatorView *testInProgress;
	UILabel     *statusLblFlip;
}

@property (nonatomic, retain) IBOutlet UITextField *emailTo;
@property (nonatomic, retain) IBOutlet UITextField *emailFrom;
@property (nonatomic, retain) IBOutlet UITextField *emailFromPassword;
@property (nonatomic, retain) IBOutlet UITextField *smtpHost;
@property (nonatomic, retain) IBOutlet UITextField *deviceID;
@property (nonatomic, retain) IBOutlet UIButton    *testIt;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *testInProgress;
@property (nonatomic, retain) IBOutlet UILabel *statusLblFlip;
@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
- (IBAction)done:(id)sender;
- (IBAction)testIt:(id)sender;
- (void)updateStatus:(NSNotification *)notification;
- (void)doConnect;
- (void)doValidate;
- (void)savePrefs;
- (void)updateModel;
@end

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

