//
//  StationsViewController
//  Next Stop
//
//  Created by Alberto Martinez on 8/1/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface StationsViewController : UIViewController <UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>//<UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    UITableView *myTableView;
    AppDelegate *app;
    NSArray* stopNames;
  
    
    NSMutableArray* searchedData;
    UISearchBar *searchBar;
    UISearchDisplayController *searchController ;
    
    
}
@property (nonatomic, retain) UISearchDisplayController *searchController;
@property (nonatomic, retain) NSMutableArray* searchedData;
@property (nonatomic, retain) UISearchBar *searchBar;


@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) AppDelegate* app;
@property (nonatomic, retain) NSArray *stopNames;




@end
