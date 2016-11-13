//
//  ViewController.h
//  DOPNavbarMenuDemo
//
//  Created by weizhou on 5/14/15.
//  Copyright (c) 2015 weizhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "global.h"

@interface PostDetailController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *m_date;
@property (strong, nonatomic) IBOutlet UILabel *m_hour;
@property (strong, nonatomic) IBOutlet UILabel *m_description;
@property (strong, nonatomic) IBOutlet UILabel *m_name;
@property (strong, nonatomic) IBOutlet UIImageView *m_imageView;
@property (strong, nonatomic) IBOutlet UILabel *m_address;
@property (strong, nonatomic) IBOutlet MKMapView *mapview;
@property (strong, nonatomic) IBOutlet UILabel *m_lastname;
@property double m_latitude;
@property double m_longitude;
@property NSString *m_foto;

@property double spendTime;
@property NSTimer *timer;


@end
