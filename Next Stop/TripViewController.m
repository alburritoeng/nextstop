//
//  TripViewController.m
//  Next Stop
//
//  Created by Alberto Martinez on 8/2/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import "TripViewController.h"
#import "AppDelegate.h"
#import "TDOAuth.h"


@interface TripViewController ()

@end

@implementation TripViewController
@synthesize myTableView;
@synthesize myDataPicker;
@synthesize reverseBtn;
@synthesize startLocationBtn;
@synthesize endLocationBtn;
@synthesize stopNames;
@synthesize current;
@synthesize app;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        /*
         Dollar sign icon:
         You can do whatever you want with these icons (use on web or in desktop applications) as long as you don?t pass them off as your own and remove this readme file. A credit statement and a link back to
         http://led24.de/iconset/ or http://led24.de/ would be appreciated.
         */
        self.title = NSLocalizedString(@"Fares", @"Fares");
        self.tabBarItem.image = [UIImage imageNamed:@"dollar"]; //second"];
        AppDelegate* app1 = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        stopNames = [[NSMutableArray alloc]init];
        NSMutableArray* tempArray = [[NSMutableArray alloc]init];
        [tempArray addObject:@""];
        for(id ob in app1.stopNameAndStopId)
        {
            [tempArray addObject:ob];
        }
        
        stopNames = [tempArray sortedArrayUsingSelector:@selector(compare:)];

        
        [self.endLocationBtn setTintColor:[UIColor grayColor]];
        [self.startLocationBtn setTintColor:[UIColor grayColor]];
//        UIBarButtonItem *tripItBtn = [[UIBarButtonItem alloc] initWithTitle:@"Calculate Fare" style:UIBarButtonItemStyleBordered target:self  action:@selector(routeTrip)];
//        self.navigationItem.rightBarButtonItem = tripItBtn;

                                       
               

    }
    
    [self routeTrip];
    [self showPicker];
    //
    //[self pickerView:myDataPicker attributedTitleForRow:<#(NSInteger)#> forComponent:<#(NSInteger)#>]
    
    return self;
}
- (void) FreeRide
{
    self.OneWayLabel.text = [NSString stringWithFormat:@"Free! "];
    self.RoundTripLabel.text = [NSString stringWithFormat:@"On Us!"];
    self.SevenDayLabel.text = [NSString stringWithFormat:@"Really, No Charge!"];
}
- (void) UpdateLabels:(double) fare
{
    self.OneWayLabel.text = [NSString stringWithFormat:@"$%.2f", fare];
    self.RoundTripLabel.text = [NSString stringWithFormat:@"$%.2f", fare*2];
    self.SevenDayLabel.text = [NSString stringWithFormat:@"$%.2f", fare*7];
}
- (void) routeTrip
{
    NSString* val1 = [app.stopNameAndStopId objectForKey:[endLocationBtn.titleLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
     NSString* val2 = [app.stopNameAndStopId objectForKey:[startLocationBtn.titleLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    int origin = [val1 intValue];
    int destination = [val2 intValue];
    
    if(origin == 0 || destination==0)
    {
        [self UpdateLabels:0];
        return;
    }
    
    if(origin == destination)
    {
        [self FreeRide];
        return;
    
    }
    //write method to get
    double fare = [app GetFareForTrip:origin withEnd:destination];
    [self UpdateLabels:fare];
    
    
}



//current=0 -- start
//current=1 -- end

- (IBAction)chooseEndLoc:(id)sender
{
    current = 1;

    self.NotifyLabel.text = [NSString stringWithFormat:@"End:"];

    [self showPicker];
}

- (void) showPicker
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:ctx];
	[UIView setAnimationDuration:.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGRect fullScreenRect = [[UIScreen mainScreen] bounds];
    pickerViewContainer.frame = CGRectMake(0, fullScreenRect.size.height-275, 320, 255);//200);
    
    //pickerViewContainer.frame = CGRectMake(0, 118, 320, 248);
    [UIView commitAnimations];
}


- (IBAction)reverseLocations:(id)sender
{
    
    NSString* temp = endLocationBtn.titleLabel.text;
    [endLocationBtn setTitle:startLocationBtn.titleLabel.text forState:UIControlStateNormal];
    [startLocationBtn setTitle:temp forState:UIControlStateNormal];
   
    [self routeTrip];

}

- (IBAction)chooseStartLoc:(id)sender   
{
    current=0;
    self.NotifyLabel.text = [NSString stringWithFormat:@"Start:"];

    [self showPicker];
}

- (IBAction)DoneBtn:(id)sender
{
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    [UIView beginAnimations:nil context:ctx];
//	[UIView setAnimationDuration:.5];
//	[UIView setAnimationDelegate:self];
//	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//    
//    CGRect fullScreenRect = [[UIScreen mainScreen] bounds];
//    pickerViewContainer.frame = CGRectMake(0, fullScreenRect.size.height, 320, 255);//116);
//    
//    //pickerViewContainer.frame = CGRectMake(0, 460, 320, 216);//248);
//    [UIView commitAnimations];

    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        return YES;
    }
    return NO;
    
}

- (void) viewWillAppear:(BOOL)animated
{
 
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [super viewWillAppear:animated] ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //pickerViewContainer.frame = CGRectMake(0, 460, 320, 248);
    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self showPicker];
    
 
}

- (void)viewDidUnload
{
    [self setReverseBtn:nil];
    [self setStartLocationBtn:nil];
    [self setEndLocationBtn:nil];
    [self setMyTableView:nil];
    [self setMyDataPicker:nil];
    doneBtn = nil;
    pickerViewContainer = nil;
    myTableView = nil;
    [self setOneWayLabel:nil];
    [self setRoundTripLabel:nil];
    [self setSevenDayLabel:nil];
    [self setNotifyLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *returnStr = @"";
	
	// note: custom picker doesn't care about titles, it uses custom views
	if (pickerView == myDataPicker)
		returnStr = [stopNames objectAtIndex:row];

	return returnStr;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView == myDataPicker)	// don't show selection for the custom picker
	{
        if(current==0)
        {
            self.NotifyLabel.text = [NSString stringWithFormat:@"Start:"];
            NSString* val = [NSString stringWithFormat:@"%@ ",
                             [stopNames objectAtIndex:[pickerView selectedRowInComponent:0]]];
            [self.startLocationBtn setTitle:val forState:UIControlStateNormal];
            [self routeTrip];
           
        }
        else
        {
           self.NotifyLabel.text = [NSString stringWithFormat:@"End:"];
            NSString* val = [NSString stringWithFormat:@"%@ ",
                             [stopNames objectAtIndex:[pickerView selectedRowInComponent:0]]];
            [self.endLocationBtn setTitle:val forState:UIControlStateNormal];

            [self routeTrip];
           
        }

    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [stopNames count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}




@end
