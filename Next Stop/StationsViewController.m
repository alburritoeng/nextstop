//
//  StationsViewController
//  Next Stop
//
//  Created by Alberto Martinez on 8/1/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import "StationsViewController.h"
#import "AppDelegate.h"
#import "TopThreeViewController.h"

@interface StationsViewController ()

@end

@implementation StationsViewController
@synthesize myTableView, app, stopNames;
@synthesize searchedData;
@synthesize searchBar;
@synthesize searchController ;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Stations", @"Stations");
        self.tabBarItem.image = [UIImage imageNamed:@"trainexample"];
        //stopNameAndStopId
        app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        stopNames = [[NSMutableArray alloc]init];
        NSMutableArray* tempArray = [[NSMutableArray alloc]init];
        for(id ob in app.stopNameAndStopId)
        {
            [tempArray addObject:ob];
        }
        
        stopNames = [tempArray sortedArrayUsingSelector:@selector(compare:)];
        searchedData = [[NSMutableArray alloc]init];
            }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.delegate = self;
    
    self.myTableView.tableHeaderView = searchBar;
    
    searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    searchController.delegate = self;
    
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.searchedData removeAllObjects];

    for(NSString* group in stopNames) 
    {
        NSRange range = [group rangeOfString:searchString options:NSCaseInsensitiveSearch];
        if (range.length != 0)
        {
            //if the substring match
            [searchedData addObject:group];
        }
    }
    return YES;
}


- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [super viewWillAppear:animated] ;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
    NSUInteger row = [indexPath row];
    NSString* stopID;
    NSString* routeID;
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        stopID=  [app.stopNameAndStopId objectForKey:[searchedData objectAtIndex:row]];
        routeID = [searchedData objectAtIndex:row];
    }
    else
    {
        //NSString* temp = [stopNames objectAtIndex:row];
        stopID=  [app.stopNameAndStopId objectForKey:[stopNames objectAtIndex:row]];
        routeID = [stopNames objectAtIndex:row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    NSMutableArray* possibleStops = [app getStopsForStopId:stopID stripStops:NO];
    
    TopThreeViewController *topThreeView = [[TopThreeViewController alloc] initWithNibName:@"TopThreeViewController" bundle:nil];
    topThreeView.trains = possibleStops;
    topThreeView.title = @"Trains";
    topThreeView.stopID=stopID;
    topThreeView.note = [NSString stringWithFormat:@"**All** stops %@", routeID];
    [self.navigationController pushViewController:topThreeView animated:YES];
    
    
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        return YES;
    }
    return NO;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        // search view population
        return [self.searchedData count];
    } else {
        return [stopNames count];
    }
    
    
   // return [stopNames count];// [app.stopNameAndStopId count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
       
        cell.textLabel.text = [searchedData objectAtIndex:indexPath.row];//[app.stopNameAndStopId obje]
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    }
    else
    {
    cell.textLabel.text = [stopNames objectAtIndex:indexPath.row];//[app.stopNameAndStopId obje]
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end
