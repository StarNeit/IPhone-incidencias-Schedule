//
//  ViewController.m
//  DOPNavbarMenuDemo
//
//  Created by weizhou on 5/14/15.
//  Copyright (c) 2015 weizhou. All rights reserved.
//

#import "PostDetailController.h"
#import "SVProgressHUD.h"

@interface PostDetailController () <UITextViewDelegate>

@end

@implementation PostDetailController

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                               
                           }];
}
-(void)myTimerCallback:(NSTimer*)timer
{
    if (self.spendTime == -1){
        [self.timer invalidate];
        self.timer = nil;
    }
    self.spendTime ++;
    if (self.spendTime > 45){
        [SVProgressHUD dismiss];
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Warning" message:NSLocalizedString(@"Your network status is not ok.Please try again",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [errorAlert show];
        self.spendTime = 0;
        [self.timer invalidate];
        self.timer = nil;
        
        [self.navigationController popToViewController: [[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD show];
    
    self.spendTime = 0;
    //timer
    SEL mySelector = @selector(myTimerCallback:);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:mySelector userInfo:nil repeats:YES];
    
    
    self.title = NSLocalizedString(@"Post",nil);
    self.m_description.text = ga_expone[g_curindex];
    self.m_date.text = ga_fecha[g_curindex];
    self.m_hour.text = ga_hora[g_curindex];
    self.m_name.text = ga_nombres[g_curindex];
    self.m_lastname.text = ga_apellidos[g_curindex];
    self.m_latitude = ga_latitud[g_curindex];
    self.m_longitude = ga_longitud[g_curindex];
    self.m_foto = ga_foto[g_curindex];
    
    // download the image asynchronously
    [self downloadImageWithURL:[NSURL URLWithString: self.m_foto] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            // change the image in the cell
            self.m_imageView.image = image;
        }
        [SVProgressHUD dismiss];
        self.spendTime = -1;
    }];
    
    //---------my position-------
    MKPointAnnotation *annot2 = [[MKPointAnnotation alloc] init];
    annot2.title = NSLocalizedString(@"My location",nil);
    annot2.subtitle = NSLocalizedString(@"This is my location",nil);
    
    CLLocationCoordinate2D touchMapCoordinate2;
    touchMapCoordinate2 = CLLocationCoordinate2DMake(self.m_latitude, self.m_longitude);
    annot2.coordinate = touchMapCoordinate2;
    [self.mapview addAnnotation:annot2];
    
    
    float spanX = 0.5;
    float spanY = 0.5;
    MKCoordinateRegion region;
    region.center.latitude = self.m_latitude;//self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.m_longitude;//self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    @try {
        [self.mapview setRegion:region animated:YES];
    }
    @catch (NSException *exception) {
        
    }
    
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:self.m_latitude longitude:self.m_longitude]; //insert your coordinates
    
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  //String to hold address
                  NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@","];
                  self.m_address.text = locatedAt;
              }
     ];
}


- (void)openMenu:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end