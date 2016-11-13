//
//  ViewController.h
//  DOPNavbarMenuDemo
//
//  Created by weizhou on 5/14/15.
//  Copyright (c) 2015 weizhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "global.h"

@interface ViewController : UIViewController<UIAlertViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property double myLatitude;
@property double myLongitude;

@end

