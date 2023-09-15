//
//  MapAllRoutesViewController.m
//  Next Stop
//
//  Created by Alberto Martinez on 4/23/13.
//  Copyright (c) 2013 Alberto Martinez. All rights reserved.
//
#import "AppDelegate.h"
#import "MapAllRoutesViewController.h"
#import "MapViewController.h"
#import "TopThreeViewController.h"

@interface MapAllRoutesViewController ()

@end

@implementation MapAllRoutesViewController
@synthesize _routeRect, RouteNamesArray;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    RouteNamesArray = [[NSArray alloc] initWithObjects:@"91 Line", @"Antelope Valley Line", @"Burbank-Bob Hope Airport", @"Inland Emp.-Orange Co. Line", @"Orange County Line", @"Riverside Line", @"San Bernardino Line", @"Ventura County Line", nil];
    
    UIBarButtonItem *showStops = [[UIBarButtonItem alloc] initWithTitle:@"Show Stops" style:UIBarButtonItemStyleBordered target:self  action:@selector(showStops)];
    
    self.navigationItem.rightBarButtonItem = showStops;
    [self LoadRoute];

    
    [super viewDidLoad];

}

- (void) showStops
{
    
    if([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Show Stops"])
    {
        self.navigationItem.rightBarButtonItem.title = @"Hide Stops";
        
        [self LoadAnnotations];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = @"Show Stops";
        [self.myMapView removeAnnotations:self.myMapView.annotations];
    }
        
    
    
}
- (void) LoadAnnotations
{
    
    //[self removeAllAnnotations];
    double defaultLong =-118.23;
    double defaultLat =  34.06;

    AppDelegate * app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary* stopsIDDict = [app getFiveStationsNear:0.0 andLat:0.0];
    
    double latitude = defaultLat;
    double longitude = defaultLong;
    
    // Set some coordinates for our position
    CLLocationCoordinate2D myLocation;
    
    myLocation.latitude = latitude;
    myLocation.longitude = longitude;
    
    NSMutableArray* annotationsToAdd = [[NSMutableArray alloc] init];
    for(id stopName in stopsIDDict)
    {
        
        NSString* stopNameStr = [NSString stringWithFormat:@"%@", stopName];
        double lat1 = 0.0;
        double lon1 = 0.0;
        NSMutableDictionary* coordDict = [stopsIDDict objectForKey:stopName];
        for(id lat in coordDict)
        {
            lat1 = [lat doubleValue];
            lon1 = [[coordDict objectForKey:lat] doubleValue];
            
        }
        
        // Set some coordinates for our position
        CLLocationCoordinate2D loc1;
        
        loc1.latitude =  lon1;
        loc1.longitude = lat1;

        MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:stopNameStr andCoordinate:loc1];
        [annotationsToAdd addObject:newAnnotation];

    }
    
    [self.myMapView addAnnotations:annotationsToAdd];
}


-(void) LoadRoute
{

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MKMapPoint northEastPoint;
    MKMapPoint southWestPoint;
    
    for(int i=0; i< [RouteNamesArray count]; i++)
    {
        NSString* routeName = [RouteNamesArray objectAtIndex:i];
    
        NSArray* pointStrings = [app getShapesForRoute: routeName];
    
       
    
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
        MKPolyline* routeLine;
        routeLine = [MKPolyline polylineWithPoints:pointArr count:pointStrings.count];
        routeLine.title = routeName;
        //NSLog(@"%f %f, %f %f", southWestPoint.x, southWestPoint.y, northEastPoint.x, northEastPoint.y);
        //_routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
        
        //[self.myMapView setVisibleMapRect:_routeRect animated:YES];
        [self.myMapView addOverlay:routeLine];
        free(pointArr);
    }
    
    [self zoomToFitMapAnnotations:self.myMapView];
}

- (void)zoomToFitMapAnnotations:(MKMapView *)mapView {
    if ([mapView.overlays count] == 0) return;
    
    double defaultLong =-118.23;
    double defaultLat =  34.06;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = defaultLat;//-90;
    topLeftCoord.longitude = defaultLong;// 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKOverlay> overlay in mapView.overlays) {
        
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, [overlay coordinate].longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, [overlay coordinate].latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, [overlay coordinate].longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, [overlay coordinate].latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    
    // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    //MKPolyline *pl = <MKPolyline> overlay;
    //MKPolyline *pl = [overlay.polyline];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MKPolylineView *pv = [[MKPolylineView alloc] initWithPolyline:overlay];
    
    
    pv.fillColor = [self colorWithHexString:[app getColorForRoute:     pv.polyline.title  ]];//[UIColor redColor];
    pv.strokeColor = [self colorWithHexString:[app getColorForRoute:     pv.polyline.title  ]];//[UIColor redColor];
    pv.lineWidth = 12;
    return pv;
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

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MapViewAnnotation* annotation = (MapViewAnnotation*)view.annotation;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSString* stopID;
    NSString* routeID;
    stopID=  [app.stopNameAndStopId objectForKey:annotation.title];
    routeID = annotation.title;

    NSMutableArray* possibleStops = [app getStopsForStopId:stopID stripStops:NO];
    
    TopThreeViewController *topThreeView = [[TopThreeViewController alloc] initWithNibName:@"TopThreeViewController" bundle:nil];
    topThreeView.trains = possibleStops;
    topThreeView.title = @"Trains";
    topThreeView.stopID=stopID;
    topThreeView.note = [NSString stringWithFormat:@"**All** stops %@", routeID];
    [self.navigationController pushViewController:topThreeView animated:YES];

}


+ (CGFloat)annotationPadding;
{
    return 10.0f;
}
+ (CGFloat)calloutHeight;
{
    return 40.0f;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    
    static NSString* UserIdentifier = @"Stop";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)
    [self.myMapView dequeueReusableAnnotationViewWithIdentifier:UserIdentifier];
    if (!pinView)
    {
        // if an existing pin view was not available, create one
        MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc]
                                               initWithAnnotation:annotation reuseIdentifier:UserIdentifier];
        
        
//        UIImage *flagImage = [UIImage imageNamed:@"trains.png"];
//        
//        CGRect resizeRect;
//        
//        resizeRect.size = CGSizeMake(32,32);// flagImage.size;
//        CGSize maxSize = CGRectInset(self.view.bounds,
//                                     [MapAllRoutesViewController annotationPadding],
//                                     [MapAllRoutesViewController annotationPadding]).size;
//        maxSize.height -= self.navigationController.navigationBar.frame.size.height + [MapAllRoutesViewController calloutHeight];
//        if (resizeRect.size.width > maxSize.width)
//            resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
//        if (resizeRect.size.height > maxSize.height)
//            resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
//        
//        resizeRect.origin = (CGPoint){0.0f, 0.0f};
//        UIGraphicsBeginImageContext(resizeRect.size);
//        [flagImage drawInRect:resizeRect];
//        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        annotationView.image = resizedImage;
        
        
        
        
        annotationView.canShowCallout = YES;
  
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.rightCalloutAccessoryView = rightButton;

        return annotationView;
    }
    else
    {
        pinView.annotation = annotation;
    }
    return pinView;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
