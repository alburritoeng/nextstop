//
//  Anemities.h
//  Next Stop
//
//  Created by Alberto Martinez on 8/16/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Anemities : NSObject
{
    BOOL bathroom;
    BOOL parking;
    BOOL parkingFee;
    BOOL bikeRack;
    NSString* contact;
    
}
@property BOOL bathroom;
@property BOOL parking;
@property BOOL parkingFee;
@property BOOL bikeRack;
@property (nonatomic, copy) NSString* contact;


@end
