//
//  MapViewAnnotation.m
//  MapDemo
//
//  Created by Alberto Martinez on 8/12/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation
@synthesize title, coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {

	title = ttl;
	coordinate = c2d;
	return self;
}



- (void)dealloc {
	
}

@end
