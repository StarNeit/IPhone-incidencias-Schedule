//
//  ViewController.m
//  DOPNavbarMenuDemo
//
//  Created by weizhou on 5/14/15.
//  Copyright (c) 2015 weizhou. All rights reserved.
//

#import "NewPostController.h"
#import "DOPNavbarMenu.h"
#import "SVProgressHUD.h"
#import "NSString+Encode.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface NewPostController () <UITextViewDelegate, DOPNavbarMenuDelegate>

@end

@implementation NewPostController

@synthesize btnCamera,btnGallery;
@synthesize btnItemCamera,btnItemGallery;
@synthesize ivPickedImage;

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    
    //1:yes
    //0:no
  
        if (alertView.tag == 12) {
            if (buttonIndex == 0) //no
            {
                [SVProgressHUD dismiss];
                
                //redirecting...
                UIStoryboard *mainStorynboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *documetController;
                documetController = [mainStorynboard instantiateViewControllerWithIdentifier:@"postviewcontroller"];
                [self.navigationController pushViewController:documetController animated:YES];
                
                
                
                
            }else if (buttonIndex == 1){
                SEL mySelector = @selector(myTimerCallback:);
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:mySelector userInfo:nil repeats:YES];
                self.spendTime = 0;
            }
        }
}

-(void)myTimerCallback:(NSTimer*)timer
{
    if (self.flagOfDoPost == 1){
        self.spendTime ++;
    }
    if (self.spendTime > 45){
        
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Warning",nil) message:NSLocalizedString(@"Your network status is not ok.Do you want to continue loading now?",nil)
                                   delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
         errorAlert.tag = 12;
        [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
        [errorAlert show];
        
        self.spendTime = 0;
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.flagOfDoPost == 2){
        [SVProgressHUD dismiss];
        [self.timer invalidate];
        self.timer = nil;
        
        [[[self.navigationController viewControllers] objectAtIndex:0] viewDidLoad];
        [self.navigationController popToViewController: [[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"newpost_post.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(openMenu:)];
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];*/
    self.title = NSLocalizedString(@"New Post",nil);
    
    //timer
    SEL mySelector = @selector(myTimerCallback:);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:mySelector userInfo:nil repeats:YES];
    self.flagOfDoPost = 0;
    self.spendTime = 0;
    self.flagOfDescInput = 1;
    
    //---------my position-------
    
    MKPointAnnotation *annot2 = [[MKPointAnnotation alloc] init];
    annot2.title = NSLocalizedString(@"My location",nil);
    annot2.subtitle = NSLocalizedString(@"This is my location",nil);
    
    CLLocationCoordinate2D touchMapCoordinate2;
    touchMapCoordinate2 = CLLocationCoordinate2DMake(g_latitude, g_longitude);
    annot2.coordinate = touchMapCoordinate2;
    [self.mapView addAnnotation:annot2];
    
    
    float spanX = 0.5;
    float spanY = 0.5;
    MKCoordinateRegion region;
    region.center.latitude = g_latitude;//self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = g_longitude;//self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    @try {
        [self.mapView setRegion:region animated:YES];
    }
    @catch (NSException *exception) {
        
    }
    
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:g_latitude longitude:g_longitude]; //insert your coordinates
    
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  //String to hold address
                  NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@","];
                  self.myAddress.text = locatedAt;
              }
     ];
    
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [ivPickedImage setUserInteractionEnabled:YES];
    [ivPickedImage addGestureRecognizer:singleTap];
    
    
    NSUserDefaults *defaults1 = [NSUserDefaults standardUserDefaults];
    self.myName.text = [defaults1 valueForKey:@"name"];
    self.myLastName.text = [defaults1 valueForKey:@"lastname"];
    self.myCellphone.text = [defaults1 valueForKey:@"cellphone"];
    
}

-(UIImage *)resizeImage:(UIImage *)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 300.0;
    float maxWidth = 400.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
    
}

- (NSString *)encodeString:(NSStringEncoding)encoding
{
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self,
                                                                NULL, (CFStringRef)@";/?:@&=$+{}<>,",
                                                                CFStringConvertNSStringEncodingToEncoding(encoding)));
}

- (IBAction)AddNewPost:(id)sender {
    if (compareString(self.myDescription.text, @"")){
        showAlertMessage(NSLocalizedString(@"Description Field is empty, please fill the field and try again.",nil));
        return;
    }
    if (self.flagOfDoPost > 0) return;
    self.flagOfDoPost = 1;
    [SVProgressHUD show];
    
    NSString *boundary = @"SportuondoFormBoundary";
    NSMutableData *body = [NSMutableData data];
    
    //-----
    float actualHeight = ivPickedImage.image.size.height;
    float actualWidth = ivPickedImage.image.size.width;
    float maxHeight = 300.0;
    float maxWidth = 400.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [ivPickedImage.image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData2 = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();

    //-----
    
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageWithData:imageData2], 0.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", @"foto"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"api-key"       : @"55e76dc4bbae25b066cb",
                                                   @"Accept"        : @"application/json",
                                                   @"Content-Type"  : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
                                                   };
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    
    
    //date&time
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/M/yyyy"];
    
    NSString *l_date = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
    
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *l_hour = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
    
    //--imei
    NSString *vendorID;
    vendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *str = [self.myDescription.text stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://demos.hybridap.es/api/incidencias/Crear?expone=%@&latitud=%f&telefono=%@&longitud=%f&hora=%@&nombres=%@&fecha=%@&apellidos=%@&imei=%@",
                        self.myDescription.text,g_latitude,self.myCellphone.text,g_longitude,l_hour,self.myName.text,l_date,self.myLastName.text,vendorID];

    NSLog(urlStr);
    
    // Encode the parameters
    NSString *encodedStr = [urlStr encodeString:NSUTF8StringEncoding];
    
    NSLog(encodedStr);
        
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request
                                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                      if (error) {
                                                          showAlertMessage(NSLocalizedString(@"Post Failed.Check your network status.",nil));
                                                          return;
                                                      } else {
                                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                          self.flagOfDoPost = 2;
                                                      }
                                                  }];
    [uploadTask resume];
    
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.myName.text forKey:@"name"];
    [defaults setValue:self.myLastName.text forKey:@"lastname"];
    [defaults setValue:self.myCellphone.text forKey:@"cellphone"];
    [defaults synchronize];
}

-(void)tapDetected{
    self.toolbar.hidden = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//----key
- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
}

CGFloat offSet;
- (void)keyboardWasShown:(NSNotification *)notification {
    offSet= self.uiScrollView.contentOffset.y;
    
    
    
    if (offSet == 0.0) return;
    
    //if (self.flagOfDescInput == 1) return;
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint buttonOrigin = self.myCellphone.frame.origin;
    
    CGFloat buttonHeight = self.myCellphone.frame.size.height;
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height;
        
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
        
        [self.uiScrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    CGPoint pt;
    pt.y = offSet;
    [self.uiScrollView setContentOffset:pt animated:YES];
    self.flagOfDescInput = 0;
    
}

- (IBAction)didexitedit:(id)sender {
    self.flagOfDescInput = 0;
}

- (IBAction)onClickDescription:(id)sender {
    self.flagOfDescInput = 1;
}

- (IBAction)btnGalleryClicked:(id)sender
{
    ipc= [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        [self presentViewController:ipc animated:YES completion:nil];
    else
    {
        popover=[[UIPopoverController alloc]initWithContentViewController:ipc];
        [popover presentPopoverFromRect:btnGallery.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    self.toolbar.hidden = true;
}

- (IBAction)btnCameraClicked:(id)sender
{
    ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:ipc animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"No Camera Available.",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok",nil) otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
    }
    self.toolbar.hidden = true;
}

#pragma mark - ImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
        [popover dismissPopoverAnimated:YES];
    }
    ivPickedImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end