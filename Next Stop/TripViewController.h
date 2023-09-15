//
//  TripViewController.h
//  Next Stop
//
//  Created by Alberto Martinez on 8/2/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface TripViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    IBOutlet UITableView *myTableView;
    NSArray* stopNames;
    int current;
    IBOutlet UIBarButtonItem *doneBtn;
    IBOutlet UIView *pickerViewContainer;
    AppDelegate* app;
}
@property (strong, nonatomic) IBOutlet UILabel *RoundTripLabel;
@property (strong, nonatomic) IBOutlet UILabel *SevenDayLabel;
@property (strong, nonatomic) IBOutlet UILabel *NotifyLabel;    //so the user knows which is the picker is modying (origin or destination)

@property (strong, nonatomic) IBOutlet UILabel *OneWayLabel;
@property (nonatomic, retain) AppDelegate* app;
@property int current;
@property (nonatomic, retain) NSArray* stopNames;
@property (strong, nonatomic) IBOutlet UIButton *reverseBtn;
@property (strong, nonatomic) IBOutlet UIButton *startLocationBtn;
@property (strong, nonatomic) IBOutlet UIButton *endLocationBtn;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIPickerView *myDataPicker;
- (IBAction)chooseEndLoc:(id)sender;
- (IBAction)reverseLocations:(id)sender;
- (IBAction)chooseStartLoc:(id)sender;
- (IBAction)DoneBtn:(id)sender;
- (void) routeTrip;



@end
