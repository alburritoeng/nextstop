//
//  Anemities.m
//  Next Stop
//
//  Created by Alberto Martinez on 8/16/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import "Anemities.h"

@implementation Anemities

@synthesize bathroom, parking, parkingFee, bikeRack, contact;


- (id)initWithData:(BOOL) restroom andParking:(BOOL)parkingLot andFee: (BOOL) fee andBike:(BOOL) rack andContact:(NSString*)phone
{
    
    bathroom = restroom;
    parking = parkingLot;
    parkingFee = fee;
    bikeRack = rack;
    contact = phone;
	return self;
}


@end
