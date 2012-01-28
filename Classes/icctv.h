//
//  icctv.h
//  cctv
//
//  Created by Alexandre Berman on 1/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#import "SynthesizeSingleton.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"

#define GET_INSTRUCTIONS_FROM_PREF_KEY @"kGetInstructionsFromPreferenceKey"
#define REPORT_TO_PREF_KEY @"kReportToPreferenceKey"
#define SMTP_HOST_PREF_KEY @"kSmtpHostPreferenceKey"
#define PASSWORD_PREF_KEY @"kPasswordPreferenceKey"
#define DEVICE_ID_PREF_KEY @"kDeviceIdPreferenceKey"


@interface icctv : NSObject <SKPSMTPMessageDelegate> {
	NSString *reportTo;
	NSString *getInstructionsFrom;
	NSString *Password;
	NSString *deviceID;
	NSString *smtpHost;
	NSString *status;
	NSTimer	 *myTimer;
	NSNumber *interval;
	NSNumber *intervalIndex;
	BOOL     isRunning;
	UIImagePickerController *imgPicker;
	UIViewController *mainView;
}

@property(nonatomic, retain) NSString *reportTo;
@property(nonatomic, retain) NSString *getInstructionsFrom;
@property(nonatomic, retain) NSString *Password;
@property(nonatomic, retain) NSString *deviceID;
@property(nonatomic, retain) NSString *smtpHost;
@property(nonatomic, retain) NSString *status;
@property(nonatomic, retain) NSTimer  *myTimer;
@property(nonatomic, retain) NSNumber *interval;
@property(nonatomic, retain) NSNumber *intervalIndex;
@property(nonatomic, assign) BOOL isRunning;
@property(nonatomic, retain) UIImagePickerController *imgPicker;
@property(nonatomic, retain) UIViewController *mainView;

+ (icctv *) sharedicctv;
- (void)updateStatus:(NSString *)newStatusLbl withRunningFlag:(BOOL)newStatus;
- (void)statusNotify;
- (void)doSendTestEmail;
- (void)doDeActivate;
- (void)doActivate;
- (void)grabPhotoAndSend:(NSTimer *)timer;
- (void)takePicture:(NSTimer *)timer;
- (void)doSendImage:(NSString *)imagePath withName:(NSString *)imageName;
- (BOOL)checkIfReady;
- (BOOL)checkNetworkReady;

@end
