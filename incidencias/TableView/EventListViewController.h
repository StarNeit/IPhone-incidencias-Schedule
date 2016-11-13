//
//  CarListViewController.h
//  AddItemTableViewDemo
//
//  Created by Arthur Knopper on 15-06-13.
//  Copyright (c) 2013 Arthur Knopper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarDetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "global.h"

@interface EventListViewController : UITableViewController<UIAlertViewDelegate, CLLocationManagerDelegate>

@property int postCnt;
@property NSTimer *timer;
@property double myLatitude;
@property double myLongitude;
@property double spendTime;
@end
