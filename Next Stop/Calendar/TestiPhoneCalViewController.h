//
//  TestiPhoneCalViewController.h
//  TestiPhoneCal
//
//  Created by tinyfool on 10-3-6.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestiPhoneCalViewController : UIViewController {

    IBOutlet UIView *mainView;
    int m_day;

}
@property int m_day;
@property (nonatomic, retain) IBOutlet UIView* mainView;

- (IBAction)closeCalendar:(id)sender;
- (IBAction)chooseNow:(id)sender;

@end


