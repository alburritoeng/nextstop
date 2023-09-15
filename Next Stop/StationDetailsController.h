//
//  StationDetailsController.h
//  Next Stop
//
//  Created by Alberto Martinez on 8/16/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Anemities.h"
#import <CoreLocation/CoreLocation.h>

@interface StationDetailsController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    NSMutableArray* stationDetails;
    NSString* stationName;
    CLGeocoder *geocoder;
    NSString* stationAddress;
    IBOutlet UITableView *myTableView;
    
    
}
@property (nonatomic, retain) NSMutableArray* stationDetails;
@property (nonatomic, copy) NSString* stationName;
@property (nonatomic, copy) NSString* stationAddress;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, retain)  IBOutlet UITableView *myTableView;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (BOOL)tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender;

@end
