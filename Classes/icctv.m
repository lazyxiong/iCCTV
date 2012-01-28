//
//  icctv.m
//  cctv
//
//  Created by Alexandre Berman on 1/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "icctv.h"

@implementation icctv

SYNTHESIZE_SINGLETON_FOR_CLASS(icctv);
@synthesize getInstructionsFrom, reportTo, smtpHost, Password, deviceID, status, isRunning, myTimer, interval, intervalIndex, imgPicker;
@synthesize mainView;

// update status
- (void)updateStatus:(NSString *)newStatusLbl withRunningFlag:(BOOL)newStatus {
	status = newStatusLbl;
	isRunning = newStatus;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"statusLblUpdate" object:status];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"statusUpdate" object:[NSNumber numberWithBool:isRunning]];
}

// trigger status update notification
- (void)statusNotify {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"statusLblUpdate" object:status];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"statusUpdate" object:[NSNumber numberWithBool:isRunning]];
}

// test email
- (void)doSendTestEmail {
	if ([self checkIfReady])
	{
		NSString *image_path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
		NSString *image_name = [[NSString alloc] initWithString:@"test.jpg"];
		[self doSendImage:image_path withName:image_name];
	}
}

// grab a picture and send it
- (void)grabPhotoAndSend:(NSTimer*)timer {
	imgPicker = [[UIImagePickerController alloc] init]; 
	UIView *overlayView = [[UIView alloc] initWithFrame:imgPicker.view.frame];
	imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	imgPicker.showsCameraControls = NO;
	imgPicker.navigationBarHidden = YES;
	imgPicker.toolbarHidden = YES;
	imgPicker.delegate = self;
    imgPicker.cameraOverlayView = overlayView;
	[self.mainView presentModalViewController:imgPicker animated:NO];
	// -- here we need to wait a bit...
	[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(takePicture:) userInfo:nil repeats:NO];
}

// -- actually take a picture here
- (void)takePicture:(NSTimer*)timer {
	[imgPicker takePicture];
	//NSLog(@"-- should have taken picture");
}

// this method should (I think) get called automagically once camera finished taking picture...
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	//NSLog(@"-- Did finish picking with info");
	// the captured image should be in the variable img, and then you can go and manipulate it as you see fit
	UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
	// Dismiss the camera
	[self.mainView dismissModalViewControllerAnimated:NO];
	// create a file
	NSString *jpgName = [[NSString alloc] initWithString:@"cctv_image.jpg"];
	NSString *tmpPath = [NSString stringWithFormat:@"Documents/%@", jpgName];
	NSString *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:tmpPath];
	[UIImageJPEGRepresentation(img, 0.3) writeToFile:jpgPath atomically:YES];
	[picker release];
	// -- send the image out now
	[self doSendImage:jpgPath withName:jpgName];
}

// stop main loop
- (void)doDeActivate {
	[myTimer invalidate];
	[myTimer release];
	myTimer = nil; // ensures we never invalidate an already invalid Timer
	[self updateStatus:@"server stopped..." withRunningFlag:NO];
}

// main loop
- (void)doActivate {
	//NSLog(@"-- interval now: %f", [self.interval doubleValue]);
	if ([self checkIfReady])
	{
	    myTimer = [[NSTimer scheduledTimerWithTimeInterval:[self.interval doubleValue] // Ticks once per interval seconds
		  				   	                    target:self     // Contains the function you want to call
						                      selector:@selector(grabPhotoAndSend:) 
							   	              userInfo:nil
						                       repeats:YES] retain];
	    [self updateStatus:@"server started..." withRunningFlag:YES];
	}
}

// check network connectivity
- (BOOL)checkNetworkReady {
	Reachability *hostReach = [Reachability reachabilityWithHostName: @"www.apple.com"];
	[NSThread sleepForTimeInterval:2.0];
	NetworkStatus netStatus = [hostReach currentReachabilityStatus];
	if(netStatus == NotReachable) {
		[self updateStatus:@"Error: network is unreachable !" withRunningFlag:NO];
		return NO;
	}
	return YES;
}

// check readiness
- (BOOL)checkIfReady {
	if ([smtpHost isEqualToString:@""])
	{
	    [self updateStatus:@"Error: configuration doesn't exist !" withRunningFlag:NO];
		return NO;
	}
	else
	{
	    return YES;
		//return [self checkNetworkReady];
	}
}

// send image !
- (void)doSendImage:(NSString *)imagePath withName:(NSString *)imageName {
	if ([self checkIfReady])
	{
	    NSString *contentDispositionKey = [NSString stringWithFormat:@"inline;\r\n\tfilename=\"%@\"", imageName];
	    NSString *contentTypeKey = [NSString stringWithFormat:@"image/jpg;\r\n\tname=%@;\r\n\tx-unix-mode=0666", imageName];
	    SKPSMTPMessage *test_smtp_message = [[SKPSMTPMessage alloc] init];
            test_smtp_message.fromEmail = getInstructionsFrom;
            test_smtp_message.toEmail = reportTo;
            test_smtp_message.relayHost = smtpHost;
            test_smtp_message.requiresAuth = TRUE;
            test_smtp_message.login = getInstructionsFrom;
            test_smtp_message.pass = Password;
            test_smtp_message.wantsSecure = TRUE; // smtp.gmail.com doesn't work without TLS!
	    if ([deviceID isEqualToString:@""])
	    {
		   test_smtp_message.subject = [[NSString alloc] initWithString: @"(icctv) image arrived !"];
	    }
	    else
	    {
		   test_smtp_message.subject = [NSString stringWithFormat:@"(icctv) image arrived [%@]", deviceID];
	    }
	    test_smtp_message.delegate = self;
            NSMutableArray *parts_to_send = [NSMutableArray array];
            //If you are not sure how to format your message part, send an email to your self.  
            //In Mail.app, View > Message> Raw Source to see the raw text that a standard email client will generate.
            //This should give you an idea of the proper format and options you need
            NSDictionary *plain_text_part = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"text/plain\r\n\tcharset=UTF-8;\r\n\tformat=flowed", kSKPSMTPPartContentTypeKey,
                                [[NSString alloc] initWithString: @"image attached\n"], kSKPSMTPPartMessageKey,
                                @"quoted-printable", kSKPSMTPPartContentTransferEncodingKey,
                                nil];
            [parts_to_send addObject:plain_text_part];
	    NSString *image_path = imagePath;
	    //NSLog(@"-- imagePath: %@", imagePath);
	    //NSLog(@"-- imageName: %@", imageName);
   	    NSData *image_data = [NSData dataWithContentsOfFile:image_path];
  	    NSDictionary *image_part = [NSDictionary dictionaryWithObjectsAndKeys:
				contentDispositionKey, kSKPSMTPPartContentDispositionKey,
				@"base64",kSKPSMTPPartContentTransferEncodingKey,
				contentTypeKey, kSKPSMTPPartContentTypeKey,
				[image_data encodeWrappedBase64ForData],kSKPSMTPPartMessageKey,
				nil];
	    [parts_to_send addObject:image_part];
  	    test_smtp_message.parts = parts_to_send;
	    [test_smtp_message send];
	}
}

-(id)init {
   self = [super init];
   if (self != nil)
   {
	   getInstructionsFrom = @"";
	   reportTo = @"";
	   smtpHost = @"";
	   Password = @"";
	   deviceID = @"";
	   status   = @"";
	   self.interval = [NSNumber numberWithDouble:60.0];   // default - 1 min
   }
   return self;
}

-(void) dealloc {
	[getInstructionsFrom release];
	[reportTo release];
	[smtpHost release];
	[Password release];
	[deviceID release];
	[status release];
	[myTimer release];
	[interval release];
	[super dealloc];
}

#pragma mark SKPSMTPMessage Delegate Methods
- (void)messageState:(SKPSMTPState)messageState {
    //NSLog(@"HighestState:%d", HighestState);
    //if (messageState > HighestState)
    //  HighestState = messageState;
    //ProgressBar.progress = (float)HighestState/(float)kSKPSMTPWaitingSendSuccess;
}
- (void)messageSent:(SKPSMTPMessage *)SMTPmessage {
    [SMTPmessage release];
    //Spinner.hidden = YES;
    //[Spinner stopAnimating];
    //ProgressBar.hidden = YES;
	
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Sent!"
    //                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[alert show];   
    //[alert release];
    //DEBUGLOG(@"delegate - message sent");
    [self updateStatus:@"message sent !" withRunningFlag:YES];
}
- (void)messageFailed:(SKPSMTPMessage *)SMTPmessage error:(NSError *)error {
    [SMTPmessage release];
    //Spinner.hidden = YES;
    //[Spinner stopAnimating];
    //ProgressBar.hidden = YES;
	
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription]
    //                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[alert show];   
    //[alert release];
    //DEBUGLOG(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
	//[self doDeActivate];
    //[self updateStatus:[NSString stringWithFormat:@"error: %@", [error localizedDescription]] withRunningFlag:NO];
	[self updateStatus:[NSString stringWithFormat:@"error: %@", [error localizedDescription]] withRunningFlag:YES];
}

@end
