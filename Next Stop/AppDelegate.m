//
//  AppDelegate.m
//  Next Stop
//
//  Created by Alberto Martinez on 8/1/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import "AppDelegate.h"

#import "RoutesViewController.h"

#import "StationsViewController.h"
#import "AlertsViewController.h"
#import "TripViewController.h"
#import "MapViewController.h"

#import <sys/xattr.h>   //to prevent this file to be backedup to the iCloud!!!


@implementation AppDelegate
@synthesize db, routeAndDirection,tripIdToShort,shortToRouteId, stopNameAndStopId, stopIDAndStopName;
@synthesize bikeCars;
@synthesize shortToTripId;
bool m_BUpdatingDatabase;
#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort(); } }


//
//- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
//{
//    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
//    
//    const char* filePath = [[URL path] fileSystemRepresentation];
//    
//    const char* attrName = "com.apple.MobileBackup";
//    u_int8_t attrValue = 1;
//    
//    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
//    return result == 0;
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    m_BUpdatingDatabase=false;//this should always be false, only when updating the GTFS data should it temporarily be set to true
    [self createDatabase];
    [self fillTripDictionary];
    [self fillStopNamesDictionary];
    [self  loadBikeCars];
    
    UIViewController *routesView = [[RoutesViewController alloc] initWithNibName:@"RoutesViewController" bundle:nil];
    UIViewController *nearView = [[StationsViewController alloc] initWithNibName:@"StationsViewController" bundle:nil];
    UIViewController *alertsView = [[AlertsViewController alloc] initWithNibName:@"AlertsViewController" bundle:nil];
    //UIViewController *tripsView = [[TripViewController alloc] initWithNibName:@"TripViewController" bundle:nil];
    UIViewController *mapView = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    
    UINavigationController * alertNav = [[UINavigationController alloc] initWithRootViewController:alertsView];
    UINavigationController * routeNav = [[UINavigationController alloc] initWithRootViewController:routesView];
    UINavigationController * nearNav = [[UINavigationController alloc] initWithRootViewController:nearView];
    //UINavigationController * tripNav = [[UINavigationController alloc] initWithRootViewController:tripsView];
    UINavigationController * mapNav = [[UINavigationController alloc] initWithRootViewController:mapView];
 
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[routeNav, mapNav, nearNav, alertNav];//tripNav,alertNav];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    UINavigationController* nav = (UINavigationController*) [self.tabBarController selectedViewController];
    UIViewController* topVC = [nav topViewController];
    
    //if the current view is Alerts, reload the alerts when returning from background/not-active, same for mapviewcontroller
    if([topVC respondsToSelector:@selector(alertRefreshData)])
    {
        [topVC performSelector:@selector(alertRefreshData) withObject:nil afterDelay:.25];
    }
    else if([topVC respondsToSelector:@selector(mapViewReloadMap)])
    {
        [topVC performSelector:@selector(mapViewReloadMap) withObject:nil afterDelay:.25];
        //mapViewReloadMap
    }
}


/*
 Burbank-bob Hope
 904, 909
 San Bernardino Line
 303, 307, 311, 315, 319, 327, 335, 387, 302, 304, 310, 318, 320, 322, 324, 328, 386, 357, 369, 362, 368
 
 Riverside Line
 407, 408
 
 Orange County Line
 605, 683, 607, 685, 687, 641, 643, 645, 682, 684, 602, 640, 604, 642, 644, 661, 665, 663, 667, 660, 662, 666, 664
 
 Inland Empire-Orange County Line
 850, 802, 804, 806, 808, 803, 805, 807, 851, 811, 813, 858, 860, 857, 859
 
 Not sure when, but supposed to get more bike cars:
 http://www.metrolinktrains.com/news/promotions_detail/title/CicLAvia_October7
 Additional Bikes Cars will be on the following trains:
 San Bernardino Line: 351, 357, 359, 364, 366, 368, 376
 Orange County Line: 661, 666, 664
 Antelope Valley Line: 260, 262, 265, 269
 
 */
- (void) loadBikeCars
{
    
    //old list
//    NSArray* carsArray2 = [[NSArray alloc] initWithObjects:@"904", @"909", @"303",
//                          @"307", @"311", @"315", @"319", @"327", @"335", @"387",
//                          @"302", @"304", @"310", @"318", @"320", @"322", @"324",
//                          @"328", @"386", @"357", @"369", @"362", @"368", @"407",
//                          @"408", @"605", @"683", @"607", @"685", @"687", @"641",
//                          @"643", @"645", @"682", @"684", @"602", @"640", @"604",
//                          @"642", @"644", @"661", @"665", @"663", @"667", @"660",
//                          @"662", @"666", @"664", @"850", @"802", @"804", @"806",
//                          @"808", @"803", @"805", @"807", @"851", @"811", @"813",
//                          @"858", @"860", @"857", @"859", nil];
    
//    NSArray *carsArray = [[NSArray alloc] initWithObjects:@"850", @"804", @"808", @"803", @"805", @"807", @"851", @"858", @"860", @"857", @"859", @"904", @"909", @"303", @"307", @"311", @"319", @"327", @"335", @"387", @"302", @"310", @"318", @"320", @"322", @"324", @"328", @"386", @"357", @"369", @"362", @"368", @"407", @"408", @"605", @"609", @"683", @"607", @"685", @"687", @"641", @"643", @"645", @"682", @"684", @"602", @"640", @"604", @"642", @"644", @"661", @"665", @"663", @"667", @"660", @"662", @"666", @"664", @"850", @"804", @"808", @"803", @"805", @"807", @"851", @"858", @"860", @"857", @"859", nil];
    
    //updated this list of bikecars 9/28/2013
    NSArray *carsArray = [[NSArray alloc] initWithObjects:@"904", @"909", @"303", @"307", @"311", @"319", @"327", @"335",
                          @"302", @"310", @"318", @"320", @"322", @"324", @"328", @"386", @"357", @"369", @"357", @"369",
                          @"362", @"368", @"407", @"408", @"605", @"683", @"607", @"685", @"687", @"641", @"643", @"645",
                          @"682", @"684", @"602", @"640", @"604", @"642", @"644", @"660", @"662", @"666", @"664", @"661",
                          @"665", @"663", @"667", @"857", @"859", @"858", @"860", @"803", @"805", @"807", @"851", @"850",
                          @"804", @"808", nil];

    bikeCars = [[NSMutableSet alloc] initWithArray:carsArray];
 
    //NSLog(@"%d \t %d", [carsArray2 count], [carsArray count]);
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);//NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"database1.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success)
        return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"database1.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}


//write a function that deletes all database files
//then will be replaced by the new sqlite file
- (void) deleteOldDatabase
{
    //BOOL success;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);//NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *DBPath = [documentsDirectory stringByAppendingPathComponent:@"database1.sqlite"];
    
    if([fileManager fileExistsAtPath:DBPath])
    {
        if([fileManager isDeletableFileAtPath:DBPath]==YES)
        {
           [fileManager removeItemAtPath:DBPath error:&error];
        }
    }

    //isDeletableFileAtPath
}
- (void) createDatabase
{
    //9/29/2013 - apparantly, when I update the database I always delete the old one
    //and force copy the new one.... i should fix this.
    [self deleteOldDatabase];
    [self createEditableCopyOfDatabaseIfNeeded];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);//NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database1.sqlite"];
    db = [FMDatabase databaseWithPath:path];
    if (![db open]) {
        NSLog(@"Could not open db.");
    }
    [self createCalendarDBTable];
    [self createRoutesDBTable];
    [self createTripsDBTable];
    [self createStopsDBTable];
    [self createShapesDBTable];
    [self createStopTimesDBTable];
    [self createAnemitiesDBTable];
    //added fares tables - 4/28/13 version 3.2.1
    [self CreatFareRulesDBTable];
    [self CreateFareAttributesDBTable];
    
    [self createDictionaryWithTripIDAndDirection];
    [self createDictionaryWithTripIDAndShortName];
}

//"stop_id","stop_name","stop_lat","stop_lon","zone_id","stop_url"
- (NSMutableDictionary*) getFiveStationsNear:(double) longitude andLat:(double)latitude
{
    NSMutableDictionary* stopIDDict = [[NSMutableDictionary alloc]init];
    NSString* q1 = [NSString stringWithFormat:@"select stop_name, stop_lat, stop_lon from stops "];
    
    FMResultSet *rs = [db executeQuery:q1];
    while ([rs next])
    {
       
        NSMutableDictionary* longAndLat = [[NSMutableDictionary alloc]init];
        [longAndLat setObject:[rs stringForColumn:@"stop_lat"] forKey:[rs stringForColumn:@"stop_lon"]];
        [stopIDDict setObject:longAndLat forKey:[rs stringForColumn:@"stop_name"]];
    }
    return stopIDDict;
}

- (NSMutableDictionary*) getCoordinateForStopName:(NSString*) stopName
{
    NSMutableDictionary* stopIDDict = [[NSMutableDictionary alloc]init];
    NSString* q1 = [NSString stringWithFormat:@"select stop_name, stop_lat, stop_lon from stops where stop_name=\"%@\"", stopName];
    
    FMResultSet *rs = [db executeQuery:q1];
    if ([rs next])
    {
        
        NSMutableString* longAndLat = [[NSMutableString alloc]init];
        [longAndLat setString:[NSString stringWithFormat:@"%@,%@", [rs stringForColumn:@"stop_lat"] ,[rs stringForColumn:@"stop_lon"]]];
        //[longAndLat setObject:[rs stringForColumn:@"stop_lat"] forKey:[rs stringForColumn:@"stop_lon"]];
        [stopIDDict setObject:longAndLat forKey:[rs stringForColumn:@"stop_name"]];
    }
    return stopIDDict;
}

- (void) createDictionaryWithTripIDAndShortName
{
    
    //tripIdToShort
    //takes 296100057 and pairs with 626 (ML 626)
    //take short 626 and pair with 296100057
    tripIdToShort = [[NSMutableDictionary alloc]init];
    shortToTripId = [[NSMutableDictionary alloc] init];
    NSString* q1 = [NSString stringWithFormat:@"select distinct trip_id, trip_short_name  from trips "];
    
    FMResultSet *rs = [db executeQuery:q1];
    while ([rs next])
    {
        [tripIdToShort setObject:[rs stringForColumn:@"trip_short_name"] forKey:[rs stringForColumn:@"trip_id"]];
        [shortToTripId setObject:[rs stringForColumn:@"trip_id"] forKey:[rs stringForColumn:@"trip_short_name"]];
        
    }
    
}
- (void) createDictionaryWithTripIDAndDirection
{
    //routeAndDirection
        routeAndDirection = [[NSMutableDictionary alloc]init];
    NSString* q1 = [NSString stringWithFormat:@"select distinct trip_id, direction_id from trips "];
    
    FMResultSet *rs = [db executeQuery:q1];
    while ([rs next])
    {
        [routeAndDirection setObject:[rs stringForColumn:@"direction_id"] forKey:[rs stringForColumn:@"trip_id"]];
    }
    
}

//need a method that finds the last stop by finding the largest stop_sequence in the list

- (NSString*) getLastStopFromShortName:(NSString*) shortName
{
    NSString* q1 = [NSString stringWithFormat:@"select stop_sequence, stop_id from stoptimes where trip_id=\"%@\"", [shortToTripId objectForKey:shortName]];
   // NSString* lastStop;
    NSMutableString* stopId = [[NSMutableString alloc] init];
    int largestSequence=-1;
    FMResultSet *rs = [db executeQuery:q1];
    while([rs next] )
    {
        int stopSeq = [rs intForColumn:@"stop_sequence"];
        if(stopSeq > largestSequence)
        {
            largestSequence = stopSeq;//[rs intForColumn:@"stop_sequence"];
            [stopId setString:[NSString stringWithFormat:@"%@", [rs stringForColumn:@"stop_id"]]];
        }
    }
    
    if(largestSequence>-1)
        return [self getFriendNameForRouteID:stopId];
    
    return nil;
    
}

- (void) fillStopNamesDictionary
{
    //"stop_id","stop_name","stop_lat","stop_lon","zone_id","stop_url"
     NSString* q1 = [NSString stringWithFormat:@"select stop_name, stop_id from stops"];
    stopNameAndStopId = [[NSMutableDictionary alloc] init];
    stopIDAndStopName = [[NSMutableDictionary alloc] init];
    FMResultSet *rs = [db executeQuery:q1];
    while ([rs next])
    {
        [stopNameAndStopId setObject:[rs stringForColumn:@"stop_id"] forKey:[rs stringForColumn:@"stop_name"]];
        [stopIDAndStopName setObject:[rs stringForColumn:@"stop_name"] forKey:[rs stringForColumn:@"stop_id"]];
        
    }
}

- (void) fillTripDictionary
{
    //"route_id","service_id","trip_id","trip_headsign","trip_short_name","direction_id","shape_id"
    // "Ventura County Line","1141","294100121","L. A. Union Station","100"
    NSString* q1 = [NSString stringWithFormat:@"select trip_short_name, route_id from trips"];
    shortToRouteId = [[NSMutableDictionary alloc] init];
    FMResultSet *rs = [db executeQuery:q1];
    while ([rs next])
    {
        //Venture County Line = VC
        //San Bernardino Line = SB
        //Orange County Line = OC
        //Antelope Valley Line = ANT
        //91 Line- 91
        //Burbank-Bob Hope Airport - Burbank
        //Inland Emp.-Orange Co. Line - IEOC
        //Riverside Line - RL
        NSString* line = [rs stringForColumn:@"route_id"];
        if([line isEqualToString:@"Ventura County Line"])
            [shortToRouteId setObject:@"VC" forKey:[rs stringForColumn:@"trip_short_name"]];
        else if([line isEqualToString:@"San Bernardino Line"])
            [shortToRouteId setObject:@"SB" forKey:[rs stringForColumn:@"trip_short_name"]];
        else if([line isEqualToString:@"Orange County Line"])
            [shortToRouteId setObject:@"OC" forKey:[rs stringForColumn:@"trip_short_name"]];
        else if([line isEqualToString:@"Antelope Valley Line"])
            [shortToRouteId setObject:@"ANT" forKey:[rs stringForColumn:@"trip_short_name"]];
        else if([line isEqualToString:@"91 Line"])
            [shortToRouteId setObject:@"91" forKey:[rs stringForColumn:@"trip_short_name"]];
        else if([line isEqualToString:@"Burbank-Bob Hope Airport"])
            [shortToRouteId setObject:@"Burbank" forKey:[rs stringForColumn:@"trip_short_name"]];
        else if([line isEqualToString:@"Burbank-Bob Hope Airport Metrolink Station"])
            [shortToRouteId setObject:@"Burbank" forKey:[rs stringForColumn:@"trip_short_name"]];
        else if([line isEqualToString:@"Inland Emp.-Orange Co. Line"])
            [shortToRouteId setObject:@"IEOC" forKey:[rs stringForColumn:@"trip_short_name"]];
        else if([line isEqualToString:@"Riverside Line"])
            [shortToRouteId setObject:@"RL" forKey:[rs stringForColumn:@"trip_short_name"]];
        else{
            NSLog(@"NOT IN SET = %@", [rs stringForColumn:@"trip_short_name"]);
        }
    }
    
}

- (NSMutableArray*) getRouteDetailsForRoute:(NSString*) shortName
{
    NSMutableArray* dict = [[NSMutableArray alloc]init];

     NSString* q1 = [NSString stringWithFormat:@"select * from stoptimes where trip_id=\"%@\" order by departure_time", [shortToTripId objectForKey:shortName]];
    FMResultSet *rs = [db executeQuery:q1];
    while ([rs next])
    {
        RouteDetailsClass* t= [[RouteDetailsClass alloc]init];
        t.stopId = [self getFriendNameForRouteID:[rs stringForColumn:@"stop_id"]];
        t.stopSequence = [rs stringForColumn:@"stop_sequence"];
        t.departureTime = [rs stringForColumn:@"departure_time"];
        [dict addObject:t];
    }
    return dict;
}
- (NSString*) getTitleHeadingForTripShortName:(NSString*) shortName
{
    
    NSString* titleHeading;
    NSString* q1 = [NSString stringWithFormat:@"select stop_headsign from stoptimes where trip_id=\"%@\"", [shortToTripId objectForKey:shortName]];

    FMResultSet *rs = [db executeQuery:q1];
    if ([rs next])
    {
        titleHeading = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"stop_headsign"]];
    }   
    
    
    return titleHeading;
    
    
}


//trip_id

- (double) GetFareForTrip:(int) stopA withEnd:(int) stopB
{
    
    //fare_id,origin_id,destination_id
    NSString *q = [NSString stringWithFormat:@"select fare_id from farerules where origin_id=%d and destination_id=%d", stopA, stopB];
    
    FMResultSet *rs = [db executeQuery:q];
    if ([rs next])
    {
        int fareID = [rs doubleForColumn:@"fare_id"];
        
        //now get the fare...
        //fare_id,price
        NSString *q1 = [NSString stringWithFormat:@"select price from fareattributes where fare_id=%d", fareID];
        
        FMResultSet *rs1= [db executeQuery:q1];
       // rs1 = [db executeQuery:q1];
        if([rs1 next])
        {
            return [rs1 doubleForColumn:@"price"];//[NSString stringWithFormat:@"$%.2f", [rs1 doubleForColumn:@"price"]];
        }
        
    }
    
    return 0.00;
    
}
- (NSString*) getFirstStopForTripShortName:(NSString*) shortName
{
    NSString* q1 = [NSString stringWithFormat:@"select stop_sequence, stop_id from stoptimes where trip_id=\"%@\"", [shortToTripId objectForKey:shortName]];
    NSMutableString* stopId = [[NSMutableString alloc] init];
    int largestSequence=10000;
    FMResultSet *rs = [db executeQuery:q1];
    while([rs next] )
    {
        int stopSeq = [rs intForColumn:@"stop_sequence"];
        if(stopSeq < largestSequence)
        {
            largestSequence = stopSeq;
            [stopId setString:[NSString stringWithFormat:@"%@", [rs stringForColumn:@"stop_id"]]];
        }
    }
    
    if(largestSequence<10000)
        return [self getFriendNameForRouteID:stopId];
    
    return nil;
    

    
    /*
     NSString *q = [NSString stringWithFormat:@"select stop_id from stoptimes where trip_id=\"%@\"", [shortToTripId objectForKey: shortName]];
    
    FMResultSet *rs = [db executeQuery:q];
    if ([rs next]) {
        
        return [self getFriendNameForRouteID:[rs stringForColumn:@"stop_id"]];
    }
    return nil;
    */
    
    
    
    
}
- (void) setDay:(int) day
{
    NSLog(@"%d", day);
}

- (NSMutableArray*) getStopsForStopId:(NSString*) stopId 
{
    NSString* q1 = [NSString stringWithFormat:@"select distinct arrival_time, trip_id from stoptimes where stop_id=\"%@\" order by arrival_time", stopId];
    NSMutableArray *results = [NSMutableArray array];
    
    NSDateFormatter* theDateFormatter = [[NSDateFormatter alloc] init];
    [theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [theDateFormatter setDateFormat:@"EEEE"];
    NSString *weekDay =  [theDateFormatter stringFromDate:[NSDate date]];
    
    //the day is for deterimning if this route runs today
    int day = [self getIntFromStringDay:weekDay];
    
    FMResultSet *rs = [db executeQuery:q1];
    while ([rs next])
    {
        NSString* longRouteId = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"trip_id"]];
        NSString* serviceID = [self getServiceIdFromTripId:longRouteId];
        bool routeAvailableToday = [self doesTripRun:serviceID onThisDay:day];
        if(routeAvailableToday)
        {
            NSString* time = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"arrival_time"]];
            if(!([self hasTrainAlreadyPassed:time]))
            {
                NSString* res = [NSString stringWithFormat:@"%@,%@", [self.tripIdToShort objectForKey:[rs stringForColumn:@"trip_id"]], [rs stringForColumn:@"arrival_time"]];
                [results addObject:res];
            }
        }
    }
    
    return results;
}


- (NSMutableArray*) getStopsForStopId:(NSString*) stopId stripStops:(BOOL)strip
{
    NSString* q1 = [NSString stringWithFormat:@"select distinct arrival_time, trip_id from stoptimes where stop_id=\"%@\" order by arrival_time", stopId];
    NSMutableArray *results = [NSMutableArray array];
    
    NSDateFormatter* theDateFormatter = [[NSDateFormatter alloc] init];
    [theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [theDateFormatter setDateFormat:@"EEEE"];
    NSString *weekDay =  [theDateFormatter stringFromDate:[NSDate date]];
    
    //the day is for deterimning if this route runs today
    int day = [self getIntFromStringDay:weekDay];
    
    FMResultSet *rs = [db executeQuery:q1];
    while ([rs next])
    {
        NSString* longRouteId = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"trip_id"]];
        NSString* serviceID = [self getServiceIdFromTripId:longRouteId];
        bool routeAvailableToday = [self doesTripRun:serviceID onThisDay:day];
        if(routeAvailableToday)
        {
            NSString* time = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"arrival_time"]];
            //if(strip && !([self hasTrainAlreadyPassed:time]))
            if(strip)
            {
                if( !([self hasTrainAlreadyPassed:time]))
                {
                    NSString* res = [NSString stringWithFormat:@"%@,%@", [self.tripIdToShort objectForKey:[rs stringForColumn:@"trip_id"]], [rs stringForColumn:@"arrival_time"]];
                    [results addObject:res];
                }
            }
            else
            {
                
                NSString* res = [NSString stringWithFormat:@"%@,%@", [self.tripIdToShort objectForKey:[rs stringForColumn:@"trip_id"]], [rs stringForColumn:@"arrival_time"]];
                //NSLog(@"%@", res);
                [results addObject:res];
            }
        }
    }

    return results;
}

- (NSMutableArray*) getStopsForStopId:(NSString*) stopId stripStops:(BOOL)strip forDay:(int)day
{
    NSString* q1 = [NSString stringWithFormat:@"select distinct arrival_time, trip_id from stoptimes where stop_id=\"%@\" order by arrival_time", stopId];
    NSMutableArray *results = [NSMutableArray array];

    FMResultSet *rs = [db executeQuery:q1];
    while ([rs next])
    {
        NSString* longRouteId = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"trip_id"]];
        NSString* serviceID = [self getServiceIdFromTripId:longRouteId];
        bool routeAvailableToday = [self doesTripRun:serviceID onThisDay:day];
        if(routeAvailableToday)
        {
            NSString* time = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"arrival_time"]];
            if(strip)
            {
                if( !([self hasTrainAlreadyPassed:time]))
                {
                    NSString* res = [NSString stringWithFormat:@"%@,%@", [self.tripIdToShort objectForKey:[rs stringForColumn:@"trip_id"]], [rs stringForColumn:@"arrival_time"]];
                    [results addObject:res];
                }
            }
            else
            {   
                NSString* res = [NSString stringWithFormat:@"%@,%@", [self.tripIdToShort objectForKey:[rs stringForColumn:@"trip_id"]], [rs stringForColumn:@"arrival_time"]];
                [results addObject:res];
            }
        }
    }
    return results;
}


- (BOOL) hasTrainAlreadyPassed:(NSString*) trainTimeFound
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    
    NSDate* date ;//= [[NSDate alloc] init];
    date = [NSDate date];
    
    /***TRAIN TIME***/
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *trainTime = [formatter dateFromString:trainTimeFound];
    /****END TRAIN TIME***/
    
    NSCalendar *calendar =[NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit ) fromDate:trainTime];
    NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:date];
    
    [timeComponents setMinute:[timeComponents minute] - 12];    //show the train from 12 minutes ago...
    
    NSDate *trianInfo = [calendar dateFromComponents:dateComponents];
    NSDate *curInfo = [calendar dateFromComponents:timeComponents];
    
    // If the receiver is earlier than anotherDate, the return value is negative.
    NSTimeInterval interval = [trianInfo timeIntervalSinceDate:curInfo];
    if(interval >0)
    {
        // count++;
        return NO;
        //need to write a query to get the trip_short_name for this long train ID...
        //NSString* shortName = [self.tripIdToShort objectForKey:[array objectAtIndex:0]];
       // [ridesDict setObject:[array objectAtIndex:1] forKey:shortName];
    }
    

    return YES;
}


- (int) getIntFromStringDay:(NSString*)day
{
    
    int nDay = 0;
    if([day isEqualToString:@"Saturday"])
        return 5;
    if([day isEqualToString:@"Sunday"])
        return 6;
    if([day isEqualToString:@"Monday"])
        return 0;
    if([day isEqualToString:@"Tuesday"])
        return 1;
    if([day isEqualToString:@"Wednesday"])
        return 2;
    if([day isEqualToString:@"Thursday"])
        return 3;
    if([day isEqualToString:@"Friday"])
        return 4;
    
    return nDay;
}





- (NSMutableDictionary*) getNextThreeStopsForStopId:(NSString*) stopId andDirection:(NSInteger) directionID
{
 
    NSMutableDictionary* ridesDict = [[NSMutableDictionary alloc]init];

    NSString* q1 = [NSString stringWithFormat:@"select distinct arrival_time, trip_id from stoptimes where stop_id=\"%@\" order by arrival_time", stopId];
    NSMutableArray *results = [NSMutableArray array];
    
    FMResultSet *rs = [db executeQuery:q1];
    while ([rs next])
    {
        NSString* res = [NSString stringWithFormat:@"%@,%@", [rs stringForColumn:@"trip_id"], [rs stringForColumn:@"arrival_time"]];
       // NSLog(@"%@", res);
        [results addObject:res];
    }
    if([results count] == 0)
        return nil;
    
 //   NSString* directionString = [NSString stringWithFormat:@"%d", directionID];
  //  int count=0;
    for(NSString *s in results)
    {

       
       // if(count >=3)
         //   continue;
        NSArray *array = [s componentsSeparatedByString: @","];
      //  NSString* stopid = [NSString stringWithFormat:@"%@",[array objectAtIndex:0]];
        //NSInteger dir = [[routeAndDirection objectForKey:stopid] intValue];
      //  if(dir != directionID)
        //     continue;
             
             
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm:ss"];

        NSDate* date ;//= [[NSDate alloc] init];
        date = [NSDate date];

        /***TRAIN TIME***/
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
        [formatter setDateFormat:@"HH:mm:ss"];
        NSDate *trainTime = [formatter dateFromString:[array objectAtIndex:1]];
        /****END TRAIN TIME***/
        
        NSCalendar *calendar =[NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit ) fromDate:trainTime];
        NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:date];

        NSDate *trianInfo = [calendar dateFromComponents:dateComponents];
        NSDate *curInfo = [calendar dateFromComponents:timeComponents];
              
        // If the receiver is earlier than anotherDate, the return value is negative.
        NSTimeInterval interval = [trianInfo timeIntervalSinceDate:curInfo];
        if(interval >0)
        {
           // count++;
            
            //need to write a query to get the trip_short_name for this long train ID...
            NSString* shortName = [self.tripIdToShort objectForKey:[array objectAtIndex:0]];
            [ridesDict setObject:[array objectAtIndex:1] forKey:shortName];
        }
                      
    }
    
    
    return ridesDict;
}

- (NSArray*) getLowestStopOrderForStop:(NSString*) routeID
{
    //https://github.com/reedlauber/Next-Septa/blob/master/app/models/simplified_stop.rb
    NSString* q1 = [NSString stringWithFormat:@"select distinct s.stop_id, s.stop_name, st.stop_sequence from stops s inner join stoptimes st on s.stop_id=st.stop_id inner join trips t on st.trip_id=t.trip_id inner join routes r on r.route_id=\"%@\" where t.route_id=\"%@\" and t.direction_id =\"1\" ORDER BY st.stop_sequence", routeID, routeID];
    
    //NSMutableArray *results = [NSMutableArray array];
    
    FMResultSet *rs = [db executeQuery:q1];
    NSMutableDictionary* dict1 = [[NSMutableDictionary alloc]init];
    NSMutableSet * setStopNames = [[NSMutableSet alloc] init];
    while ([rs next])
    {
       //if([rs objectForColumnName:@"stop_name"]!=nil && [rs stringForColumn:@"stop_name"]!=@"" &&
        if([rs objectForColumnName:@"stop_name"] !=nil && ![[rs stringForColumn:@"stop_name"] isEqual:@""] &&
        ![setStopNames containsObject:[rs stringForColumn:@"stop_name"]])
        {
            [setStopNames addObject:[rs stringForColumn:@"stop_name"]];
            //[results addObject:[rs resultDictionary]];
            //[dict1 setObject:[rs stringForColumn:@"stop_name"] forKey:[NSNumber numberWithInt:[rs intForColumn:@"stop_sequence"]]];
            [dict1 setObject:[NSNumber numberWithInt:[rs intForColumn:@"stop_sequence"]] forKey:[rs stringForColumn:@"stop_name"]];
        }
        
    }
    NSMutableArray* ar1 = [[NSMutableArray alloc]init];
    for(id ob in dict1)
    {

        [ar1 addObject:ob];
    }
    
    NSArray* sorted = [ar1 sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray* stopids = [[NSMutableArray alloc] init];
    for(id i in sorted)
    {
        [stopids addObject:i];//[dict1 objectForKey:i]];
       // NSLog(@"Stop ---- %@", i);//[dict1 objectForKey:i]);

    }
    return stopids;
    
    
}


- (NSString*) getArrivalTimeForTrainNum:(NSString*)trainNum 
{
   // NSString *stopId = [self getStopIdFromHeadingName:friendlyName];
    
    NSString *tripID = [NSString stringWithFormat:@"%@",[shortToTripId objectForKey:trainNum]];
    NSString *q1 = [NSString stringWithFormat:@"select arrival_time, stop_sequence from stoptimes where trip_id=\"%@\"", tripID];
    //NSLog(@"%@   %@", tripID, q1);
    int largest = 0;
    NSMutableString* time = [[NSMutableString alloc]init];
    FMResultSet *rs = [db executeQuery:q1];
    while ([rs next])
    {
        int seq = [rs intForColumn:@"stop_sequence"];
        if(seq > largest)
        {
            [time setString:[rs stringForColumn:@"arrival_time" ]];
            largest = seq;
        }
    }
    
    
    return time;
}

- (NSArray*) getShapesForRoute:(NSString*)routeID
{
    //select unique shape_id from trips where route_id = routeID -- should return 2 results...use the first
    //then select * from shapes where shape_id = ....
    //return NSArray with the "shape_pt_lat","shape_pt_lon"
    //use that to plot the overlay
    NSString* ID;
    NSMutableArray * results = [[NSMutableArray alloc]init];
    //NSLog(@"%@", routeID);
    NSString *q = [NSString stringWithFormat:@"select distinct shape_id from trips where route_id=\"%@\"", routeID];
    FMResultSet *rs = [db executeQuery:q];
    if ([rs next])
    {
        //just get the first one...
        ID = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"shape_id"]];
        
    }
    
    if(ID!=nil)
    {
        NSString *q1 = [NSString stringWithFormat:@"select * from shapes where shape_id=\"%@\" order by shape_pt_sequence", ID];
        FMResultSet *rs1 = [db executeQuery:q1];
        NSMutableArray* sequence = [[NSMutableArray alloc] init];
        NSMutableDictionary* data = [[NSMutableDictionary alloc]init];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        while([rs1 next])
        {
         
           
            
            NSString* seqStr = [NSString stringWithFormat:@"%@", [rs1 stringForColumn:@"shape_pt_sequence"]];
             NSNumber * numStopSeq = [f numberFromString:seqStr];
            [sequence addObject:numStopSeq];//[rs1 stringForColumn:@"shape_pt_sequence"]];
//            NSLog(@"routeID=%@, pointSeq =%@", [rs1 stringForColumn:@"shape_id"], [rs1 stringForColumn:@"shape_pt_sequence"]);
           NSString* point = [NSString stringWithFormat:@"%@,%@", [rs1 stringForColumn:@"shape_pt_lat"], [rs1 stringForColumn:@"shape_pt_lon"]];
//            [results addObject:point];
            [data setObject:point forKey:numStopSeq];
        }

        
        
           NSArray* sort = [sequence sortedArrayUsingSelector:@selector(compare:)];
        
        for(NSNumber *s in sort)
        {
            NSString * dat = [data objectForKey:s];
            //NSString* d = [NSString stringWithFormat:@"%@", dat];
            //NSLog(@"sequence = %@",dat );
            [results addObject:dat];
        }
    }
    
    NSArray* res = [results copy];
    return res;
}

- (NSString*) getArrivalTimeForStopId:(NSString*)friendlyName withTripId:(NSString*) tripId
{
    NSString *stopId = [self getStopIdFromHeadingName:friendlyName];
    NSString *q1 = [NSString stringWithFormat:@"select arrival_time from stoptimes where stop_id=\"%@\" and trip_id=\"%@\"",stopId, tripId];
    
    FMResultSet *rs = [db executeQuery:q1];
    if ([rs next])
    {
        return [rs stringForColumn:@"arrival_time" ];
    }

    
    return nil;
}

//Heading name will be like "Lancaster"
//Friendly Station Name will be like "Lancaster Metrolink Station"
- (NSString*) getStopIdFromHeadingName:(NSString*) routeName
{
    //stop_id from stops using stop_name
    NSString *q = [NSString stringWithFormat:@"select stop_id from stoptimes where stop_headsign=\"%@\"", routeName];
    

    FMResultSet *rs = [db executeQuery:q];
    if ([rs next])
    {
        return [rs stringForColumn:@"stop_id" ];
    }
    
    return nil;
}

- (bool) doesTripRun:(NSString*) serviceid onThisDay:(int) day
{
    //day will be monday, tuesday, wednesday, etc
    //service_id should exist on the calendar table under service_id
    
    NSString *q = [NSString stringWithFormat:@"select * from calendar where service_id=\"%@\"", serviceid];
    
        
    FMResultSet *rs = [db executeQuery:q];
    if ([rs next])
    {
        //NSLog(@"%d", [rs intForColumn:@"saturday"] );
        switch (day)
        {
            case 0: //monday
               if( [rs intForColumn:@"monday"] == 1)
                   return YES;
                break;
            case 1: //tuesday
                if( [rs intForColumn:@"tuesday"] == 1)
                    return YES;
            break;
            case 2: //wednesday
                if( [rs intForColumn:@"wednesday"] == 1)
                    return YES;
            break;
            case 3: //thursday
                if( [rs intForColumn:@"thursday"] == 1)
                    return YES;
            break;
            case 4: //friday
                if( [rs intForColumn:@"friday"] == 1)
                    return YES;
            break;
            case 5: //saturday
                if( [rs intForColumn:@"saturday"] == 1)
                    return YES;
            break;
            case 6: //sunday
                if( [rs intForColumn:@"sunday"] == 1)
                    return YES;
            break;
            default:
            return NO;
        }
        
        //return [rs stringForColumn:@"service_id" ];
    }

    
    return NO;
    
    
}

- (NSString*) getServiceIdFromTripId:(NSString*)tripId
{
    //service_id
    NSString *q = [NSString stringWithFormat:@"select service_id from trips where trip_id=\"%@\"", tripId];
    
    FMResultSet *rs = [db executeQuery:q];
    if ([rs next])
    {
        return [rs stringForColumn:@"service_id" ];
    }
    
    return nil;

}
- (NSString*) getStopIdFromFriendlyName:(NSString*) routeName
{
    //stop_id from stops using stop_name
    NSString *q = [NSString stringWithFormat:@"select stop_id from stops where stop_name=\"%@\"", routeName];
    
    FMResultSet *rs = [db executeQuery:q];
    if ([rs next])
    {
        return [rs stringForColumn:@"stop_id" ];
    }
    
    return nil;
}






- (NSMutableArray*) getallTripShortNamesForRoute: (NSString*) routeName;
{
    NSMutableArray * tempList = [[NSMutableArray alloc] init];
    
    NSString *q = [NSString stringWithFormat:@"select trip_short_name from trips where route_id=\"%@\"", routeName];
    
    FMResultSet *rs = [db executeQuery:q];
    while ([rs next]) {
        
        //return [rs stringForColumn:@"route_color"];
        [tempList addObject:[rs stringForColumn:@"trip_short_name"]];
    }
    return tempList;
    
}

- (NSString*) getFriendNameForRouteID:(NSString*)routeID;
{
    NSString *q = [NSString stringWithFormat:@"select stop_name from stops where stop_id=\"%@\"", routeID];
    
    FMResultSet *rs = [db executeQuery:q];
    if ([rs next]) {
        
        return [rs stringForColumn:@"stop_name"];
    }
    return nil;
    
}

- (NSMutableArray*) getTimeAndLocationForRoute:(NSString*)routeID
{
    //- query for arrival_time and stop_id and stop_sequence
    //        - make a comma separated string with a CRLF at the end
    //        - Add the string to an NSMutableArray
    
    NSMutableArray * tempList = [[NSMutableArray alloc] init];
    
    NSString *q = [NSString stringWithFormat:@"select arrival_time, stop_id, stop_sequence from stoptimes where trip_id=\"%@\"", routeID];
    
    FMResultSet *rs = [db executeQuery:q];
    while ([rs next]) {
        NSString* line = [NSString stringWithFormat:@"%@,%@,%@\n", [rs stringForColumn:@"arrival_time"],
                          [rs stringForColumn:@"stop_id"], [rs stringForColumn:@"stop_sequence"]];
        
        //return [rs stringForColumn:@"route_color"];
        [tempList addObject:line];
    }
    return tempList;
    
    
}

//To get the longest route/stops for a line:
//1. Get the route_id, (Venture County Line), that the user has selected
//2. use the route_id and query the trips table for all the "trip_id" that fit this route_id
//3. iterate through all the trip_id found and query stop times table
//4. get a count returned for the query of trip_id and the one with the largest count returned will contain all the stops
//5. then do a query for that trip_id again and this time get an NSArray of all the stop_id
//6. query the stops table for the user-friendly station name based on the stop_id
- (NSMutableSet*) getAllRouteStopsForLine:(NSString*)friendlyRouteName
{
    
    //route_id trip_short_name
    //    NSString *q1 = [NSString stringWithFormat:@"select route_id from trips where trip_short_name= \"%@\"", routeID];
    //    NSMutableString *friendlyRouteName = [[NSMutableString alloc] init];
    //    FMResultSet *rs1 = [db executeQuery:q1];
    //    if([rs1 next])
    //    {
    //        [friendlyRouteName setString:[rs1 stringForColumn:@"route_id"]];
    //    }
    //    else
    //        return nil;
    //
    
    //2.
    //routeID should be user-friendly name -- like Ventury County Line or Orange County Line
    //"route_id","service_id","trip_id","trip_headsign","trip_short_name","direction_id","shape_id"
    NSMutableArray * tripIdsArray = [[NSMutableArray alloc] init];
    NSString *q = [NSString stringWithFormat:@"select trip_id from trips where route_id = \"%@\"", friendlyRouteName];
    
    FMResultSet *rs = [db executeQuery:q];
    while ([rs next]) {
        
        [tripIdsArray addObject:[rs stringForColumn:@"trip_id"]];
        
    }
    
    //3.
    //int count = 0;
    //NSMutableString* longestTripId =[[NSMutableString alloc] init];
    //longestTripId setString@""
    NSMutableSet * stopNames = [[NSMutableSet alloc] init];
    for(NSString* tripId in tripIdsArray)
    {
        
        NSString * q = [NSString stringWithFormat:@"select stop_id from stoptimes where trip_id=\"%@\"", tripId];
        //NSLog(@"%@", q);
        FMResultSet* s = [db executeQuery:q];
        while([s next])
        {
            
            [stopNames addObject:[s stringForColumn:@"stop_id"]];
        }
        
        //        NSString * q = [NSString stringWithFormat:@"select count(*) from stoptimes where trip_id=\"%@\"", tripId];
        //
        //        FMResultSet *s = [db executeQuery:q];
        //        int localCount=-1;
        //        if ([s next]) {
        //            //4.
        //            localCount = [s intForColumnIndex:0];
        //            if(localCount > count)
        //            {
        //                [longestTripId setString:tripId];
        //                count = localCount;
        //            }
        //        }
    }
    
    NSMutableSet* tempSet = [[NSMutableSet alloc] initWithCapacity:[stopNames count]];
    for(NSString* stops in stopNames)
    {
        [tempSet addObject:[self getFriendNameForRouteID: stops]];
        //   NSLog(@"stop - %@", [self getFriendNameForRouteID: stops]);
    }
    
    return tempSet;
    
    
    //5.
    //if(count>0)
    //    {
    //        NSMutableArray * allStopNames = [[NSMutableArray alloc] init];
    //        NSString *q = [NSString stringWithFormat:@"select stop_id from stoptimes where trip_id=\"%@\"", longestTripId];
    //
    //        FMResultSet *rs = [db executeQuery:q];
    //        while ([rs next]) {
    //
    //
    //            [allStopNames addObject:[self getFriendNameForRouteID: [rs stringForColumn:@"stop_id"]]];
    //
    //        }
    //        for(NSString* stops in allStopNames)
    //        {
    //            NSLog(@"stop - %@", stops);
    //        }
    //        return allStopNames;
    //
    //    }
    
    
    //  return nil;
    
}
- (NSMutableArray*) getAllRouteNames
{
    NSMutableArray * tempList = [[NSMutableArray alloc] init];
    NSString *q = [NSString stringWithFormat:@"select route_long_name from routes"];
    
    FMResultSet *rs = [db executeQuery:q];
    while ([rs next]) {
        
        [tempList addObject:[rs stringForColumn:@"route_long_name"]];
    }
    
    return tempList;
}

- (NSMutableDictionary*) getRouteIdAndTripHeadSignForRoute:(NSString*)routeName
{
    NSMutableDictionary * tempList = [[NSMutableDictionary alloc] init];
    NSString *q = [NSString stringWithFormat:@"select trip_short_name, trip_headsign from trips"];
    
    FMResultSet *rs = [db executeQuery:q];
    while ([rs next]) {
        
        [tempList setObject:[rs stringForColumn:@"trip_headsign"] forKey:[rs stringForColumn:@"trip_short_name"]]; //addObject:[rs stringForColumn:@"route_long_name"]];
    }
    
    return tempList;
}

- (NSMutableArray*) getStationDetails:(NSString*) stopID
{
    NSMutableArray * tempList = [[NSMutableArray alloc] init];
    NSString *q = [NSString stringWithFormat:@"select * from anemities where route_id=\"%@\"", stopID];
    
    FMResultSet *rs = [db executeQuery:q];
    while ([rs next]) {
        //route_id,bathroom,parking,parking_fee,bicycle_racks,waiting_area,contact_info
        [tempList addObject:[rs stringForColumn:@"bathroom"]];
        [tempList addObject:[rs stringForColumn:@"parking"]];
        [tempList addObject:[rs stringForColumn:@"parking_fee"]];
        [tempList addObject:[rs stringForColumn:@"bicycle_racks"]];
        [tempList addObject:[rs stringForColumn:@"waiting_area"]];
        [tempList addObject:[rs stringForColumn:@"contact_info"]];
        break;  //only 1 entry!!!
        
    }
    
    return tempList;
    
}

//get the "trip_id" from trips table for this route_short_number
- (NSString*) getTripIdFromShortNumber:(NSString*)shortNum
{
    NSString *q = [NSString stringWithFormat:@"select trip_id from trips where trip_short_name=\"%@\"", shortNum];
    
    FMResultSet *rs = [db executeQuery:q];
    if ([rs next]) {
        
        return [rs stringForColumn:@"trip_id"];
        //[tempList addObject:[rs stringForColumn:@"route_long_name"]];
    }
    return nil;
}


- (NSString*) getColorForRoute:(NSString*) routeName
{
    //NSMutableArray * tempList = [[NSMutableArray alloc] init];
    NSString *q = [NSString stringWithFormat:@"select route_color from routes where route_id=\"%@\"", routeName];
    
    FMResultSet *rs = [db executeQuery:q];
    if ([rs next]) {
        
        return [rs stringForColumn:@"route_color"];
        //[tempList addObject:[rs stringForColumn:@"route_long_name"]];
    }
    return nil;
    //  return tempList;
}



- (void) createRoutesDBTable
{
    if(m_BUpdatingDatabase)
    {
        [db close];
        [db open];
        [db executeUpdate:@"DROP TABLE routes"];
    }
    //route_id,agency_id,route_short_name,route_long_name,route_type,route_url,route_color,route_text_color
    [db executeUpdate:@"create table routes (route_id text, agency_id text, route_short_name text, route_long_name text, route_type text, route_url text, route_color text, route_text_color text)"];
    
    if([db countTableEntries:@"routes"]<=0)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"routes" ofType:@"txt"];
        NSString *dataStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [dataStr componentsSeparatedByString:@"\n"];
        for(int i = 1; i<[lines count]-1; i++)
        {
            NSString *line = [lines objectAtIndex:i];
            NSArray *array = [line componentsSeparatedByString: @","];
            
            
            
            NSString* routeID =  [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
            NSString* trimrouteID= [routeID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            NSString* agencyID =  [NSString stringWithFormat:@"%@",[array objectAtIndex:1]];
            NSString* trimagencyID= [agencyID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* routeShortName =  [NSString stringWithFormat:@"%@",[array objectAtIndex:2]];
            NSString* trimrouteShortName= [routeShortName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* routeLongName =  [NSString stringWithFormat:@"%@",[array objectAtIndex:3]];
            NSString* trimrouteLongName= [routeLongName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* routeType =  [NSString stringWithFormat:@"%@",[array objectAtIndex:4]];
            NSString* trimrouteType= [routeType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* routeURL =  [NSString stringWithFormat:@"%@",[array objectAtIndex:5]];
            NSString* trimrouteURL= [routeURL stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* routeColor =  [NSString stringWithFormat:@"%@",[array objectAtIndex:6]];
            NSString* trimrouteColor= [routeColor stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* routeTextColor =  [NSString stringWithFormat:@"%@",[array objectAtIndex:7]];
            NSString* trimrouteTextColor= [routeTextColor stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            
            
            NSString *query = [NSString stringWithFormat:@"insert into routes (route_id, agency_id, route_short_name, route_long_name, route_type, route_url, route_color, route_text_color) values (?, ?, ?, ?, ?, ?, ?, ?)"];
            
            [db executeUpdate:query, trimrouteID, trimagencyID, trimrouteShortName, trimrouteLongName,
             trimrouteType, trimrouteURL, trimrouteColor, trimrouteTextColor];
            
        }
    }
    
}

- (void) createTripsDBTable
{
    if(m_BUpdatingDatabase)
    {
        [db close];
        [db open];
        [db executeUpdate:@"DROP TABLE trips"];
    }
    //"route_id",service_id,"trip_id","trip_headsign","trip_short_name",direction_id,"shape_id",trip_sequence
    //"route_id","service_id","trip_id","trip_headsign","trip_short_name","direction_id","shape_id"
    [db executeUpdate:@"create table trips (route_id text, service_id text, trip_id text, trip_headsign text, trip_short_name text, direction_id text, shape_id text)"];
    
  //  double c = [db countTableEntries:@"trips"];
    
    if([db countTableEntries:@"trips"]<=0)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"trips" ofType:@"txt"];
        NSString *dataStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [dataStr componentsSeparatedByString:@"\n"];
        for(int i = 1; i<[lines count]-1; i++)
        {
            NSString *line = [lines objectAtIndex:i];
            NSArray *array = [line componentsSeparatedByString: @","];
            
            
            
            NSString* routeID =  [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
            NSString* trimrouteID= [routeID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* serviceID =  [NSString stringWithFormat:@"%@",[array objectAtIndex:1]];
            NSString* trimServiceID= [serviceID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* tripID =  [NSString stringWithFormat:@"%@",[array objectAtIndex:2]];
            NSString* trimTripID= [tripID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* tripHeadsign =  [NSString stringWithFormat:@"%@",[array objectAtIndex:3]];
            NSString* trimTripHeadsign= [tripHeadsign stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* tripShortName =  [NSString stringWithFormat:@"%@",[array objectAtIndex:4]];
            NSString* trimTripShortName= [tripShortName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* directionID =  [NSString stringWithFormat:@"%@",[array objectAtIndex:5]];
            NSString* trimDirectionID= [directionID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* shapeID =  [NSString stringWithFormat:@"%@",[array objectAtIndex:6]];
            NSString* trimShapeID= [shapeID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            
            
            NSString *query = [NSString stringWithFormat:@"insert into trips (route_id, service_id, trip_id, trip_headsign, trip_short_name, direction_id, shape_id) values (?, ?, ?, ?, ?, ?, ?)"];
            
            [db executeUpdate:query, trimrouteID, trimServiceID, trimTripID, trimTripHeadsign,
             trimTripShortName, trimDirectionID, trimShapeID];
           
        }
    }
    
}

- (void) createStopsDBTable
{

    if(m_BUpdatingDatabase)
    {
        [db close];
        [db open];
        [db executeUpdate:@"DROP TABLE stops"];
    }
    //"stop_id","stop_name",stop_lat,stop_lon,zone_id,"stop_url"
    //"stop_id","stop_name","stop_lat","stop_lon","zone_id","stop_url"
    [db executeUpdate:@"create table stops (stop_id text, stop_name text, stop_lat text, stop_lon text, zone_id text, stop_url text)"];
    
    if([db countTableEntries:@"stops"]<=0)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"stops" ofType:@"txt"];
        NSString *dataStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [dataStr componentsSeparatedByString:@"\n"];
        for(int i = 1; i<[lines count]-1; i++)
        {
            NSString *line = [lines objectAtIndex:i];
            NSArray *array = [line componentsSeparatedByString: @","];
            
            
            
            NSString* stopID =  [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
            NSString* trimStopID= [stopID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* stopName =  [NSString stringWithFormat:@"%@",[array objectAtIndex:1]];
            NSString* trimStopName= [stopName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* stopLat =  [NSString stringWithFormat:@"%@",[array objectAtIndex:2]];
            NSString* trimStopLat= [stopLat stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* stopLon =  [NSString stringWithFormat:@"%@",[array objectAtIndex:3]];
            NSString* trimStopLon= [stopLon stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* zoneID =  [NSString stringWithFormat:@"%@",[array objectAtIndex:4]];
            NSString* trimZoneID= [zoneID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* stopURL =  [NSString stringWithFormat:@"%@",[array objectAtIndex:5]];
            NSString* trimStopURL= [stopURL stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString *query = [NSString stringWithFormat:@"insert into stops (stop_id, stop_name, stop_lat, stop_lon, zone_id, stop_url) values (?, ?, ?, ?, ?, ?)"];
            
            [db executeUpdate:query, trimStopID, trimStopName, trimStopLat, trimStopLon,
             trimZoneID, trimStopURL];
            
        }
    }
    
}

- (void) createCalendarDBTable
{
//    "service_id",monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
//    "service_id",monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date  

    if(m_BUpdatingDatabase)
    {
        [db close];
        [db open];
        [db executeUpdate:@"DROP TABLE calendar"];
    }
    [db executeUpdate:@"create table calendar (service_id text, monday double, tuesday double, wednesday double, thursday double, friday double, saturday double, sunday double, start_date text, end_date text)"];
    
    if([db countTableEntries:@"calendar"]<=0)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"calendar" ofType:@"txt"];
        NSString *dataStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [dataStr componentsSeparatedByString:@"\n"];
        for(int i = 1; i<[lines count]-1; i++)
        {
            NSString *line = [lines objectAtIndex:i];
            NSArray *array = [line componentsSeparatedByString: @","];
            
            NSString* serviceId =  [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
            NSString* trimServiceId  =[serviceId stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* monday =  [NSString stringWithFormat:@"%@", [array objectAtIndex:1]];
            NSString* monStrip= [monday stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* tuesday =  [NSString stringWithFormat:@"%@", [array objectAtIndex:2]];
            NSString* tueStrip= [tuesday stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* wednesday =  [NSString stringWithFormat:@"%@", [array objectAtIndex:3]];
            NSString* wedStrip= [wednesday stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* thursday =  [NSString stringWithFormat:@"%@", [array objectAtIndex:4]];
            NSString* thursStrip= [thursday stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* friday =  [NSString stringWithFormat:@"%@", [array objectAtIndex:5]];
            NSString* friStrip= [friday stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* saturday =  [NSString stringWithFormat:@"%@", [array objectAtIndex:6]];
            NSString* satStrip= [saturday stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* sunday =  [NSString stringWithFormat:@"%@", [array objectAtIndex:7]];
            NSString* sunStrip= [sunday stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* start =  [NSString stringWithFormat:@"%@", [array objectAtIndex:8]];
            NSString* startStrip= [start stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* end =  [NSString stringWithFormat:@"%@", [array objectAtIndex:9]];
            NSString* endStrip= [end stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber * monDouble = [f numberFromString:monStrip];
            NSNumber * tueDouble = [f numberFromString:tueStrip];
            NSNumber * wedDouble = [f numberFromString:wedStrip];
            NSNumber * thuDouble = [f numberFromString:thursStrip];
            NSNumber * friDouble = [f numberFromString:friStrip];
            NSNumber * satDouble = [f numberFromString:satStrip];
            NSNumber * sunDouble = [f numberFromString:sunStrip];
            
            //"service_id",monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
            NSString *query = [NSString stringWithFormat:@"insert into calendar (service_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_date, end_date) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
            
            [db executeUpdate:query, trimServiceId, monDouble, tueDouble, wedDouble, thuDouble, friDouble, satDouble, sunDouble, startStrip, endStrip];
            
            

        }
    }

}


- (void) CreateFareAttributesDBTable
{
    
//    [db close];
//    [db open];
//    [db executeUpdate:@"DROP TABLE fareattributes"];
    //fare_id,price,currency_type,payment_method,transfers,transfer_duration
    //not saving currency_type --- its always "USD", just add fare_id & price
    [db executeUpdate:@"create table fareattributes (fare_id double, price double,PRIMARY KEY(fare_id ASC) )"];
    //, payment_method double, transfers double, transfer_duration double)"];
    
    if([db countTableEntries:@"fareattributes"]<=0)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"fare_attributes" ofType:@"txt"];
        NSString *dataStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [dataStr componentsSeparatedByString:@"\n"];
        for(int i = 1; i<[lines count]-1; i++)
        {
            NSString *line = [lines objectAtIndex:i];
            NSArray *array = [line componentsSeparatedByString: @","];
            
            NSString* fairID =  [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
            NSString* trimFairID= [fairID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* price =  [NSString stringWithFormat:@"%@",[array objectAtIndex:1]];
            NSString* trimprice = [price stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            //NSString* currency =  [NSString stringWithFormat:@"%@",[array objectAtIndex:2]];
            //NSString* trimdCurrency= [currency stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            //NSString* price =  [NSString stringWithFormat:@"%@",[array objectAtIndex:3]];
            //NSString* trimprice = [price stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            
            double fareIDDouble = [trimFairID doubleValue];
            double priceDouble = [trimprice doubleValue];
            
            //double destinationIDDouble = [trimdestinationID doubleValue];
            
            
            NSString *query = [NSString stringWithFormat:@"insert into fareattributes (fare_id, price) values (?, ?)"];
            
            [db executeUpdate:query, [NSNumber numberWithDouble:fareIDDouble], [NSNumber numberWithDouble:priceDouble]];
        }
        
    }
    
    
}


- (void) CreatFareRulesDBTable
{
//    [db close];
//    [db open];
//    [db executeUpdate:@"DROP TABLE farerules"];
    
    //fare_id,origin_id,destination_id
    //2,81,82
    [db executeUpdate:@"create table farerules (fare_id double, origin_id double, destination_id double)"];
    
    if([db countTableEntries:@"farerules"]<=0)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"fare_rules" ofType:@"txt"];
        NSString *dataStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [dataStr componentsSeparatedByString:@"\n"];
        for(int i = 1; i<[lines count]-1; i++)
        {
            NSString *line = [lines objectAtIndex:i];
            NSArray *array = [line componentsSeparatedByString: @","];
            
            NSString* fairID =  [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
            NSString* trimFairID= [fairID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* originID =  [NSString stringWithFormat:@"%@",[array objectAtIndex:1]];
            NSString* trimoriginID = [originID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* destinationID =  [NSString stringWithFormat:@"%@",[array objectAtIndex:2]];
            NSString* trimdestinationID= [destinationID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            double fareIDDouble = [trimFairID doubleValue];
            double originIDDouble = [trimoriginID doubleValue];
            double destinationIDDouble = [trimdestinationID doubleValue];
            
            
            NSString *query = [NSString stringWithFormat:@"insert into farerules (fare_id, origin_id, destination_id) values (?, ?, ?)"];
            
            [db executeUpdate:query, [NSNumber numberWithDouble:fareIDDouble], [NSNumber numberWithDouble:originIDDouble], [NSNumber numberWithDouble:destinationIDDouble]];
        }
        
    }

    
}
- (void) createAnemitiesDBTable
{
    //route_id,bathroom,parking,parking_fee,bicycle_racks,waiting_area,contact_info
    
    [db executeUpdate:@"create table anemities (route_id text, bathroom text, parking text, parking_fee text, bicycle_racks text, waiting_area text, contact_info text)"];

    if([db countTableEntries:@"anemities"]<=0)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"anemities" ofType:@"txt"];
        NSString *dataStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [dataStr componentsSeparatedByString:@"\n"];
        for(int i = 1; i<[lines count]-1; i++)
        {
            NSString *line = [lines objectAtIndex:i];
            NSArray *array = [line componentsSeparatedByString: @","];
            
            
            
            NSString* routeID =  [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
            NSString* trimRouteID= [routeID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* bathroom =  [NSString stringWithFormat:@"%@",[array objectAtIndex:1]];
            NSString* trimBathroom= [bathroom stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* parking =  [NSString stringWithFormat:@"%@",[array objectAtIndex:2]];
            NSString* trimParking= [parking stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* parkingFee =  [NSString stringWithFormat:@"%@",[array objectAtIndex:3]];
            NSString* trimParkingFee= [parkingFee stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* bicycle =  [NSString stringWithFormat:@"%@",[array objectAtIndex:4]];
            NSString* trimBike= [bicycle stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* waiting =  [NSString stringWithFormat:@"%@",[array objectAtIndex:5]];
            NSString* trimWaiting= [waiting stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* contact =  [NSString stringWithFormat:@"%@",[array objectAtIndex:6]];
            NSString* trimContact= [contact stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString *query = [NSString stringWithFormat:@"insert into anemities (route_id,bathroom,parking,parking_fee,bicycle_racks,waiting_area,contact_info) values (?, ?, ?, ?, ?, ?, ?)"];
            
            [db executeUpdate:query, trimRouteID, trimBathroom, trimParking, trimParkingFee, trimBike, trimWaiting, trimContact];
            
        }

    
    }
        
        
}



//"shape_id","shape_pt_lat","shape_pt_lon","shape_pt_sequence"
- (void) createShapesDBTable
{
    
//    [db close];
//    [db open];
//    [db executeUpdate:@"DROP TABLE shapes"];

    //shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence
    //"shape_id","shape_pt_lat","shape_pt_lon","shape_pt_sequence"
    [db executeUpdate:@"create table shapes (shape_id text, shape_pt_lat text, shape_pt_lon text, shape_pt_sequence double)"];
    
    if([db countTableEntries:@"shapes"]<=0)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"shapes" ofType:@"txt"];
        NSString *dataStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [dataStr componentsSeparatedByString:@"\n"];
        for(int i = 1; i<[lines count]-1; i++)
        {
            NSString *line = [lines objectAtIndex:i];
            NSArray *array = [line componentsSeparatedByString: @","];
            
            
            
            NSString* shapeID =  [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
            NSString* trimShapeID= [shapeID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* shapePtLat =  [NSString stringWithFormat:@"%@",[array objectAtIndex:1]];
            NSString* trimShapePtLat= [shapePtLat stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* shapePtLon =  [NSString stringWithFormat:@"%@",[array objectAtIndex:2]];
            NSString* trimShapePtLon= [shapePtLon stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* shapePtSeq =  [NSString stringWithFormat:@"%@",[array objectAtIndex:3]];
            NSString* trimShapePtSeq= [shapePtSeq stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            
            NSString *query = [NSString stringWithFormat:@"insert into shapes (shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence) values (?, ?, ?, ?)"];
            
            [db executeUpdate:query, trimShapeID, trimShapePtLat, trimShapePtLon, trimShapePtSeq];
            
        }
    }
    
}

- (void) createStopTimesDBTable
{
    
    //trip_id,"arrival_time","departure_time",stop_id,stop_sequence,"stop_headsign",pickup_type
    //"trip_id","arrival_time","departure_time","stop_id","stop_sequence","stop_headsign","pickup_type","arrival_secs","departure_secs"
    if(m_BUpdatingDatabase)
    {
        [db close];
        [db open];
        [db executeUpdate:@"DROP TABLE stoptimes"];
    }
    [db executeUpdate:@"create table stoptimes (trip_id text, arrival_time text, departure_time text, stop_id text, stop_sequence integer, stop_headsign text)"];
    //metrolink removed arrival_secs & departure_secs in their April 22, 2013 update
    //, arrival_secs text, departure_secs text)"];
    
    if([db countTableEntries:@"stoptimes"]<=0)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"stop_times" ofType:@"txt"];
        NSString *dataStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [dataStr componentsSeparatedByString:@"\n"];
        for(int i = 1; i<[lines count]-1; i++)
        {
            NSString *line = [lines objectAtIndex:i];
            NSArray *array = [line componentsSeparatedByString: @","];
            
            
            
            NSString* tripID =  [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
            NSString* trimTripID= [tripID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* arrivalTime =  [NSString stringWithFormat:@"%@",[array objectAtIndex:1]];
            NSString* trimArrivalTime= [arrivalTime stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* departureTime =  [NSString stringWithFormat:@"%@",[array objectAtIndex:2]];
            NSString* trimDepartureTime= [departureTime stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* stopID =  [NSString stringWithFormat:@"%@",[array objectAtIndex:3]];
            NSString* trimStopID= [stopID stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSString* stopSeq =  [NSString stringWithFormat:@"%@", [array objectAtIndex:4]];
            NSString* trimStopSeq= [stopSeq stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber * numStopSeq = [f numberFromString:trimStopSeq];
            
            NSString* stopHeadsign =  [NSString stringWithFormat:@"%@",[array objectAtIndex:5]];
            NSString* trimStopHeadsign= [stopHeadsign stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            //NSString* arrivalSec =  [NSString stringWithFormat:@"%@",[array objectAtIndex:6]];
            //NSString* trimArrivalSec= [arrivalSec stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            //NSString* departureSec =  [NSString stringWithFormat:@"%@",[array objectAtIndex:7]];
            //NSString* trimDepartureSec= [departureSec stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            
            
            NSString *query = [NSString stringWithFormat:@"insert into stoptimes (trip_id, arrival_time, departure_time, stop_id, stop_sequence, stop_headsign) values (?, ?, ?, ?, ?, ?)"];
            
            [db executeUpdate:query, trimTripID, trimArrivalTime, trimDepartureTime, trimStopID, numStopSeq, trimStopHeadsign];
            
        }
    }
    
}



- (NSString*) convertTimeToStandard:(NSString*) time
{
    //dumb data-- check if the data is >25 first
    NSArray *array = [time componentsSeparatedByString: @":"];
    NSInteger hour = [[array objectAtIndex:0] intValue];
    if(hour >= 24)
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
    else
    {
        if(([dateComponents hour]-12) ==0)  //noon
            return [NSString stringWithFormat:@"%@ PM", time];
        return [NSString stringWithFormat:@"%@ AM", time];
    }
}




- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
      [db close];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        return YES;
    }
    return NO;

}



@end
