//
//  UserAnnotation
//  MapDemo
//
//  Created by Alberto Martinez on 8/12/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import "UserAnnotation.h"

@implementation UserAnnotation
@synthesize title, coordinate, pinColor;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {

	title = ttl;
	coordinate = c2d;
	return self;
}

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d andColor:(MKPinAnnotationColor) color {
    
	title = ttl;
	coordinate = c2d;
    pinColor = color;
	return self;
}

// optional
//- (NSString *)subtitle
//{
//    return @"Founded: June 29, 1776";
//}

- (void)dealloc {
	
}

@end
