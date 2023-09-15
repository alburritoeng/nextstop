//
//  StationDetailsController.m
//  Next Stop
//
//  Created by Alberto Martinez on 8/16/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import "StationDetailsController.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#define kLabelTag			4096



#define AppVersion          @"3.7"

@interface StationDetailsController ()

@end

@implementation StationDetailsController
@synthesize stationDetails;
@synthesize stationName;
@synthesize geocoder;
@synthesize stationAddress;
@synthesize myTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    // Do any additional setup after loading the view from its nib.
    
    
    double lat1 = 0.0;
    double lon1 = 0.0;
    AppDelegate*  app  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary* coordDict = [app getCoordinateForStopName:stationName];
    
    for(id stopName in coordDict)
    {
        NSString* c = [coordDict objectForKey:stopName];
        NSArray* latLonArr = [c componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
        lat1 = [[latLonArr objectAtIndex:0] doubleValue];
        lon1 = [[latLonArr objectAtIndex:1] doubleValue];
    }
   // NSLog(@"%f, %f", lat1, lon1);
    
    CLLocationCoordinate2D loc1;
    
    loc1.latitude =  lat1;
    loc1.longitude = lon1;
    
    
    CLLocation* location = [[CLLocation alloc] initWithCoordinate:loc1 altitude:0 horizontalAccuracy:0 verticalAccuracy:0 course:0 speed:0 timestamp:[NSDate date]];
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }

    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        if(placemark!=nil)
        {
            NSString* address;
            if(placemark.subThoroughfare == nil)
                address = @"";
            else
                address = placemark.subThoroughfare;
            self.stationAddress = [NSString stringWithFormat:@"%@ %@, %@, %@, %@", address, placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode];
            
            
            
            [self.myTableView beginUpdates];
            NSUInteger _path[2] = {0, 0};
            NSIndexPath *_indexPath = [[NSIndexPath alloc] initWithIndexes:_path length:2];
            NSArray *_indexPaths = [[NSArray alloc] initWithObjects:_indexPath, nil];

            [self.myTableView reloadRowsAtIndexPaths:_indexPaths withRowAnimation:UITableViewRowAnimationRight];

            [self.myTableView endUpdates];
            
        }
    
    }];
    
    
  
    
    
    
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	
    //route_id,bathroom,parking,parking_fee,bicycle_racks,waiting_area,contact_info
	NSString *sectionHeader = nil;
	switch (section) {
        case 0:
            sectionHeader = @"Nearest Address to Station";
            break;
        case 1:
            sectionHeader = @"Bathrooms available";
            break;
        case 2:
            sectionHeader = @"Parking available?";
            break;
        case 3:
            sectionHeader = @"Is there a parking fee?";
            break;
        case 4:
            sectionHeader = @"Are there bike racks?";
            break;
        case 5:
            sectionHeader = @"A waiting area?";
            break;
        case 6:
            sectionHeader = @"Station contact number:";
            break;
        case 7:
            sectionHeader = @"Next Stop Version:";
            break;
        default:
            break;
    }
	
	
	
	return sectionHeader;
}

-(BOOL)tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender
{
	//NSLog(@"can perform action for table");
	if (action == @selector(cut:))
		return NO;
	else if (action == @selector(copy:))
		return YES;
	else if (action == @selector(paste:))
		return NO;
	else if (action == @selector(select:) || action == @selector(selectAll:))
		return NO;
	else
		return [super canPerformAction:action withSender:sender];
}


-(void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender
{
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    if(indexPath.section==0)
    {
        gpBoard.string = self.stationAddress;
    }
    else
    {
        gpBoard.string = [self.stationDetails objectAtIndex:indexPath.section-1];
    }
//	gpBoard.string = [self.values objectAtIndex:[indexPath section]];
}

-(BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath
{
	//NSLog(@"Should show menu for index section = %d, row = %d", [indexPath section], [indexPath row]);
	if ((indexPath.section == 0) || indexPath.section == 6)
		return YES;
	return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    

    //remember, added address as index=0, so everything in the stationDetails array gets pushed one... so do a '-1' on the section value.
    if(indexPath.section==0)    //section 0 -- address
    {
        //address
        if(stationAddress.length>0)
        {
            cell.textLabel.text = stationAddress;
            
        }
        else
        {
            cell.textLabel.text = @"locating...";
        }
       cell.textLabel.numberOfLines=3;
    }
    else if(indexPath.section <6)
    {
       
        int  num = [[stationDetails objectAtIndex:indexPath.section-1] intValue];
        if(num==0)
            cell.textLabel.text = @"No";
        else
            cell.textLabel.text = @"Yes";
    }
    else
    {
        if(indexPath.section-1 <[stationDetails count])
            cell.textLabel.text = [stationDetails objectAtIndex:indexPath.section-1];
        else
            cell.textLabel.text = [NSString stringWithFormat:@"%@", AppVersion];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 8; //Main and Optional
}

- (void)viewDidUnload
{
    myTableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
