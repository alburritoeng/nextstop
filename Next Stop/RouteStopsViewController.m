//
//  RouteStopsViewController.m
//  Next Stop
//
//  Created by Alberto Martinez on 8/5/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import "RouteStopsViewController.h"
#import "AppDelegate.h"
#import "StationDetailsController.h"
@interface RouteStopsViewController ()

@end

@implementation RouteStopsViewController
@synthesize myLabel;
@synthesize myTableView;
@synthesize routeID, details;
@synthesize app;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      app  = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    }
    return self;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        return YES;
    }
    return NO;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.details = [[NSMutableArray alloc] init];
    self.details = [app getRouteDetailsForRoute:self.routeID];
    
    
     
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setMyTableView:nil];
    [self setMyLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.details count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  80;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    RouteDetailsClass* t = [self.details objectAtIndex:indexPath.row];
    NSString* stopID = t.stopId;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    NSMutableArray* results = [app getStationDetails:stopID];
    

    StationDetailsController* stationView = [[StationDetailsController alloc] initWithNibName:@"StationDetailsController" bundle:nil];

    stationView.stationName = stopID;
    stationView.title = stopID;

    if([results count] >0)
    {
        stationView.stationDetails = results;
        [self.navigationController pushViewController:stationView animated:YES];
    }
//    else
//        NSLog(@"%@", stopID);

}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    //will take user to the next screen showing all the stops along the selected route
    //they are sorted here based on the lowest order they appear under stop_times
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    //NSString* text = [NSString stringWithFormat:@"%@", [self.details objectAtIndex:indexPath.row]];
    RouteDetailsClass* t = [self.details objectAtIndex:indexPath.row];
        
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.text = t.stopId;
    NSString* time = [app convertTimeToStandard:t.departureTime];
    cell.textLabel.text = [NSString stringWithFormat:@" %@", time];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}



@end
