//
//  FirstViewController.h
//  Next Stop
//
//  Created by Alberto Martinez on 8/1/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoutesViewController: UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    
    NSMutableDictionary *routesDict ;
    NSMutableArray *listX;
    NSMutableDictionary * routeAndColor;
    

    NSArray* routeNames;
}

@property(nonatomic, retain)    NSMutableDictionary *routesDict ;
@property(nonatomic, retain)    NSMutableArray *listX;
@property(nonatomic, retain)    NSMutableDictionary* routeAndColor;
@property(nonatomic, retain)    NSArray* routeNames;


@end
