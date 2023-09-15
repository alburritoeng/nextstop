//
//  TripsForRoute.m
//  trains
//
//  Created by Alberto Martinez on 7/29/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import "TripsForRoute.h"
#import "AppDelegate.h"
#import "TopThreeViewController.h"
#import <math.h>
#import "StationDetailsController.h"


@interface TripsForRoute ()

@end

@implementation TripsForRoute

@synthesize allRoutes, routeIdAndHeadsign, navColor;
@synthesize myMapView, myTableView;
@synthesize shapeData, routeName;
@synthesize routeLine, routeLineView, _routeRect;
@synthesize annotationsToAdd;
@synthesize originalCenter, originalMapRect;

double defaultLong1 =-118.23;
double defaultLat1 =  34.06;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myMapView.delegate=self;
    
    annotationsToAdd = [[NSMutableArray alloc] init];
    
    
    [self loadRoute];
    [self.myMapView addOverlay:self.routeLine];
    [self addStopAnnotations];
 
	[self.myMapView setNeedsDisplay];

    self.navigationController.navigationBar.tintColor = self.navColor;
    
    
    UIImage *image = [UIImage imageNamed:@"enlarge_icon3.png"];
    UIBarButtonItem *expandMapBtn = [[UIBarButtonItem alloc] initWithImage:image landscapeImagePhone:image style:UIBarButtonItemStyleBordered target:self action:@selector(expandMap:)];
    
    self.navigationItem.rightBarButtonItem = expandMapBtn;

    
    
 }
- (void) RestoreMap
{
    [self.myMapView setFrame:originalMapRect];
    [self.myMapView setCenter:originalCenter];
    myTableView.hidden=false;
    locLabel.hidden=false;
}


- (IBAction)expandMap:(id)sender
{
    
    if(originalCenter.x==0 && originalCenter.y==0)
    {
        originalCenter = self.myMapView.center;
        originalMapRect = self.myMapView.frame;
    }
    //NSLog(@"%@", self.mapView);
    //NSLog(@"mapViewCenter X and Y are %f and %f ", self.mapView.center.x, self.mapView.center.y);
    if(!self.myTableView.hidden)
    {
        [self.myMapView setFrame:self.view.bounds];
        myTableView.hidden=true;
        [locLabel setHidden:YES];
        //locLabel.hidden=true;

    }
    else
    {
        [self.myMapView setFrame:originalMapRect];
        [self.myMapView setCenter:originalCenter];
        myTableView.hidden=false;
        [locLabel setHidden:NO];
        //locLabel.hidden=false;
    }
    
    
}

- (void)viewDidUnload
{
    self.myMapView = nil;
    locLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
  
    return [self.allRoutes count];//0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //here add all the stops for this route 
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    NSString *routeID = [[NSString alloc] initWithFormat:@"%@", [self.allRoutes objectAtIndex:row]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [ NSString stringWithFormat:@"%@",routeID ];//[NSString stringWithFormat:@"Train %@ to %@", routeID, headsign];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUInteger row = [indexPath row];
    NSString *routeID = [[NSString alloc] initWithFormat:@"%@", [self.allRoutes objectAtIndex:row]];
    
    NSString* stopID = [app getStopIdFromFriendlyName:routeID ];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

 
    NSMutableArray* possibleStops = [app getStopsForStopId:stopID];
    if([possibleStops count] == 0)
        possibleStops = [app getStopsForStopId:stopID stripStops:NO];
    TopThreeViewController *topThreeView = [[TopThreeViewController alloc] initWithNibName:@"TopThreeViewController" bundle:nil];
    topThreeView.trains = possibleStops;
    topThreeView.title = @"Trains";
    topThreeView.stopID=stopID;
    topThreeView.routeID=routeID;
    topThreeView.note = [NSString stringWithFormat:@"**Remaining** Trains For %@ \nRoute: %@", [self getDay], routeID];
    [self.navigationController pushViewController:topThreeView animated:YES];

}

- (NSString*) getDay
{
    NSDateFormatter* theDateFormatter = [[NSDateFormatter alloc] init];
    [theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [theDateFormatter setDateFormat:@"EEEE"];
    return [theDateFormatter stringFromDate:[NSDate date]];
    
}



-(void) loadRoute
{
    //NSString* filePath;// = [[NSBundle mainBundle] pathForResource:@”route” ofType:@”csv”];
    //NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
   // NSArray* pointStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray* pointStrings = [app getShapesForRoute: routeName];
    
    MKMapPoint northEastPoint = MKMapPointMake(0, 0);//(0,0);
    MKMapPoint southWestPoint = MKMapPointMake(0,0);
    
    MKMapPoint* pointArr = malloc(sizeof(MKMapPoint) * pointStrings.count);
    
    for(int idx = 0; idx < pointStrings.count; idx++)
    {
        NSString* currentPointString = [pointStrings objectAtIndex:idx];
        NSArray* latLonArr = [currentPointString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
        CLLocationDegrees latitude = [[latLonArr objectAtIndex:0] doubleValue];
        CLLocationDegrees longitude = [[latLonArr objectAtIndex:1] doubleValue];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        MKMapPoint point = MKMapPointForCoordinate(coordinate);
        
        if (idx == 0) {
            northEastPoint = point;
            southWestPoint = point;
        }
        else
        {
            if (point.x > northEastPoint.x)
                northEastPoint.x = point.x;
            if(point.y > northEastPoint.y)
                northEastPoint.y = point.y;
            if (point.x < southWestPoint.x)
                southWestPoint.x = point.x;
            if (point.y < southWestPoint.y)
                southWestPoint.y = point.y;
        }
        
        pointArr[idx] = point;
        
    }
    
    self.routeLine = [MKPolyline polylineWithPoints:pointArr count:pointStrings.count];
    
    _routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
   
    [self.myMapView setVisibleMapRect:_routeRect animated:YES];
    free(pointArr);
    
}

- (void) addStopAnnotations
{

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    annotationsToAdd = [[NSMutableArray alloc] init];
    for(id stopName in self.allRoutes)
    {
        
        NSString* stopNameStr = [NSString stringWithFormat:@"%@", stopName];
        double lat1 = 0.0;
        double lon1 = 0.0;
        NSMutableDictionary* coordDict = [app getCoordinateForStopName:stopName]; 
        for(id stopName in coordDict)
        {
            NSString* c = [coordDict objectForKey:stopName];
            NSArray* latLonArr = [c componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            
            lat1 = [[latLonArr objectAtIndex:0] doubleValue];
            lon1 = [[latLonArr objectAtIndex:1] doubleValue];
        }
        // Set some coordinates for our position
        CLLocationCoordinate2D loc1;
        
        loc1.latitude =  lat1;
        loc1.longitude = lon1;

        MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:stopNameStr andCoordinate:loc1];
       [annotationsToAdd addObject:newAnnotation];
    }
    [self.myMapView addAnnotations:self.annotationsToAdd];
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay
{
    MKOverlayView* overlayView = nil;
    
    if(overlay == self.routeLine)
    {
        //if we have not yet created an overlay view for this overlay, create it now.
        if(nil == self.routeLineView)
        {
            self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
            self.routeLineView.fillColor = self.navColor;// [UIColor redColor];
            self.routeLineView.strokeColor = self.navColor;//[UIColor redColor];
            self.routeLineView.lineWidth = 12;
        }
        
        overlayView = self.routeLineView;
        
    }
    
    return overlayView;
    
}


- (void) addCoordinateToMap:(CLLocationCoordinate2D) location withName:(NSString*) stopName
{

        
        MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:stopName andCoordinate:location];
        [self.myMapView addAnnotation:newAnnotation];
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{

   // NSLog(@"hello");
//    id <MKAnnotation>  annotation = view.annotation;
//    // if it's the user location, just return nil.
//    if ([annotation isKindOfClass:[MKUserLocation class]])
//        return;
//    NSString* str = [NSString stringWithFormat:@"%@", view.annotation.title];
//    if([str isEqualToString:@"You"])
//        return;
//    
//    self.locationLabel.hidden=NO;
//    self.locationLabel.text = str;
//    
//    [self performSelectorOnMainThread:@selector(updateTableItems:) withObject:str waitUntilDone:NO];
    
    
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MapViewAnnotation* annotation = (MapViewAnnotation*)view.annotation;

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSMutableArray* results = [app getStationDetails:annotation.title];
    
    
    StationDetailsController* stationView = [[StationDetailsController alloc] initWithNibName:@"StationDetailsController" bundle:nil];
    
    stationView.stationName = annotation.title;
    stationView.title = annotation.title;
    
    if([results count] >0)
    {
        stationView.stationDetails = results;
        [self.navigationController pushViewController:stationView animated:YES];
    }

    
    
}
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    

        // try to dequeue an existing pin view first
        static NSString* UserIdentifier = @"Stop";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
        [myMapView dequeueReusableAnnotationViewWithIdentifier:UserIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc]
                                                   initWithAnnotation:annotation reuseIdentifier:UserIdentifier];
            annotationView.pinColor = MKPinAnnotationColorRed;
            annotationView.animatesDrop = YES;
            annotationView.canShowCallout = YES;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//            [rightButton addTarget:self
//                            action:@selector(showStation:)
//                  forControlEvents:UIControlEventTouchUpInside];

          //  rightButton.titleLabel.text = annotation.title;
            
            annotationView.rightCalloutAccessoryView = rightButton;

            
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    return nil;
    
}




@end
