//
//  AlertsViewController.m
//  Next Stop
//
//  Created by Alberto Martinez on 8/2/12.
//  Copyright (c) 2012 Alberto Martinez. All rights reserved.
//

#import "AlertsViewController.h"
#import "TDOAuth.h"


@interface AlertsViewController ()
@property(nonatomic, retain) IBOutlet UITableView *myTableView;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;
@end

@implementation AlertsViewController
@synthesize twitterText, tweetTime, myTableView;
@synthesize activity;
@synthesize tweetz;

@synthesize receivedData;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Alerts", @"Alerts");
        self.tabBarItem.image = [UIImage imageNamed:@"alert3"];
        UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self  action:@selector(alertRefreshData)];
        self.navigationItem.rightBarButtonItem = refreshBtn;
    }
    return self;
}


- (void) alertRefreshData
{
    [self.tweetz removeAllObjects];
    
    [self.myTableView reloadData];
    [self performSelector:@selector(getTwitterData) withObject:nil afterDelay:1.5];
    //[self getTwitterData];
}
- (void) getTwitterData
{
    NSString* CONSUMER_KEY = [NSString stringWithFormat:@"pyabDlJ9xfY7XJhJkPtkcQ"];
    NSString* CONSUMER_SECRET = [NSString stringWithFormat:@"h7FlK7AMyyXkYBvtAL4w9I9rC6Er6kZ1iXgFQPmWTw"];
    NSString* accessToken = [NSString stringWithFormat:@"269448541-DeTXN0wxlzEeKfewu9PT1JnDsGT52cmwGYrIOX4Q"];
    NSString* tokenSecret = [NSString stringWithFormat:@"v6H7Vt0dJG99h4B5p5XatGEwTqN9VbNTf3t1PNcavOA"];

    
    //    269448541-DeTXN0wxlzEeKfewu9PT1JnDsGT52cmwGYrIOX4Q
//    Access token secret	v6H7Vt0dJG99h4B5p5XatGEwTqN9VbNTf3t1PNcavOA

    NSDictionary *params1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Metrolink", @"screen_name", @"35", @"count", @"1", @"exclude_replies" ,nil];


    //Updated for API 1.1 6/11/13   - https://api.twitter.com/1.1/statuses/user_timeline.json
    NSURLRequest *echo = [TDOAuth URLRequestForPath:@"/1.1/statuses/user_timeline.json" //@"/1/account/verify_credentials.json"
                                      GETParameters:params1//nil
                                             scheme:@"https"
                                               host:@"api.twitter.com"
                                        consumerKey:CONSUMER_KEY
                                     consumerSecret:CONSUMER_SECRET
                                        accessToken:accessToken
                                        tokenSecret:tokenSecret];


    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:echo delegate:self];

    receivedData = [[NSMutableData alloc] init];
    
    if(theConnection)
    {}
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    
    NSError *jsonError = nil;
   
    NSMutableArray *tweets = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:&jsonError];
    
    id json = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:&jsonError];
    //NSLog(@"%@", json);
    if ([json isKindOfClass:[NSDictionary class]]) {
        
        if([json objectForKey:@"errors"])
        {
            NSArray *trends = [json objectForKey:@"errors"];
            NSDictionary *msg = [trends objectAtIndex:0];
    
            long code = (long) [msg objectForKey:@"code"];
            if(code!=200)
                return;
        }
        
    }
    else    //else dictionary
    {
    
        if (tweets) {
               
            //  set our 'datastore' to the returned array of tweets
            self.tweetz = tweets;
        
            //filter the results for RT
            [self filterResults];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                // tell our table to reload itself, but make sure we do this on the main thread
            [self.myTableView reloadData];
            });
        }
        else {
        NSLog(@"An error occurred process JSON: %@", [jsonError localizedDescription]);
        }

    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}



- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error =%@", [error userInfo]);
}




- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  
    [self getTwitterData];
    return;
   }

- (void) filterResults
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"not text contains 'RT'"];
    NSArray* data = [NSMutableArray arrayWithArray:self.tweetz];
    NSArray* filteredArray = [data filteredArrayUsingPredicate:pred];
    [self.tweetz removeAllObjects    ];
    self.tweetz = [[NSMutableArray alloc] initWithArray:filteredArray];
    
    return;
  }

- (BOOL)_hasTweetsToShow
{
    return (tweetz && [tweetz count] > 0);
}


- (void) viewWillAppear:(BOOL)animated
{
     self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [super viewWillAppear:animated] ;
}



- (NSDate*) dateInMyTimeZone:(NSDate*)sourceDate
{
    //this code gets me the current time in MY timezone in 24-hour format
   // NSDate* sourceDate = [NSDate date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval inter = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* currentDate = [[NSDate alloc] initWithTimeInterval:inter sinceDate:sourceDate];
    return currentDate;
    
}
- (double) getTimeSinceNowForAlertDate:(NSDate*)alertDate
{
    //a return val of 0 means do not post this alert view to the user!
    
    /*************For current date*************/
    //this code gets me the current time in MY timezone in 24-hour format
    NSDate* sourceDate = [NSDate date];
    NSDate* currentDate = [self dateInMyTimeZone:sourceDate];
    /************end for current date**********/

    // If the receiver is earlier than anotherDate, the return value is negative.
    NSTimeInterval interval = [alertDate timeIntervalSinceDate:currentDate];
    if(interval <0)
    {
        
        return interval*= -1;
    }

    return 0;
}


- (NSDate*) convertToUTC:(NSDate*)sourceDate withOffset:(double)offset
{
    NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
    if([systemTimeZone isDaylightSavingTime])
    {
        NSDate* date1;// = [[NSDate alloc] init];
        date1 = [NSDate date];
        NSTimeInterval dstInterval = [systemTimeZone daylightSavingTimeOffsetForDate:date1];
        
        offset += dstInterval;
    }
   
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:offset sinceDate:sourceDate];
   
    return destinationDate;    
}



- (NSDate*) dateCheck:(NSString*) time withOffset:(double) offset
{
    NSDateFormatter *fromTwitter = [[NSDateFormatter alloc] init];
    [fromTwitter setDateFormat:@"EEE MMM dd HH:mm:ss '+0000' yyyy"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    [df setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    NSDate *date = [df dateFromString:time];
    NSDate *tweetDateCorrected =  [self convertToUTC:date withOffset:offset];
    
    return tweetDateCorrected;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self _hasTweetsToShow]) {
        return [tweetz count];
    }
    
    //  we return 1 for our 'loading' message
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _hasTweetsToShow]) {
    return 120;
    }
    else
        return 40;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //NSLog(@"%@", cell.textLabel.text);
    if ([cell.textLabel.text rangeOfString:@"Next Stop"].location == NSNotFound)
    {
        return;
    } 
    
    
    //if(cell.text isEqualToString:);
    
    //NSString *stringUrl = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=XXXXXXXX&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8";
    //NSURL *url = [NSURL URLWithString:stringUrl];
    //[[UIApplication sharedApplication] openURL:url];
    
    //NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (ver >= 7.0) {
    NSString *str = @"https://itunes.apple.com/WebObjects/MZStore.woa";
    str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str];
    str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
    
    // Here is the app id from itunesconnect
    str = [NSString stringWithFormat:@"%@554042092", str];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }else
    {
        NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
        str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str];
        str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
        
        // Here is the app id from itunesconnect
        str = [NSString stringWithFormat:@"%@554042092", str];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if ([self _hasTweetsToShow]) {
        //  in each returned object, there is a 'text' attribute that is the status
        //NSMutableArray* retData = [self parseResponse:[self.twitter]]

        //trying to remove entry 0...which is invalid?
        //so add 1 to the index, but don't go over the [tweetz count]
        //did this b/c I was seeing "Loading" entry when I had valid results... lets see if this works
        //its ok if this logic truncates the last entry...it'll most likely be too old of an Alert.
        
        int r = indexPath.row;//+1;
        ///if(r>[self.tweetz count]-1)
           // r = r-1;//[self.tweetz objectAtIndex:r-1];
//        NSArray * userDict = [self.tweetz objectAtIndex:indexPath.row] ;//[tweet objectForKey:@"user"];
//        NSDictionary* userTweet = (NSDictionary*)userDict;//(NSDictionary*)userDict;
//        NSMutableArray* retData = [self parseResponse:userTweet withTime:[[self.tweetz objectAtIndex:indexPath.row] objectForKey:@"created_at"] withTweetText:[[self.tweetz objectAtIndex:indexPath.row] objectForKey:@"text"]];
        //NSLog(@"row = %d, r=%d ", indexPath.row, r);
        NSArray * userDict = [self.tweetz objectAtIndex:r] ;
        NSDictionary* userTweet = (NSDictionary*)userDict;
        NSMutableArray* retData = [self parseResponse:userTweet withTime:[[self.tweetz objectAtIndex:r] objectForKey:@"created_at"] withTweetText:[[self.tweetz objectAtIndex:r] objectForKey:@"text"]];

        
        if(retData!=nil)
        {
            NSString* tweetValue = [NSString stringWithFormat:@"%@", [retData objectAtIndex:1]];
            NSString* timeValue = [NSString stringWithFormat:@"%@\n", [retData objectAtIndex:0]];
            cell.textLabel.text = tweetValue;//[retData objectAtIndex:1];
            cell.detailTextLabel.text = timeValue;//[retData objectAtIndex:0];
            cell.detailTextLabel.numberOfLines = 4;
            cell.accessoryType = UITableViewCellAccessoryNone;
            //NSLog(@"%d, %@", indexPath.row, tweetValue);
            return cell;
          //  cell.textLabel.text = [[self.tweetz objectAtIndex:indexPath.row] objectForKey:@"text"];
        }
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"Next Stop Metrolink"];
            cell.detailTextLabel.text =[NSString stringWithFormat:@"Remember to review Next Stop Metrolink in the AppStore"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //NSLo g(@"%d row is invalid", indexPath.row);
        }
    }
    else {
        cell.textLabel.text = @"Loading alerts...";
        cell.detailTextLabel.numberOfLines = 1;
    }
    
    return cell;
}


- (NSDate*) getTweetDate: (NSString*) dateString
{
    //NSString *dateString = @"01-02-2010";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    //Sun Aug 18 16:05:46 +0000 2013
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];//dd-MM-yyyy"];
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];//[[NSDate alloc] init];
    //dateFromString =[dateFormatter dateFromString:dateString];
    //NSLog(@"** %@", dateString);
    //NSLog(@"*** %@", dateFromString);
    
    NSString *localDate = [NSDateFormatter localizedStringFromDate:dateFromString dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    NSLog(@"localDate = %@", localDate);
    //NSLog(@"date with local timezone is: %@",
     //     [dateFromString descriptionWithLocale:[NSLocale systemLocale]]);

    
    // voila!
    dateFromString = [dateFormatter dateFromString:dateString];
    //[dateFormatter release];
    return dateFromString;
}

- (NSMutableArray*) parseResponse: (NSDictionary*) user withTime:(NSString*)created_at withTweetText:(NSString*) text
{
    //NSArray* userDict1 = [ user objectForKey:@"user"];
   // NSDictionary* userTweet1 = (NSDictionary*)userDict1;
    
   // NSArray * userDict = [tweet objectForKey:@"user"];
    //NSDictionary* userTweet = user;//(NSDictionary*)userDict;
    NSString *twittext = text;//[tweet objectForKey:@"text"];
   // NSLog(@"userText = %@", userTweet);
    //NSString *timeTemp = created_at;//[tweet objectForKey:@"created_at"];
    //NSString* offSetString = [userTweet1 objectForKey:@"utc_offset"];
    //NSLog(@"%@", created_at);
    
    
   // NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   // NSDate *dateFromString = [dateFormatter dateFromString:created_at];//[[NSDate alloc] init]; // <- non freed instance
   // dateFromString = [dateFormatter dateFromString:created_at];
    

    // Get minutes & hours since
    NSTimeInterval timeInterval = [[self getTweetDate:created_at] timeIntervalSinceNow];
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    // Create the NSDates
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:date1];
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
    NSInteger minutes = -1*[conversionInfo minute];
    NSInteger hours =  -1*[conversionInfo hour];
    NSInteger days = [conversionInfo day];
//  NSLog(@"Conversion: %dmin %dhours %ddays %dmoths",-1*[conversionInfo minute], -1*[conversionInfo hour], [conversionInfo day], [conversionInfo month]);

    
    
    /*
    
    
    [self getTweetDate:created_at];
   // NSLog(@"time interval = %f", timeInterval);
   // NSLog(@"date =%@, time since = %f", [self getTweetDate:created_at],timeInterval);
    
    
    double offSet =[offSetString doubleValue];
    
    NSDate* time2 = [self dateCheck:timeTemp withOffset:offSet];

    NSDateFormatter* inFormat = [[NSDateFormatter alloc] init];
    [inFormat setDateFormat:@"hh:mm:ss a"];
    [inFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    //NSLog(@"%@", time2);
    double timeSinceTweet = [self getTimeSinceNowForAlertDate:time2];
    double val = timeSinceTweet/60;
    double val2 = timeSinceTweet/3600;
    //double val3 = timeSinceTweet/21600;
    NSString *strTimeSinceTweet ;
   // NSLog(@"offset = %f, time = %@, val = %f", offSet, time2,val);
     
    
    if(val<60)
    {
        strTimeSinceTweet= [NSString stringWithFormat:@"%d minutes ago", (int)val];
    }
    else if(val2 < 24)
    {
        if((int)floor(val) == 1)
            strTimeSinceTweet= [NSString stringWithFormat:@"%d hour ago", (int)floor(val2)];
        else
            strTimeSinceTweet= [NSString stringWithFormat:@"%d hours ago", (int)floor(val2)];
    }
    else
        return nil;
*/
    //if([twittext rangeOfString:@"RT"].location  ==0)
      //  return nil;//                         continue;
    NSString *strTimeSinceTweet ;
    NSLog(@"day %d", days);
    if(days!=0)
        return nil;
    if(hours<1)
    {
        strTimeSinceTweet= [NSString stringWithFormat:@"%d minutes ago", minutes];
    }
    else if(hours < 24)
    {
        if(hours == 1)
            strTimeSinceTweet= [NSString stringWithFormat:@"%d hour %d min ago", hours, minutes];
        else
            strTimeSinceTweet= [NSString stringWithFormat:@"%d hours %d min ago", hours, minutes];
    }
    else
        return nil;
    
    
    NSMutableArray* object = [[NSMutableArray alloc]init];
    [object addObject:twittext];
    [object addObject:strTimeSinceTweet ];
    return object;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self twitterQuery];
   
}

- (void)viewDidUnload
{

    myTableView = nil;
    activity = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




@end
