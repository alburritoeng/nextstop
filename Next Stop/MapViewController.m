//
//  MapViewController.m
//  Next Stop
//
//  Created by Alberto Martinez on 8/12/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import "MapViewController.h"
#import "RouteStopsViewController.h"
#import "StationDetailsController.h"

@interface MapViewController ()

@end

@implementation MapViewController
@synthesize activityIndicator;
@synthesize mapView;
@synthesize myTableView;
@synthesize locationManager;
@synthesize app;
@synthesize pickerItems;
@synthesize trains;
@synthesize ridesInDict;
@synthesize myIndex;
@synthesize myPickerView;
@synthesize locationLabel;
@synthesize distance;
@synthesize stopNamesFound;
@synthesize distanceAndStopName;
@synthesize v;//calendar view controller...
@synthesize originalMapRect, originalCenter;
double defaultLong =-118.23;
double defaultLat =  34.06;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Near", @"Near");
        self.tabBarItem.image = [UIImage imageNamed:@"antenna"];
       app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        UIBarButtonItem *filterBtn = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self  action:@selector(filterChoices:)];
        //self.navigationItem.leftBarButtonItem = filterBtn;
        
        UIImage* image = nil;
        float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (ver >= 7.0) {
            image = [UIImage imageNamed:@"enlarge_icon3.png"];
        }
        else{
            image = [UIImage imageNamed:@"enlarge_icon.png"];
        }
        UIBarButtonItem *expandMapBtn = [[UIBarButtonItem alloc] initWithImage:image landscapeImagePhone:image style:UIBarButtonItemStyleBordered target:self action:@selector(expandMap:)];
        //[expandMapBtn setTintColor:[UIColor whiteColor]];
        //UIBarButtonItem *expandMapBtn = [[UIBarButtonItem alloc] initWithTitle:@"<>" style:UIBarButtonItemStyleBordered target:self  action:@selector(expandMap:)];
        //self.navigationItem.rightBarButtonItem = explandMapBtn;
         
        
        originalCenter = CGPointMake(0,0);
        
        
        UIBarButtonItem *chooseDayBtn = [[UIBarButtonItem alloc] initWithTitle:@"Day" style:UIBarButtonItemStyleBordered target:self  action:@selector(showCalendar)];
        //self.navigationItem.rightBarButtonItem =chooseDayBtn;;
        
        NSArray *tempArray = [[NSArray alloc] initWithObjects:filterBtn,chooseDayBtn, nil];
        self.navigationItem.rightBarButtonItem = expandMapBtn;
        self.navigationItem.leftBarButtonItems = tempArray;
        
        v = [[TestiPhoneCalViewController alloc] initWithNibName:@"TestiPhoneCalViewController" bundle:nil];
        v.m_day = -1;
        
        
        [self hidePicker];
        distanceAndStopName = [[NSMutableDictionary alloc] init];
        pickerItems = [[NSMutableArray alloc] init];
        [pickerItems addObject:@"5 miles"];
        [pickerItems addObject:@"10 miles"];
        [pickerItems addObject:@"All Stations"];
       
        self.myPickerView.delegate = self;
        self.myPickerView.hidden=NO;
        self.myPickerView.dataSource = self;
        stopNamesFound = [[NSMutableArray alloc] init];
        [hiddenView addSubview:myPickerView];
        distance = 6400;
        
               
    }
    return self;
}

- (NSString*) getStringFromDayInt:(int)day
{
    
    switch (day) {
        case 0:
            return @"Monday";
            break;
        case 1:
            return @"Tuesday";
            break;
        case 2:
            return @"Wednesday";
            break;
        case 3:
            return @"Thursday";
            break;
        case 4:
            return @"Friday";
            break;
        case 5:
            return @"Saturday";
            break;
        case 6:
            return @"Sunday";
            
            
        default:
            return @"Monday";
            break;
    }
    
}



- (void) showCalendar
{
    
    v.m_day = -1;
    [self.navigationController presentViewController:v animated:YES completion:nil];
    self.navigationItem.leftBarButtonItem.title = @"Filter";
}

- (IBAction)expandMap:(id)sender
{
    
    if(originalCenter.x==0 && originalCenter.y==0)
    {
        originalCenter = self.mapView.center;
        originalMapRect = self.mapView.frame;
    }
    //NSLog(@"%@", self.mapView);
    //NSLog(@"mapViewCenter X and Y are %f and %f ", self.mapView.center.x, self.mapView.center.y);
    if(!self.myTableView.hidden)
    {
        [self.mapView setFrame:self.view.bounds];
        myTableView.hidden=true;
        locLabel.hidden=true;
    }
    else
    {
        [self.mapView setFrame:originalMapRect];
        [self.mapView setCenter:originalCenter];
        myTableView.hidden=false;
        locLabel.hidden=false;
    }

    
}
- (void) RestoreMap
{
    [self.mapView setFrame:originalMapRect];
    [self.mapView setCenter:originalCenter];
    myTableView.hidden=false;
    locLabel.hidden=false;
}
- (IBAction)filterChoices:(id)sender
{
    if([self.navigationItem.leftBarButtonItem.title isEqualToString:@"Filter"])
    {
        [self showPicker];
        self.navigationItem.leftBarButtonItem.title = @"Done";
         
    }
    else
    {
        [self hidePicker];
        self.navigationItem.leftBarButtonItem.title = @"Filter";
        
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    trains = [[NSMutableArray alloc] init];
    myIndex = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view from its nib.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = 5; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 100 m
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
   
    originalMapRect = self.mapView.frame;
    //NSLog(@"init %@", self.mapView);
    //NSLog(@"mapViewCenter X and Y are %f and %f ", self.mapView.center.x, self.mapView.center.y);
    
}


- (void) removeAllAnnotations
{
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    [stopNamesFound removeAllObjects];
}

- (void) showPicker
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:ctx];
	[UIView setAnimationDuration:.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGRect fullScreenRect = [[UIScreen mainScreen] bounds];
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (ver >= 7.0) {
        hiddenView.frame = CGRectMake(0, fullScreenRect.size.height-250, 320, 200);
    }
    else
        hiddenView.frame = CGRectMake(0, fullScreenRect.size.height-285, 320, 200);
    [UIView commitAnimations];
}
- (void) hidePicker
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:ctx];
	[UIView setAnimationDuration:.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    CGRect fullScreenRect = [[UIScreen mainScreen] bounds];
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (ver >= 7.0) {
        hiddenView.frame = CGRectMake(0, fullScreenRect.size.height+50, 320, 116);
    }
    else
        hiddenView.frame = CGRectMake(0, fullScreenRect.size.height, 320, 116);
    [UIView commitAnimations];
    
    
   
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        return YES;
    }
    return NO;
    
}
- (void) mapViewReloadMap
{
 
    [self removeAllAnnotations];
    NSMutableDictionary* stopsIDDict = [app getFiveStationsNear:0.0 andLat:0.0];
    
    double latitude = (double)locationManager.location.coordinate.latitude;
    double longitude = (double)locationManager.location.coordinate.longitude;
    if(([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorized) ||
      ( latitude==0.0 && longitude==0.0))
    {
        //34.054291","-118.234299
        latitude = defaultLat;
        longitude = defaultLong;
        
    }
    // Set some coordinates for our position
    CLLocationCoordinate2D myLocation;
  
    myLocation.latitude = latitude;//(double) 51.501468;
    myLocation.longitude = longitude;//(double) -0.141596;
    [distanceAndStopName removeAllObjects];
    // Add the annotation to our map view
    [self addCoordinateToMap:myLocation withName:@"You"];
    
    
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
    
        CLLocation* stopLocation = [[CLLocation alloc] initWithCoordinate:loc1
                                                                 altitude:0.0
                                                       horizontalAccuracy:10.0
                                                         verticalAccuracy:10.0
                                                                   course:0
                                                                    speed:0.0
                                                                timestamp:[NSDate date]];
        
        if(distance==0 || ([locationManager.location distanceFromLocation: stopLocation] < distance)) //less than 4 miles
        {
            MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:stopNameStr andCoordinate:loc1];
            [annotationsToAdd addObject:newAnnotation];
            [stopNamesFound addObject:stopNameStr];
            [distanceAndStopName setObject:stopNameStr forKey:[NSNumber numberWithInt:[locationManager.location distanceFromLocation: stopLocation]]];
        }
    }
    
    [self.mapView addAnnotations:annotationsToAdd];
    
    MKMapRect zoomRect = MKMapRectNull;
    for(id<MKAnnotation> annotation in self.mapView.annotations)
    {
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate );
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0 );
        if(MKMapRectIsNull(zoomRect))
        {
            zoomRect = pointRect;
        }
        else
        {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }

    [self.mapView setVisibleMapRect:zoomRect animated:YES];

    
}
- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self mapViewReloadMap];
    [self hidePicker];

    
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self selectFirstEntry];
    [super viewDidAppear:animated];
}
- (void) addCoordinateToMap:(CLLocationCoordinate2D) location withName:(NSString*) stopName
{
    if([stopName isEqualToString:@"You"])
    {
        
        UserAnnotation *newAnnotation = [[UserAnnotation alloc] initWithTitle:stopName andCoordinate:location andColor:MKPinAnnotationColorGreen];
        [self.mapView addAnnotation:newAnnotation];
    }
    else
    {
        
        MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:stopName andCoordinate:location];
        [self.mapView addAnnotation:newAnnotation];
    }

}

+ (CGFloat)annotationPadding;
{
    return 10.0f;
}
+ (CGFloat)calloutHeight;
{
    return 40.0f;
}

- (void) selectFirstEntry
{
    if([stopNamesFound count ] == 0)
        return;
    
    NSArray* sortedStopNames = [stopNamesFound sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableString* loc1 = [[NSMutableString alloc] init];
    [loc1 setString:[NSString stringWithFormat:@"%@", [sortedStopNames objectAtIndex:0]]];
    
    if([loc1 isEqualToString:@"You"])
    {
        if([sortedStopNames count] > 1)
        [loc1 setString:[NSString stringWithFormat:@"%@", [sortedStopNames objectAtIndex:1]]];
    }
    NSString* stopID = [app.stopNameAndStopId objectForKey:loc1];
    
    NSMutableArray* possibleStops;
    if(v.m_day==-1)
        possibleStops = [app getStopsForStopId:stopID stripStops:YES];
    else if(v.m_day == -2)
    {
        possibleStops = [app getStopsForStopId:stopID stripStops:YES];
    }
    else
    {
        possibleStops = [app getStopsForStopId:stopID stripStops:NO forDay:v.m_day];
        
    }
    
    if([possibleStops count] < 2)
        possibleStops = [app getStopsForStopId:stopID stripStops:NO];
    self.trains = possibleStops;
    [ridesInDict removeAllObjects];
    [myIndex removeAllObjects];
    myIndex = [[NSMutableArray alloc] init];
    ridesInDict = [[NSMutableDictionary alloc] init];
    for(NSString* s in self.trains)
    {
        NSArray* entry = [s componentsSeparatedByString:@","];
        //NSLog(@"%@    and    %@", [entry objectAtIndex:0], [entry objectAtIndex:1]);
        [myIndex addObject:[entry objectAtIndex:0]];
        [self.ridesInDict setObject:[entry objectAtIndex:1] forKey:[entry objectAtIndex:0]];
        
    }
    
    [self.myTableView reloadData];
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorized)
    {
        //distanceAndStopName
        NSMutableArray* distanceArray = [[NSMutableArray alloc] initWithCapacity:[distanceAndStopName count] ];
        for(id distanceKey in distanceAndStopName)
        {
            [distanceArray addObject:distanceKey];
            //NSLog(@"%@", distanceKey);
        }
        NSArray* sortedDistanceArray = [distanceArray sortedArrayUsingSelector:@selector(compare:)];
   
        NSString* shortestDistance = [NSString stringWithFormat:@"%@", [sortedDistanceArray objectAtIndex:0]];
        NSNumber* numberDistance = [NSNumber numberWithInt:[shortestDistance intValue]];
        NSString* firstStop = [distanceAndStopName objectForKey:numberDistance ];
        //NSLog(@"%@", distanceAndStopName);
        //NSLog(@"distance from ME = %f", [numberDistance doubleValue]*0.000621371);
        for(int i = 0; i < [self.mapView.annotations count]; i++)
        {
            MapViewAnnotation * annon = [self.mapView.annotations objectAtIndex:i];
            if([annon.title isEqualToString:firstStop])
            {
                [self.mapView selectAnnotation:[self.mapView.annotations objectAtIndex:i] animated:YES];
                self.locationLabel.hidden=NO;
                self.locationLabel.text = firstStop;
                locLabel.text = firstStop;
                
                break;
            }
        }
    }
 
    
}


- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    MapViewAnnotation* annotation = (MapViewAnnotation*)view.annotation;
    NSMutableArray* results = [app getStationDetails:annotation.title];
        
    StationDetailsController* stationView = [[StationDetailsController alloc] initWithNibName:@"StationDetailsController" bundle:nil];
        
    //NSLog(@"distance from ME = %f", [numberDistance doubleValue]*0.000621371);
    stationView.stationName = annotation.title;
    stationView.title = annotation.title;
    
    if([results count] >0)
    {
        stationView.stationDetails = results;
        [self.navigationController pushViewController:stationView animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  110;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
    id <MKAnnotation>  annotation = view.annotation;
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return;
    NSString* str = [NSString stringWithFormat:@"%@", view.annotation.title];
    if([str isEqualToString:@"You"])
        return;
    
    self.locationLabel.hidden=NO;
    self.locationLabel.text = str;
    locLabel.text = str;
    [self performSelectorOnMainThread:@selector(updateTableItems:) withObject:str waitUntilDone:NO];
    
 
}


- (NSString*) getDay
{
    NSDateFormatter* theDateFormatter = [[NSDateFormatter alloc] init];
    [theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [theDateFormatter setDateFormat:@"EEEE"];
    return [theDateFormatter stringFromDate:[NSDate date]];
    
}

-(void) updateTableItems:(id)argArray
{
    NSString* ar = (NSString*)argArray;
    
    NSString*str = [NSString stringWithFormat:@"%@", ar];

    [activityIndicator startAnimating];
    
    NSString* stopID = [app.stopNameAndStopId objectForKey:str]; //view.annotation.title];
    
    NSMutableArray* possibleStops;
    if(v.m_day==-1)
    {
        possibleStops = [app getStopsForStopId:stopID stripStops:YES];
        NSArray* arr = self.navigationItem.leftBarButtonItems;
        UIBarButtonItem * btn = [arr objectAtIndex:1];
        btn.title = [self getDay];
        //self.navigationItem.rightBarButtonItem.title = [self getDay];
    }
    else if(v.m_day==-2)
    {
        NSArray* arr = self.navigationItem.leftBarButtonItems;
        UIBarButtonItem * btn = [arr objectAtIndex:1];
        btn.title = [self getDay];
        //self.navigationItem.rightBarButtonItem.title = [self getDay];
        possibleStops = [app getStopsForStopId:stopID stripStops:YES];

    }
    else
    {
        NSArray* arr = self.navigationItem.leftBarButtonItems;
        UIBarButtonItem * btn = [arr objectAtIndex:1];
        btn.title = [self getStringFromDayInt:v.m_day];
        //self.navigationItem.rightBarButtonItem.title = [self getStringFromDayInt:v.m_day];
        possibleStops = [app getStopsForStopId:stopID stripStops:NO forDay:v.m_day];
    }
    if([possibleStops count] < 2)
        possibleStops = [app getStopsForStopId:stopID stripStops:NO];
    
    self.trains = possibleStops;
    [ridesInDict removeAllObjects];
    [myIndex removeAllObjects];
    myIndex = [[NSMutableArray alloc] init];
    ridesInDict = [[NSMutableDictionary alloc] init];
    for(NSString* s in self.trains)
    {
        NSArray* entry = [s componentsSeparatedByString:@","];
        //NSLog(@"%@    and    %@", [entry objectAtIndex:0], [entry objectAtIndex:1]);
        [myIndex addObject:[entry objectAtIndex:0]];
        [self.ridesInDict setObject:[entry objectAtIndex:1] forKey:[entry objectAtIndex:0]];
        
    }
    
    [self.myTableView reloadData];
    
    
    [activityIndicator stopAnimating];
    
}




- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // handle our two custom annotations
    //
    if ([annotation isKindOfClass:[UserAnnotation class]]) 
    {
        // try to dequeue an existing pin view first
        static NSString* UserIdentifier = @"User";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:UserIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:UserIdentifier];
            annotationView.canShowCallout = YES;
            
            UIImage *flagImage = [UIImage imageNamed:@"flag.png"];
            
            CGRect resizeRect;
            
            resizeRect.size = flagImage.size;
            CGSize maxSize = CGRectInset(self.view.bounds,
                                         [MapViewController annotationPadding],
                                         [MapViewController annotationPadding]).size;
            maxSize.height -= self.navigationController.navigationBar.frame.size.height + [MapViewController calloutHeight];
            if (resizeRect.size.width > maxSize.width)
                resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
            if (resizeRect.size.height > maxSize.height)
                resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
            
            resizeRect.origin = (CGPoint){0.0f, 0.0f};
            UIGraphicsBeginImageContext(resizeRect.size);
            [flagImage drawInRect:resizeRect];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            annotationView.image = resizedImage;
            annotationView.opaque = NO;
            //annotationView.canShowCallout = YES;
            //annotationView.rightCalloutAccessoryView
            //UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFIcon.png"]];
            //annotationView.leftCalloutAccessoryView = sfIconView;
           // [sfIconView release];
            
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;

    }
    else
    {
        // try to dequeue an existing pin view first
        static NSString* UserIdentifier = @"Stop";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:UserIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc]
                                                   initWithAnnotation:annotation reuseIdentifier:UserIdentifier];
            annotationView.pinColor = MKPinAnnotationColorPurple;
            annotationView.animatesDrop = YES;
            annotationView.canShowCallout = YES;
            //annotationView.canShowCallout = YES;

            
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            //rightButton.backgroundColor = [UIColor whiteColor];
            annotationView.rightCalloutAccessoryView = rightButton;

            
            
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
        
        
        
    }
    
    
    
     return nil;
    
}





- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *returnStr = @"";
	
	// note: custom picker doesn't care about titles, it uses custom views
	//if (pickerView == myPickerView)
		returnStr = [pickerItems objectAtIndex:row];
    
	return returnStr;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [pickerItems count];//0;//[stopNames count];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
//    NSString* val = [NSString stringWithFormat:@"%@ ",
//                                                      [pickerItems objectAtIndex:[pickerView selectedRowInComponent:0]]];

   // NSLog(@"%@", val);
        
    if(row == 0)
        distance = 8000;
    else if(row == 1)
        distance = 16000;
    else
        distance = 0;
    
    [self mapViewReloadMap];
  //  NSLog(@"%@", val);
    
}



- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setMyTableView:nil];
    myPickerView = nil;
    activityIndicator= nil;
    [self setLocationLabel:nil];
    locLabel = nil;
    [super viewDidUnload];
       
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.myIndex count]==0)
        return 1;
    return [self.myIndex count];
    
}


- (NSString*) convertTimeToStandard:(NSString*) time
{
    //dumb data-- check if the data is >25 first
    NSArray *array = [time componentsSeparatedByString: @":"];
    NSInteger hour = [[array objectAtIndex:0] intValue];
    if(hour >=24)
    {
        hour = hour-24;
        if(hour==0) //if we have a time with 24, set it to midnight
            hour=12;
        return [ NSString stringWithFormat:@"%d:%@:%@ AM", hour, [array objectAtIndex:1], [array objectAtIndex:2]];
        
    }
    
    //[[routeAndDirection objectForKey:stopid] intValue];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *trainTime = [formatter dateFromString:time];
    
    
    NSCalendar *calendar =[NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit ) fromDate:trainTime];
    
    if(([dateComponents hour]-12) >0)
    {
        [dateComponents setHour:[dateComponents hour]-12];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        //NSLog(@"%d",[dateComponents hour] );
        //NSLog(@"%@",[dateComponents date] );
        NSDate *trianInfo = [calendar dateFromComponents:dateComponents];
        NSString *trainTime = [formatter stringFromDate:trianInfo];
        
        
        return [NSString stringWithFormat:@"%@ PM", trainTime];
    }
    else if(([dateComponents hour]-12) ==0)  //noon
            return [NSString stringWithFormat:@"%@ PM", time];

        return [NSString stringWithFormat:@"%@ AM", time];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    if([myIndex count] == 0)
    {
        cell.textLabel.text = @"No more trains available today...";
        cell.imageView.image = nil;
        cell.detailTextLabel.text = @"Select a different station";
        cell.detailTextLabel.numberOfLines = 1;
        cell.accessoryType =UITableViewCellAccessoryNone;
        return cell;
    }
    NSInteger row = indexPath.row;
    //NSString* titleHeading = [app getTitleHeadingForTripShortName:[myIndex objectAtIndex:row]];
    NSString* titleHeading =  [app getLastStopFromShortName:[myIndex objectAtIndex:row]];
    
    
    NSString* time = [NSString stringWithFormat:@"%@", [self convertTimeToStandard:[ridesInDict objectForKey:[myIndex objectAtIndex:row]]]];
    NSString* headingTo = [NSString stringWithFormat:@"%@", titleHeading];
    
    
    NSString* trainNum = [NSString stringWithFormat:@"%@", [myIndex objectAtIndex:row]];
    NSString* startingFrom = [NSString stringWithFormat:@"%@", [app getFirstStopForTripShortName:trainNum]];
    NSString* arrival_time = [ NSString stringWithFormat:@"%@", [app getArrivalTimeForTrainNum:trainNum]];
    
    
    assert(![startingFrom isEqualToString:headingTo]);
    
    //heading to
    NSString* ID = [NSString stringWithFormat:@"%@", [app.shortToRouteId objectForKey:trainNum]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ @ %@",ID, trainNum, time];
    cell.detailTextLabel.numberOfLines = 4;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Headed to %@ from %@ scheduled to arrive in %@ at %@", headingTo, startingFrom, headingTo, [self convertTimeToStandard:arrival_time]];

    NSLog(@"%@",[self convertTimeToStandard:arrival_time]);
    //BIKE CARS!!!!
    if([app.bikeCars containsObject:trainNum])
    {
        cell.imageView.image = [UIImage imageNamed:@"bike-icon.png"];
        cell.detailTextLabel.numberOfLines = 5;
    }
    else
    {
        cell.imageView.image= nil;
         cell.detailTextLabel.numberOfLines = 4;
    }
    //bike-icon.png
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([self.myIndex count]==0)
        return;
    RouteStopsViewController* view = [[RouteStopsViewController alloc] initWithNibName:@"RouteStopsViewController" bundle:nil];
    NSString* routeName = [self.myIndex objectAtIndex:indexPath.row];
    //this will be in the format short name, for example "682"
    //let the viewcontroller query the route details
    view.routeID = routeName;
    NSString* ID = [NSString stringWithFormat:@"%@", [app.shortToRouteId objectForKey:routeName]];
    view.title = [NSString stringWithFormat:@"%@ %@", ID, routeName];
    [self.navigationController pushViewController:view animated:YES];
    
}


- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    for(int i = 0; i < [self.mapView.annotations count]; i++)
    {
        MapViewAnnotation * annon = [self.mapView.annotations objectAtIndex:i];
        if([annon.title isEqualToString:@"You"])
        {
            [self.mapView removeAnnotation:[self.mapView.annotations objectAtIndex:i]];
        }
    }
    
    double latitude = (double)newLocation.coordinate.latitude;
    double longitude = (double)newLocation.coordinate.longitude;
    if([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorized)
    {
        //34.054291","-118.234299
        latitude = defaultLat;
        longitude = defaultLong;
        
    }
    // Set some coordinates for our position
    CLLocationCoordinate2D myLocation;
    myLocation.latitude = latitude;//(double) 51.501468;
    myLocation.longitude = longitude;//(double) -0.141596;
    // Add the annotation to our map view
    [self addCoordinateToMap:myLocation withName:@"You"];
    
    

    
    
    
}


@end
