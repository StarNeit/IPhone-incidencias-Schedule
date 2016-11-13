//
//  ViewController.m
//  DOPNavbarMenuDemo
//
//  Created by weizhou on 5/14/15.
//  Copyright (c) 2015 weizhou. All rights reserved.
//

#import "ViewController.h"
#import "DOPNavbarMenu.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface ViewController () <UITextViewDelegate, DOPNavbarMenuDelegate>

@property (assign, nonatomic) NSInteger numberOfItemsInRow;
@property (strong, nonatomic) DOPNavbarMenu *menu;

@end
int postCnt = 1;
@implementation ViewController{
    CLLocationManager *locationManager;
}

- (DOPNavbarMenu *)menu {
    if (_menu == nil) {
        DOPNavbarMenuItem *item1 = [DOPNavbarMenuItem ItemWithTitle:NSLocalizedString(@"Posts",nil) icon:[UIImage imageNamed:@"icon_posts.png"]];
        DOPNavbarMenuItem *item2 = [DOPNavbarMenuItem ItemWithTitle:NSLocalizedString(@"New Posts",nil) icon:[UIImage imageNamed:@"icon_newposts.png"]];
        DOPNavbarMenuItem *item3 = [DOPNavbarMenuItem ItemWithTitle:NSLocalizedString(@"Settings",nil) icon:[UIImage imageNamed:@"icon_setting.png"]];
        DOPNavbarMenuItem *item4 = [DOPNavbarMenuItem ItemWithTitle:NSLocalizedString(@"Reload",nil) icon:[UIImage imageNamed:@"icon_reload.png"]];
        DOPNavbarMenuItem *item5 = [DOPNavbarMenuItem ItemWithTitle:NSLocalizedString(@"About",nil) icon:[UIImage imageNamed:@"icon_about.png"]];
        DOPNavbarMenuItem *item6 = [DOPNavbarMenuItem ItemWithTitle:NSLocalizedString(@"Power",nil) icon:[UIImage imageNamed:@"icon_power.png"]];
        _menu = [[DOPNavbarMenu alloc] initWithItems:@[item1,item2,item3,item4,item5,item6] width:self.view.dop_width maximumNumberInRow:_numberOfItemsInRow];
        _menu.backgroundColor = UIColorFromRGB(0x067AB5);
        _menu.separatarColor = [UIColor whiteColor];
        _menu.delegate = self;
    }
    return _menu;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.numberOfItemsInRow = 3;
    g_curindex = -1;
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(openMenu:)];
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"Posts",nil);
    
    
    //----------GPS location----------
    g_latitude = 0;
    g_longitude = 0;
    self->locationManager = [[CLLocationManager alloc] init];
    
    self->locationManager.delegate = self;
    if(IS_OS_8_OR_LATER){
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([self->locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self->locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            // choose one request according to your business.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                [self->locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [self->locationManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    }
    [self->locationManager startUpdatingLocation];
    
    
    NSDictionary *headers = @{ @"cache-control": @"no-cache",
                               @"postman-token": @"0b067f69-7826-2761-92bc-7f9debd47033" };
    
    //--imei
    NSString *vendorID;
    vendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(vendorID);
    
    NSString *buf = [NSString stringWithFormat:@"http://demos.hybridap.es/api/incidencias?imei=%@",vendorID];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:buf]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSError *serializeError = nil;
                                                        NSDictionary *jsonData = [NSJSONSerialization
                                                                                  JSONObjectWithData:data
                                                                                  options:NSJSONReadingMutableContainers
                                                                                  error:&serializeError];
                                                        postCnt = jsonData.count;
                                                        
                                                        int index = 0;
                                                        for (id key in jsonData)
                                                        {
                                                            for (id key2 in key){
                                                                id theObjects = [key objectForKey:key2];
                                                                NSString *buf = [[theObjects valueForKey:@"expone"] stringByReplacingOccurrencesOfString:@"_"
                                                                                                                                   withString:@" "];
                                                                ga_expone[index] = buf;
                                                                ga_telefono[index] = [theObjects valueForKey:@"telefono"];
                                                                ga_fecha[index] = [theObjects valueForKey:@"fecha"];
                                                                ga_hora[index] = [theObjects valueForKey:@"hora"];
                                                                ga_nombres[index] = [theObjects valueForKey:@"nombres"];
                                                                ga_apellidos[index] = [theObjects valueForKey:@"apellidos"];
                                                                ga_latitud[index] = [[theObjects objectForKey:@"latitud"] doubleValue];
                                                                ga_longitud[index] = [[theObjects objectForKey:@"longitud"] doubleValue];
                                                                ga_foto[index] = [theObjects valueForKey:@"foto"];
                                                                index++;
                                                            }
                                                        }
                                                        
                                                        
                                                        
                                                        [self.tableView reloadData];
                                                        
                                                        NSLog(@"Response:%@ %@\n", response, error);
                                                        if(error == nil)
                                                        {
                                                            NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                            NSLog(@"Data = %@",text);
                                                        }
                                                        NSLog(@"%@", httpResponse);
                                                    }
                                                }];
    [dataTask resume];
}




//------------------------------------------------------------------------------------------//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return postCnt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = ga_expone[indexPath.row];
    cell.detailTextLabel.text = @"Subtitle 1";
    
    
    //[cell setBackgroundColor:[UIColor colorWithRed:.39 green:.87 blue:.255 alpha:1]];
    
    UIImage *cellImage = [UIImage imageNamed:@"posts_icon.png"];
    cell.imageView.image = cellImage;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    g_curindex = indexPath.row;
    //redirecting...
    UIStoryboard *mainStorynboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *documetController;
    documetController = [mainStorynboard instantiateViewControllerWithIdentifier:@"postdetailcontroller"];
    [self.navigationController pushViewController:documetController animated:YES];
    
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];
    g_latitude = currentLocation.coordinate.latitude;
    g_longitude = currentLocation.coordinate.longitude;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.menu) {
        [self.menu dismissWithAnimation:NO];
    }
}

- (void)openMenu:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (self.menu.isOpen) {
        [self.menu dismissWithAnimation:YES];
    } else {
        [self.menu showInNavigationController:self.navigationController];
    }
}

- (void)didShowMenu:(DOPNavbarMenu *)menu {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            UIStoryboard *mainStorynboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *documetController;
            documetController = [mainStorynboard instantiateViewControllerWithIdentifier:@"postsView"];
            [self.navigationController pushViewController:documetController animated:YES];
        }
            break;
        case 1:
        {
            UIStoryboard *mainStorynboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *documetController;
            documetController = [mainStorynboard instantiateViewControllerWithIdentifier:@"newpostview"];
            [self.navigationController pushViewController:documetController animated:YES];
        }
            break;
        case 2:
        {
            UIStoryboard *mainStorynboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *documetController;
            documetController = [mainStorynboard instantiateViewControllerWithIdentifier:@"settingsview"];
            [self.navigationController pushViewController:documetController animated:YES];
        }
            break;
        case 3:
        {
            
        }
            break;
        case 4:
        {
            UIStoryboard *mainStorynboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *documetController;
            documetController = [mainStorynboard instantiateViewControllerWithIdentifier:@"aboutview"];
            [self.navigationController pushViewController:documetController animated:YES];
        }
            break;
        case 5:
        {
            exit(0);
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.numberOfItemsInRow = [textView.text integerValue];
    self.menu = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.menu = nil;
}

@end