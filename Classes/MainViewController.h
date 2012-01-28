//
//  MainViewController.h
//  cctv
//
//  Created by Alexandre Berman on 12/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"


@interface MainViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, FlipsideViewControllerDelegate> {
	UISwitch    *appSwitch;
	UILabel     *statusLblMain;
	UIPickerView *pickerView;
	NSMutableArray *arrayIntervals;
	UIButton    *help;
	NSString    *helpAlert;
}

@property (nonatomic, retain) IBOutlet UISwitch    *appSwitch;
@property (nonatomic, retain) IBOutlet UILabel     *statusLblMain;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) NSMutableArray *arrayIntervals;
@property (nonatomic, retain) IBOutlet UIButton *help;
@property (nonatomic, retain) NSString *helpAlert;

- (IBAction)showInfo:(id)sender;
- (IBAction)switchON:(id)sender;
- (IBAction)doHelp:(id)sender;
- (void)updateStatus:(NSNotification *)notification;

@end
