//
//  TopThreeViewController.m
//  Next Stop
//
//  Created by Alberto Martinez on 8/2/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import "TopThreeViewController.h"
#import "AppDelegate.h"
#import "RouteStopsViewController.h"
#import "TestiPhoneCalViewController.h"
#import "TdCalendarView.h"
#import "TestiPhoneCalViewController.h"

@interface TopThreeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *DirInStop1Btn;
@property (weak, nonatomic) IBOutlet UIButton *DirInStop2Btn;
@property (weak, nonatomic) IBOutlet UIButton *DirInStop3Btn;
@property (weak, nonatomic) IBOutlet UIButton *DirOutStop1Btn;
@property (weak, nonatomic) IBOutlet UIButton *DirOutStop2Btn;
@property (weak, nonatomic) IBOutlet UIButton *DirOutStop3Btn;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;


@end

@implementation TopThreeViewController
@synthesize DirInStop1Btn;
@synthesize DirInStop2Btn;
@synthesize DirInStop3Btn;
@synthesize DirOutStop1Btn;
@synthesize DirOutStop2Btn;
@synthesize DirOutStop3Btn;
@synthesize myTableView;
@synthesize theDay;
@synthesize ridesInDict, ridesOutDict, myIndex, note;
@synthesize trains; //for the correct train order by time
@synthesize v;
@synthesize app;
@synthesize stopID;
@synthesize routeID;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithTitle:@"Choose Day" style:UIBarButtonItemStyleBordered target:self  action:@selector(showCalendar)];
        self.navigationItem.rightBarButtonItem = refreshBtn;
        v = [[TestiPhoneCalViewController alloc] initWithNibName:@"TestiPhoneCalViewController" bundle:nil];
       app   = (AppDelegate *)[[UIApplication sharedApplication] delegate];
           v.m_day = -1;
            }
    return self;
}


- (void) showCalendar
{
    
    v.m_day = -1;
    [self.navigationController presentViewController:v animated:YES completion:nil];
   
}

- (NSString*) getStringFromDayInt:(int)day
{
    
    switch (day) {
        case 0:
            return @"Monday";
            break;
        case 1:
            return @"Tuesday";
            break;
        case 2:
            return @"Wednesday";
            break;
        case 3:
            return @"Thursday";
            break;
        case 4:
            return @"Friday";
            break;
        case 5:
            return @"Saturday";
            break;
        case 6:
            return @"Sunday";
            
            
        default:
            return @"Monday";
            break;
    }
    
}



- (void)viewWillAppear:(BOOL)animated
{
    
    if(v.m_day>-1)
    {
        [self.myIndex removeAllObjects];
        [self.trains removeAllObjects];
        self.trains = [app getStopsForStopId:self.stopID stripStops:NO forDay:v.m_day];
       // NSLog(@"%@", trains);
        [ridesInDict removeAllObjects];
        ridesInDict = [[NSMutableDictionary alloc] init];
        for(NSString* s in self.trains)
        {
            NSArray* entry = [s componentsSeparatedByString:@","];
            NSLog(@"%@    and    %@", [entry objectAtIndex:0], [entry objectAtIndex:1]);
            [myIndex addObject:[entry objectAtIndex:0]];
            [self.ridesInDict setObject:[entry objectAtIndex:1] forKey:[entry objectAtIndex:0]];
            
        }

        if([routeID length] == 0)
        {
            // NSString* stopID = [app.stopNameAndStopId objectForKey:str]; 
            routeID = [app.stopIDAndStopName objectForKey:self.stopID];
        }
        
        NoticeLabel.text = [NSString stringWithFormat:@"**All** Trains For %@ \nRoute: %@", [self getStringFromDayInt:v.m_day], routeID];
        
        
        [self.myTableView reloadData];
        [self.myTableView setNeedsDisplay];
    }
    else if(v.m_day == -2)
    {
        [self.myIndex removeAllObjects];
        [self.trains removeAllObjects];
        self.trains = [app getStopsForStopId:self.stopID];
        // NSLog(@"%@", trains);
        [ridesInDict removeAllObjects];
        ridesInDict = [[NSMutableDictionary alloc] init];
        for(NSString* s in self.trains)
        {
            NSArray* entry = [s componentsSeparatedByString:@","];
            NSLog(@"%@    and    %@", [entry objectAtIndex:0], [entry objectAtIndex:1]);
            [myIndex addObject:[entry objectAtIndex:0]];
            [self.ridesInDict setObject:[entry objectAtIndex:1] forKey:[entry objectAtIndex:0]];
            
        }
        
        if([routeID length] == 0)
        {
            // NSString* stopID = [app.stopNameAndStopId objectForKey:str];
            routeID = [app.stopIDAndStopName objectForKey:self.stopID];
        }
        
        NoticeLabel.text = [NSString stringWithFormat:@"**Remaining** Trains For %@ \nRoute: %@", [self getDay], routeID];
        //[NSString stringWithFormat:@"**All** Trains For %@ \nRoute: %@", [self getStringFromDayInt:v.m_day], routeID];
        
        
        [self.myTableView reloadData];
        [self.myTableView setNeedsDisplay];
    }
    

    [super viewWillAppear:animated];
}


- (NSString*) getDay
{
    NSDateFormatter* theDateFormatter = [[NSDateFormatter alloc] init];
    [theDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [theDateFormatter setDateFormat:@"EEEE"];
    return [theDateFormatter stringFromDate:[NSDate date]];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        return YES;
    }
    return NO;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    myIndex = [[NSMutableArray alloc] init];
    [self.ridesInDict  removeAllObjects];
    ridesInDict = [[NSMutableDictionary alloc] init];
    for(NSString* s in self.trains)
    {
        NSArray* entry = [s componentsSeparatedByString:@","];
        NSLog(@"%@    and    %@", [entry objectAtIndex:0], [entry objectAtIndex:1]);
        [myIndex addObject:[entry objectAtIndex:0]];
        [self.ridesInDict setObject:[entry objectAtIndex:1] forKey:[entry objectAtIndex:0]];

    }
    NoticeLabel.text = note;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if([self.myIndex count] ==0)
        return 1;
    return [self.myIndex count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//NSLog(@"cellForRowAtIndexpath = %d", [indexPath row]);
    static NSString *CellIdentifier = @"DetailViewCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier];
    }
    if ([myIndex count]==0)
    {
        cell.textLabel.text = @"No more trains available today...";
        cell.detailTextLabel.numberOfLines = 1;
        return cell;
     }
   
    NSInteger row = indexPath.row;
   
    
    NSString* titleHeading =  [app getLastStopFromShortName:[myIndex objectAtIndex:row]];
    assert(![titleHeading isEqualToString:NULL]);
    NSString* time = [NSString stringWithFormat:@"%@", [self convertTimeToStandard:[ridesInDict objectForKey:[myIndex objectAtIndex:row]]]];
    NSString* headingTo = [NSString stringWithFormat:@"%@", titleHeading];

    
    NSString* trainNum = [NSString stringWithFormat:@"%@", [myIndex objectAtIndex:row]];
    NSString* startingFrom = [NSString stringWithFormat:@"%@", [app getFirstStopForTripShortName:trainNum]];
    NSString* arrival_time = [ NSString stringWithFormat:@"%@", [app getArrivalTimeForTrainNum:trainNum]];
                              
                              //[app getArrivalTimeForStopId:headingTo withTripId:[app getTripIdFromShortNumber:trainNum]]];
     assert(![startingFrom isEqualToString:headingTo]);
    //heading to
    NSString* ID = [NSString stringWithFormat:@"%@", [app.shortToRouteId objectForKey:trainNum]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ @ %@",ID, trainNum, time];
    cell.detailTextLabel.numberOfLines = 4;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Headed to %@ from %@ scheduled to arrive in %@ at %@", headingTo, startingFrom, headingTo, [self convertTimeToStandard:arrival_time]];
    
    if([app.bikeCars containsObject:trainNum])
        cell.imageView.image = [UIImage imageNamed:@"bike-icon.png"];
    else
        cell.imageView.image= nil;
    //bike-icon.png
    
    
    return cell;
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
    //else
    //    return [NSString stringWithFormat:@"%@ AM", time];
    
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  //  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
 [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([self.myIndex count] ==0)
        return;
    RouteStopsViewController* view = [[RouteStopsViewController alloc] initWithNibName:@"RouteStopsViewController" bundle:nil];
   

    NSString* routeName = [self.myIndex objectAtIndex:indexPath.row];
    
    //No trains remaining today...
    //this will be in the format short name, for example "682"
    //let the viewcontroller query the route details
    view.routeID = routeName;
      NSString* ID = [NSString stringWithFormat:@"%@", [app.shortToRouteId objectForKey:routeName]];
    view.title = [NSString stringWithFormat:@"%@ %@", ID, routeName];
    [self.navigationController pushViewController:view animated:YES];

}




- (void)viewDidUnload
{
    [self setDirInStop1Btn:nil];
    [self setDirInStop2Btn:nil];
    [self setDirInStop3Btn:nil];
    [self setDirOutStop1Btn:nil];
    [self setDirOutStop2Btn:nil];
    [self setDirOutStop3Btn:nil];

    [self setMyTableView:nil];
    NoticeLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// i need to write a sort function for the results






@end
