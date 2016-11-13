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

@interface NewPostController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerController *ipc;
    UIPopoverController *popover;
}


@property (strong, nonatomic) IBOutlet UIScrollView *uiScrollView;
@property (strong, nonatomic) IBOutlet UIView *uiScrollContentView;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UILabel *myAddress;
@property (strong, nonatomic) IBOutlet UITextField *myName;
@property (strong, nonatomic) IBOutlet UITextField *myLastName;
@property (strong, nonatomic) IBOutlet UITextField *myCellphone;
@property (strong, nonatomic) IBOutlet UITextField *myDescription;
@property (strong, nonatomic) IBOutlet UIImageView *ivPickedImage;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnItemGallery;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnItemCamera;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;


@property (weak, nonatomic) IBOutlet UIButton *btnGallery;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;


@property NSTimer *timer;
@property int flagOfDoPost;
@property int flagOfDescInput;
@property double spendTime;

@end

