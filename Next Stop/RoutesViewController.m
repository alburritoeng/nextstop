//
//  FirstViewController.m
//  Next Stop
//
//  Created by Alberto Martinez on 8/1/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import "RoutesViewController.h"
#import "AppDelegate.h"
#import "TripsForRoute.h"
#import "MapAllRoutesViewController.h"

@interface RoutesViewController ()

@end

@implementation RoutesViewController



@synthesize routesDict, listX;
@synthesize routeAndColor;
@synthesize routeNames;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Metrolink Lines", @"Metrolink Lines");
        self.tabBarItem.image = [UIImage imageNamed:@"route1"];
       
    }
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.routeNames = [app getAllRouteNames];
    

    return self;
}
			
- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];


	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    //return [self.routeNames count];
    //NSLog(@"total rows = %d", [self.routeNames count] +1);
    return [self.routeNames count] + 1; //All Routes :)S
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    //NSLog(@"row = %d", row);
    if(row<[self.routeNames count])
    {
        
        NSString *routeID = [[NSString alloc] initWithFormat:@"%@", [self.routeNames objectAtIndex:row]];
        
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        cell.textLabel.text = routeID;
        NSString *color = [app getColorForRoute:routeID];
    
        cell.contentView.backgroundColor = [self colorWithHexString:color];
        [cell.textLabel setBackgroundColor:[self colorWithHexString:color]];
    
    }
    else
    {
        cell.textLabel.text = @"All Routes Map";
        NSString* color = @"3A5FCD";    //per Button, Royal Blue
        cell.contentView.backgroundColor = [self colorWithHexString:color];
        [cell.textLabel setBackgroundColor:[self colorWithHexString:color]];
        
        
        
    }
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        return YES;
    }
    return NO;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //will take user to the next screen showing all the stops along the selected route
    //they are sorted here based on the lowest order they appear under stop_times
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger row = indexPath.row;
    //NSLog(@"sel row = %d", row);
    if(row<=7)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString* routeName = [self.routeNames objectAtIndex:indexPath.row];
        NSArray* sortedStops = [app getLowestStopOrderForStop:routeName];

        NSMutableDictionary *dict = [app getRouteIdAndTripHeadSignForRoute:routeName];

        TripsForRoute *tripsView = [[TripsForRoute alloc] initWithNibName:@"TripsForRoute"  bundle:nil];
        tripsView.allRoutes = sortedStops;
        tripsView.routeIdAndHeadsign = dict;
        tripsView.navColor = [self colorWithHexString:[app getColorForRoute:routeName]];
        tripsView.routeName = routeName;
    
        tripsView.title = routeName;
        [self.navigationController pushViewController:tripsView animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        MapAllRoutesViewController *AllRoutesView = [[MapAllRoutesViewController alloc] initWithNibName:@"MapAllRoutesViewController"  bundle:nil];

        AllRoutesView.title = @"All Routes";
        [self.navigationController pushViewController:AllRoutesView animated:YES];
    
    }
    
}









//took this method from this URL:
//http://www.imthi.com/blog/programming/iphone-sdk-convert-hex-color-string-to-uicolor.php
- (UIColor *) colorWithHexString: (NSString *) stringToConvert{
	NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	// String should be 6 or 8 characters
	//if ([cString length] < 6) return [UIColor blackColor];
	// strip 0X if it appears
	//if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
	//if ([cString length] != 6) return [UIColor blackColor];
	// Separate into r, g, b substrings
	NSRange range;
	range.location = 0;
	range.length = 2;
	NSString *rString = [cString substringWithRange:range];
	range.location = 2;
	NSString *gString = [cString substringWithRange:range];
	range.location = 4;
	NSString *bString = [cString substringWithRange:range];
	// Scan values
	unsigned int r, g, b;
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];
	
	return [UIColor colorWithRed:((float) r / 255.0f)
						   green:((float) g / 255.0f)
							blue:((float) b / 255.0f)
						   alpha:1.0f];
}


@end
