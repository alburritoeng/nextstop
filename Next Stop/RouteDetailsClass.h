//
//  RouteDetailsClass.h
//  Next Stop
//
//  Created by Alberto Martinez on 8/5/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteDetailsClass : NSObject
{
 
//    "trip_id","arrival_time","departure_time","stop_id","stop_sequence","stop_headsign","pickup_type","arrival_secs","departure_secs"
//    "294400173","06:30:00","06:30:00","131","1","Lancaster","0","23400","23400"
//    "294400173","06:41:00","06:41:00","98","2","Lancaster","0","24060","24060"
//    "294400173","06:47:00","06:47:00","86","3","Lancaster","0","24420","24420"
//    "294400173","06:52:00","06:52:00","128","4","Lancaster","0","24720","24720"
//    "294400173","06:59:00","06:59:00","129","5","Lancaster","0","25140","25140"
//    "294400173","07:18:00","07:18:00","107","6","Lancaster","0","26280","26280"
//    "294400173","07:25:00","07:25:00","126","7","Lancaster","0","26700","26700"
//    "294400173","07:31:00","07:31:00","117","8","Lancaster","0","27060","27060"
//    "294400173","08:10:00","08:10:00","134","9","Lancaster. ATTN: Train may leave up to five minutes ahead of schedule.","0","29400","29400"
//    "294400173","08:20:00","08:20:00","114","10","Lancaster. ATTN: Train may leave up to five minutes ahead of schedule.","0","30000","30000"
//    "294400173","08:40:00","08:40:00","102","11","Lancaster","0","31200","31200"
    
    NSString* tripId; //the long form of 682 -- 204400173
    NSString* departureTime;
    NSString* stopSequence;
    NSString* stopId;
    NSString* pickupType; //gives warnings if can leave early or ahead of schedule
    
}

@property (nonatomic, retain) NSString* tripId;
@property (nonatomic, retain) NSString* departureTime;
@property (nonatomic, retain) NSString* stopSequence;
@property (nonatomic, retain) NSString* stopId;
@property (nonatomic, retain) NSString* pickupType;






@end
