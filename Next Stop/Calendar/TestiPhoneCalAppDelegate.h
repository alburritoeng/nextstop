//
//  TestiPhoneCalAppDelegate.h
//  TestiPhoneCal
//
//  Created by tinyfool on 10-3-6.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestiPhoneCalViewController;

@interface TestiPhoneCalAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestiPhoneCalViewController *viewController;
    int theChosenDay;
}
@property int theChosenDay;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestiPhoneCalViewController *viewController;

@end

