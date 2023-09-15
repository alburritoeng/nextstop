//
//  MapViewController.h
//  Next Stop
//
//  Created by Alberto Martinez on 8/12/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapViewAnnotation.h"
#import "AppDelegate.h"
#import "UserAnnotation.h"
#import "TestiPhoneCalViewController.h"

@interface MapViewController : UIViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    CLLocationManager *locationManager;
    AppDelegate * app;
    NSMutableArray* trains;
    NSMutableDictionary* ridesInDict;
    NSMutableArray* myIndex ;
    NSMutableArray* pickerItems;
    IBOutlet UIView *hiddenView;
    IBOutlet UIPickerView* myPickerView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    int distance;
    NSMutableDictionary* distanceAndStopName;
    NSMutableArray* stopNamesFound;
    TestiPhoneCalViewController* v ;
    IBOutlet UILabel *locLabel;
    CGRect originalMapRect;
    CGPoint originalCenter;
    
}
@property int distance;
@property CGRect originalMapRect;
@property CGPoint originalCenter;
@property (nonatomic, retain) NSMutableDictionary* distanceAndStopName;
@property (nonatomic, retain) IBOutlet UIPickerView *myPickerView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) NSMutableArray *pickerItems;
@property (nonatomic, retain) NSMutableDictionary* ridesInDict;
@property (nonatomic, retain) NSMutableArray* trains;
@property (nonatomic, retain) NSMutableArray* myIndex;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, retain)  CLLocationManager *locationManager;
@property (nonatomic, retain) AppDelegate* app;
@property(nonatomic, retain)  TestiPhoneCalViewController* v ;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSMutableArray* stopNamesFound;




- (void) updateTableItems:(NSArray *)argArray;
- (void) addCoordinateToMap:(CLLocationCoordinate2D) location withName:(NSString*) stopName;


- (void) mapViewReloadMap;
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view;
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
