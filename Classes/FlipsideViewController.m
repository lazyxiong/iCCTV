//
//  FlipsideViewController.m
//  cctv
//
//  Created by Alexandre Berman on 12/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"


@implementation FlipsideViewController

@synthesize delegate;
@synthesize testInProgress, emailTo, emailFrom, emailFromPassword, deviceID, testIt, smtpHost, statusLblFlip;

// test connection
- (void)doConnect {
	[testInProgress startAnimating];	
	statusLblFlip.text = [[NSString alloc] initWithString: @"connecting..."];
	icctv *model = [icctv sharedicctv];
	[model doSendTestEmail]; // once method completes, it will update its status and we will get notification
}

// model's status value changed - notification arrived
- (void)updateStatus:(NSNotification *) notification {
	/*
	if ([[notification name] isEqualToString:@"statusUpdate"])
	{
		if ([(NSNumber *)[notification object] boolValue] == YES)
		{
			[testInProgress stopAnimating];
			statusLblFlip.text = [[NSString alloc] initWithString: @"success !"];
		}
	}
	*/
	if ([[notification name] isEqualToString:@"statusLblUpdate"])
	{
		[testInProgress stopAnimating];
		statusLblFlip.text = (NSString *)[notification object];
	}
}

- (void)savePrefs {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:emailTo.text forKey:REPORT_TO_PREF_KEY];
	[prefs setObject:emailFrom.text forKey:GET_INSTRUCTIONS_FROM_PREF_KEY];
	[prefs setObject:emailFromPassword.text forKey:PASSWORD_PREF_KEY];
	[prefs setObject:deviceID.text forKey:DEVICE_ID_PREF_KEY];
	[prefs setObject:smtpHost.text forKey:SMTP_HOST_PREF_KEY];
	[prefs synchronize];
}

- (void)updateModel {
	icctv *model = [icctv sharedicctv];
	model.reportTo = emailTo.text;
	model.getInstructionsFrom = emailFrom.text;
	model.Password = emailFromPassword.text;
	model.deviceID = deviceID.text;
	model.smtpHost = smtpHost.text;
}

// get all values and connect to mail server
- (void)doValidate {
   if([emailTo.text length] != 0 && [emailFrom.text length] != 0 
	          && [emailFromPassword.text length] != 0 && [smtpHost.text length] != 0)
   {
	   [self updateModel];
	   [self savePrefs];
	   [self doConnect];
   }
   else
   {
	   statusLblFlip.text = @"some fields are blank !";
   }
}

// test connecting to email
- (IBAction)testIt:(id)sender {
	[self doValidate];
}

// this is so keyboard disappears after it is not needed (ie: after clicking "done")
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[theTextField resignFirstResponder];
	return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];   
	testInProgress.hidesWhenStopped = YES;
	icctv *model = [icctv sharedicctv];
	if (![model.reportTo isEqualToString:@""])
	{ 
		emailTo.text = model.reportTo;
	}
	if (![model.getInstructionsFrom isEqualToString:@""])
	{
	    emailFrom.text = model.getInstructionsFrom;
	}
	if (![model.Password isEqualToString:@""])
	{
	    emailFromPassword.text = model.Password;
	}
	if (![model.deviceID isEqualToString:@""])
	{
	    deviceID.text = model.deviceID;
	}
	if (![model.smtpHost isEqualToString:@""])
	{
	    smtpHost.text = model.smtpHost;
	}
	// nsnotification observer method registration
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(updateStatus:)
												 name:nil
											   object:nil];
	if ([self.statusLblFlip.text isEqualToString:@""])
	{
		statusLblFlip.text = @"setup configuration";
	}
}

- (IBAction)done:(id)sender {
	[self updateModel];
	[self savePrefs];
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)dealloc {
	[emailTo release];
	[emailFrom release];
	[emailFromPassword release];
	[testIt release];
	[deviceID release];
	[testInProgress release];
	[statusLblFlip release];
	[super dealloc];
}
	
@end
