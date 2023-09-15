//
//  TripsForRoute.h
//  trains
//
//  Created by Alberto Martinez on 7/29/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapViewAnnotation.h"
#import "UserAnnotation.h"


@interface TripsForRoute : UIViewController <UITableViewDataSource, UITableViewDelegate,MKMapViewDelegate >
{
    NSString* routeName;
    NSArray* allRoutes;
    NSMutableDictionary *routeIdAndHeadsign;
    UIColor *navColor;
    NSArray* shapeData;
    //IBOutlet MKMapView *myMapView;
    IBOutlet UITableView *myTableView;
    MKPolyline* routeLine;
    MKPolylineView *routeLineView;
    MKMapRect _routeRect;
    NSMutableArray* annotationsToAdd;
    IBOutlet UILabel *locLabel;
    
    //for expanding mapview
    CGRect originalMapRect;
    CGPoint originalCenter;
}
@property CGRect originalMapRect;
@property CGPoint originalCenter;
@property(nonatomic, retain) NSMutableArray* annotationsToAdd;
@property MKMapRect _routeRect;
@property(nonatomic, retain) MKPolylineView *routeLineView;
@property(nonatomic, retain)    MKPolyline* routeLine;
@property(nonatomic, retain) NSString* routeName;
@property(nonatomic, retain) NSArray* shapeData;
@property(nonatomic, retain) IBOutlet UITableView *myTableView;
@property(nonatomic, retain) IBOutlet MKMapView *myMapView;
@property(nonatomic, retain)NSArray*allRoutes;
@property(nonatomic, retain) NSMutableDictionary *routeIdAndHeadsign;
@property(nonatomic, retain) UIColor* navColor;


- (void) addStopAnnotations;
- (void) loadRoute;
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay;


//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
- (void) addCoordinateToMap:(CLLocationCoordinate2D) location withName:(NSString*) stopName;
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation;

@end
