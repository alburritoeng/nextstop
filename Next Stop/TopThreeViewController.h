//
//  TopThreeViewController.h
//  Next Stop
//
//  Created by Alberto Martinez on 8/2/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestiPhoneCalViewController.h"
#import "AppDelegate.h"

@interface TopThreeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray* trains;
    NSMutableDictionary* ridesInDict;
    NSDictionary* ridesOutDict;
    NSMutableArray* myIndex ;
    IBOutlet UILabel *NoticeLabel;
    NSString* note;
    int theDay;
    TestiPhoneCalViewController* v ;
    AppDelegate *app;
    NSString* stopID;
    NSString* routeID;
}
@property (nonatomic,copy) NSString* stopID;
@property (nonatomic,copy) NSString* routeID;
@property (nonatomic, retain) AppDelegate*app;
@property int theDay;
@property(nonatomic, retain) NSMutableArray* trains;
@property(nonatomic, retain) NSMutableDictionary* ridesInDict;
@property(nonatomic, retain) NSDictionary* ridesOutDict;
@property(nonatomic, retain) NSMutableArray* myIndex ;
@property(nonatomic, retain) NSString* note;

@property(nonatomic, retain)  TestiPhoneCalViewController* v ;

@end
