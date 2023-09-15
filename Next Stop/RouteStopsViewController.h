//
//  RouteStopsViewController.h
//  Next Stop
//
//  Created by Alberto Martinez on 8/5/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteDetailsClass.h"
#import "AppDelegate.h"


@interface RouteStopsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSString* routeID; //short name, like "682"
    NSMutableArray* details;
    AppDelegate *app ;
    
}
@property (nonatomic, retain) AppDelegate* app;
@property (nonatomic, retain) NSString* routeID;
@property (nonatomic, retain) IBOutlet UILabel *myLabel;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray* details;
@end

