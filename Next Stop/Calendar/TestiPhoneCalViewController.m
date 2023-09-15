//
//  TestiPhoneCalViewController.m
//  TestiPhoneCal
//
//  Created by tinyfool on 10-3-6.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TestiPhoneCalViewController.h"
#import "TdCalendarView.h"
@implementation TestiPhoneCalViewController
@synthesize mainView;
@synthesize m_day;


- (IBAction)closeCalendar:(id)sender
{
    //dismissViewControllerAnimated
    [self dismissViewControllerAnimated: YES  completion:nil];
    //[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)chooseNow:(id)sender {
    TdCalendarView* v = (TdCalendarView*)self.view;
    
    self.m_day = v.theDay = -2;
    [self dismissViewControllerAnimated: YES  completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}
-(void) viewWillDisappear:(BOOL)animated
{
    

    TdCalendarView* v = (TdCalendarView*)self.view;
    
    self.m_day = v.theDay;
    
    [super viewWillDisappear:animated];
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {

    mainView = nil;
    
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    //[super dealloc];
}

@end
