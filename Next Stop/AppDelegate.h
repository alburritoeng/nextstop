//
//  AppDelegate.h
//  Next Stop
//
//  Created by Alberto Martinez on 8/1/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteDetailsClass.h"
#import "Anemities.h"
#import "FMDatabase.h"  //FMDB stands for Flying Meat Database. What a great name…
#import "FMDatabaseAdditions.h"
//sqlite3 requires the linker (build phase) to be update with libsqlite3.dylib
//#include <sqlite3.h> //commented out because I am using FMDatabase.h -- it includes all required sqlite3

//version 3.2 - 4/25/2013 - updated with April 22, 2013 schedules
//Add All Routes Map
//Fixed bug with weekend showing same origin & destination (thanks Pep!)
//Added ability to show larger maps
//version 3.3 - 6/11/2013 -
//Fixes crashes seen on Alerts Tab -- Needed to update to  Twitter API to 1.1
//Added the "Review Next Stop in AppStore to Alerts page"
//version 3.4 - 8/19/2013 - fix issues with alert dates
//version 3.5 - 9/30/2013 - updated for the 9/30/13 schedules update by Metrolink
//                        - updated bike car list
//version 3.7 - 4/17/2014 - updated fro the 4/07/14 schedules updates by Metrolink
//                        - grouped trips 100-155 from BobHope Burbank route to ventura county line- annoying issues there

#define AppVersion          @"3.7"
@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>
{

    FMDatabase *db ;
    NSMutableDictionary* routeAndDirection;
    NSMutableDictionary* tripIdToShort;
    NSMutableDictionary* shortToTripId;
    NSMutableDictionary* shortToRouteId; //for deciding if Ventura Line should be shortened to VT
    NSMutableDictionary* stopNameAndStopId; //"Anaheim Canyon Metrolink Station", 82
    NSMutableDictionary* stopIDAndStopName; //82, "Anaheim Canyon Metrolink Station"
    NSMutableSet* bikeCars;  //key and object are the same... a StopID (682)
    
}


@property (nonatomic, retain) FMDatabase* db;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, retain) NSMutableDictionary* routeAndDirection;
@property (nonatomic, retain) NSMutableDictionary* tripIdToShort;
@property (nonatomic, retain) NSMutableDictionary* shortToTripId;
@property (nonatomic, retain) NSMutableDictionary* shortToRouteId;
@property (nonatomic, retain) NSMutableDictionary* stopNameAndStopId;
@property (nonatomic, retain) NSMutableDictionary* stopIDAndStopName;
@property (nonatomic, retain) NSMutableSet* bikeCars;





- (void) createDatabase;
- (void) createRoutesDBTable;
- (void) createTripsDBTable;
- (void) createStopsDBTable;
- (void) createShapesDBTable;
- (void) createStopTimesDBTable;
- (void) createCalendarDBTable;
- (void) createAnemitiesDBTable;
- (void) createDictionaryWithTripIDAndDirection;


- (NSString*) convertTimeToStandard:(NSString*) time;
- (void) setDay:(int) day;

- (NSMutableArray*) getAllRouteNames;
- (NSString*) getColorForRoute:(NSString*) routeName;
- (NSMutableArray*) getallTripShortNamesForRoute: (NSString*) routeName;
- (NSMutableDictionary*) getRouteIdAndTripHeadSignForRoute:(NSString*)routeName;
- (NSString*) getTripIdFromShortNumber:(NSString*)shortNum;
- (NSMutableArray*) getTimeAndLocationForRoute:(NSString*)routeID;
- (NSString*) getFriendNameForRouteID:(NSString*)routeID;
- (NSMutableSet*) getAllRouteStopsForLine:(NSString*)routeID;
- (NSString*) getStopIdFromFriendlyName:(NSString*) routeName;
- (NSArray*) getLowestStopOrderForStop:(NSString*) routeID;
- (NSMutableDictionary*) getNextThreeStopsForStopId:(NSString*) stopId andDirection:(NSInteger) directionID;
- (NSString*) getTitleHeadingForTripShortName:(NSString*) shortName;
- (NSString*) getFirstStopForTripShortName:(NSString*) shortName;
- (NSString*) getArrivalTimeForTrainNum:(NSString*)trainNum;
- (NSString*) getServiceIdFromTripId:(NSString*)tripId;
- (bool) doesTripRun:(NSString*) serviceid onThisDay:(int) day;
- (NSString*) getLastStopFromShortName:(NSString*) shortName;
- (NSMutableArray*) getRouteDetailsForRoute:(NSString*) shortName; //682
- (NSMutableArray*) getStopsForStopId:(NSString*) stopId;
- (NSMutableArray*) getStopsForStopId:(NSString*) stopId stripStops:(BOOL)strip;
- (NSMutableArray*) getStopsForStopId:(NSString*) stopId stripStops:(BOOL)strip forDay:(int)day;
- (NSMutableArray*) getStationDetails:(NSString*) stopID;
- (NSArray*) getShapesForRoute:(NSString*)routeID;
- (NSMutableDictionary*) getFiveStationsNear:(double) longitude andLat:(double)latitude;
- (NSMutableDictionary*) getCoordinateForStopName:(NSString*) stopName;

- (double) GetFareForTrip:(int) stopA withEnd:(int) stopB;
//broken method...
- (NSString*) getArrivalTimeForStopId:(NSString*)friendlyName withTripId:(NSString*) tripId;


@end
