//
//  MapAllRoutesViewController.h
//  Next Stop
//
//  Created by Alberto Martinez on 4/23/13.
//  Copyright (c) 2013 Alberto Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapAllRoutesViewController : UIViewController<MKMapViewDelegate>
{

 MKMapRect _routeRect;
 NSArray* RouteNamesArray;

}
@property MKMapRect _routeRect;
@property(nonatomic, retain) IBOutlet MKMapView *myMapView;
@property(nonatomic, retain) NSArray* RouteNamesArray;


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;


@end
