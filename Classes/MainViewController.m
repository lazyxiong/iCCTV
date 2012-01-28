//
//  MainViewController.m
//  cctv
//
//  Created by Alexandre Berman on 12/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

@synthesize statusLblMain, appSwitch, pickerView, arrayIntervals, help, helpAlert;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	// nsnotification observer method registration
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus:) name:nil object:nil];
	
	// add our cute image here
	//UIImageView *i=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon3d.png"]];
	UIImageView *i=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_face.png"]];
	[i setFrame:CGRectMake(10,30,45,45)]; //Adjust X,Y,W,H as needed
	[[self view] addSubview:i];
	[i release], i=nil;
	
	// define our pickerView
	arrayIntervals = [[NSMutableArray alloc] init];
	[arrayIntervals addObject:@"1"];
	[arrayIntervals addObject:@"5"];
	[arrayIntervals addObject:@"10"];
	[arrayIntervals addObject:@"15"];
	[arrayIntervals addObject:@"20"];
	[arrayIntervals addObject:@"25"];
	[arrayIntervals addObject:@"30"];
	[arrayIntervals addObject:@"35"];
	[arrayIntervals addObject:@"40"];
	[arrayIntervals addObject:@"45"];
	[arrayIntervals addObject:@"50"];
	[arrayIntervals addObject:@"55"];
	[arrayIntervals addObject:@"60"];
	[arrayIntervals addObject:@"120"];
	[arrayIntervals	addObject:@"240"];
	
	pickerView.delegate = self;
	pickerView.dataSource = self;
	
	// turn app off initially and let user explicitly start it - unless we are already running...
	icctv *model  = [icctv sharedicctv];
	
	if (!model.isRunning)
	{
		// everything we want to do the first time app starts
		// main switch is OFF
		[appSwitch setOn:NO animated:YES];
		
		// let's select first row by default
		[pickerView selectRow:0 inComponent:0 animated:NO];
		
		// define our help
		helpAlert = [[NSString alloc] initWithString:@"\nSet/edit application configuration, then use dial to set time interval \n(in minutes). \nThe service then, will email you still images taken with camera with the frequency you specified. \n\nMain Switch turns service on/off.\n"];
	}
	else {
		// we are running service, so this is not the first time we are loaded - must be a return from another view
		[appSwitch setOn:YES animated:YES];
		[pickerView selectRow:[model.intervalIndex integerValue] inComponent:0 animated:NO];
		
		// trigger status update from the model
		[model statusNotify];
	}
	
	[super viewDidLoad];
}

// below methods are needed by UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {	
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {	
	return [arrayIntervals count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [arrayIntervals objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	// we get minute - send seconds
	NSNumber *interval = [NSNumber numberWithDouble:[[arrayIntervals objectAtIndex:row] doubleValue] * 60];
	icctv *model  = [icctv sharedicctv];
	model.interval = interval;
	model.intervalIndex = [NSNumber numberWithInteger:row];
}

// model's status value changed - notification arrived
- (void)updateStatus:(NSNotification *) notification {
	if ([[notification name] isEqualToString:@"statusLblUpdate"])
	{
		statusLblMain.text = (NSString*)[notification object];
	}
	if ([[notification name] isEqualToString:@"statusUpdate"])
	{
		// if server's status is false, we want to update our switch and set it to off
		// but if status is true - we don't want to touch the switch.
		if ([(NSNumber *)[notification object] boolValue] == NO)
		{
		   [appSwitch setOn:NO animated:YES];
		}
	}
}

// help
- (IBAction)doHelp:(id)sender {
	UIAlertView *someAlert = [[UIAlertView alloc] initWithTitle:@"Help" message:self.helpAlert delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[someAlert show];
	[someAlert release];
}

// start/stop our app
- (IBAction)switchON:(id)sender {
	icctv *model = [icctv sharedicctv];
	if ([sender isOn])
	{
		model.mainView = self;
		[model doActivate];
	} 
	else
	{
		[model doDeActivate];
	}
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender {    
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)dealloc {
    [statusLblMain release];
    [appSwitch release];
    [arrayIntervals release];
    [pickerView release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
