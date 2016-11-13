//
//  CarListViewController.m
//  AddItemTableViewDemo
//
//  Created by Arthur Knopper on 15-06-13.
//  Copyright (c) 2013 Arthur Knopper. All rights reserved.
//

#import "EventListViewController.h"
#import "Event.h"
#import "DOPNavbarMenu.h"
#import "SVProgressHUD.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface EventListViewController ()<UITextViewDelegate, DOPNavbarMenuDelegate>

@property (nonatomic, strong) NSMutableArray *cars;
@property (strong, nonatomic) DOPNavbarMenu *menu;
@property (assign, nonatomic) NSInteger numberOfItemsInRow;

- (IBAction)cancel:(UIStoryboardSegue *)segue;
- (IBAction)done:(UIStoryboardSegue *)segue;

@end

@implementation EventListViewController{
    CLLocationManager *locationManager;
}

- (DOPNavbarMenu *)menu {
    if (_menu == nil) {
        DOPNavbarMenuItem *item1 = [DOPNavbarMenuItem ItemWithTitle:NSLocalizedString(@"Posts",nil) icon:[UIImage imageNamed:@"icon_posts.png"]];
        DOPNavbarMenuItem *item2 = [DOPNavbarMenuItem ItemWithTitle:NSLocalizedString(@"New Post",nil) icon:[UIImage imageNamed:@"icon_newposts.png"]];
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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)myTimerCallback:(NSTimer*)timer
{
    self.spendTime ++;
    if (self.spendTime > 45){
        [SVProgressHUD dismiss];
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Warning" message:@"Your network status is not ok.Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        self.spendTime = 0;
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.postCnt == -1){
        self.postCnt = 0;
        [SVProgressHUD dismiss];
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.postCnt > 0){
        [self.timer invalidate];
        self.timer = nil;
        self.cars = [[NSMutableArray alloc] init];
        
        
        for (int i = 0; i < self.postCnt ; i ++)
        {
            Event *temp;
            temp = [[Event alloc] initWithName:ga_expone[i]];
            [self.cars addObject:temp];
            
        }
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SVProgressHUD show];
  
    self.postCnt = 0;
    self.spendTime = 0;
    //timer
    SEL mySelector = @selector(myTimerCallback:);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:mySelector userInfo:nil repeats:YES];

    //menu
    self.numberOfItemsInRow = 3;
    //self.title = @"Posts";
    self.title = NSLocalizedString(@"Posts", nil);
    
    
    //GPS location
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
                
            }
        }
    }
    [self->locationManager startUpdatingLocation];
    
    //dbconnect
    NSDictionary *headers = @{ @"cache-control": @"no-cache",
                               @"postman-token": @"0b067f69-7826-2761-92bc-7f9debd47033" };
    
        //--imei
    NSString *vendorID;
    vendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
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
                                                        self.postCnt = -1;
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSError *serializeError = nil;
                                                        NSDictionary *jsonData = [NSJSONSerialization
                                                                                  JSONObjectWithData:data
                                                                                  options:NSJSONReadingMutableContainers
                                                                                  error:&serializeError];
                                                        
                                                        self.cars = [[NSMutableArray alloc] init];
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
                                                                
                                                                 ga_latitud[index] = [[[theObjects valueForKey:@"latitud"] stringByReplacingOccurrencesOfString:@"," withString:@"."] doubleValue];
                                                                 ga_longitud[index] = [[[theObjects valueForKey:@"longitud"] stringByReplacingOccurrencesOfString:@"," withString:@"."] doubleValue];
                                                                ga_foto[index] = [theObjects valueForKey:@"foto"];
                                                               
                                                                index++;
                                                            }
                                                        }
                                                        
                                                        self.postCnt = jsonData.count;
                                                        if (self.postCnt == 0){
                                                            self.postCnt = -1;
                                                        }
                                                        
                                                        if(error == nil)
                                                        {
                                                            NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                        }
                                                    }
                                                }];
    [dataTask resume];
    
}

- (IBAction)cancel:(UIStoryboardSegue *)segue
{
}

- (IBAction)done:(UIStoryboardSegue *)segue
{
    /*CarDetailViewController *carDetailVC = segue.sourceViewController;
    Event *car = [[Event alloc] initWithName:carDetailVC.carName];
    [self.cars addObject:car];
    [self.tableView reloadData];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.menu) {
        [self.menu dismissWithAnimation:NO];
    }
}
- (IBAction)doOpenMenu:(id)sender {
    [SVProgressHUD dismiss];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (self.menu.isOpen) {
        [self.menu dismissWithAnimation:YES];
    } else {
        [self.menu showInNavigationController:self.navigationController];
    }
}

- (void)didShowMenu:(DOPNavbarMenu *)menu {
    //[self.navigationItem.rightBarButtonItem setTitle:@"dismiss"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu {
    [self.navigationItem.rightBarButtonItem setTitle:@"menu"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    [[self navigationController] popViewControllerAnimated: YES];
    switch (index) {
            
        case 0:
        {
            [self viewDidLoad];
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
            [self viewDidLoad];
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.menu = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.menu = nil;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.cars count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CarCell";
    
    Event *currentCar = [self.cars objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = currentCar.brandName;
    
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
    CLLocation *currentLocation = newLocation;
    CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];
    g_latitude = currentLocation.coordinate.latitude;
    g_longitude = currentLocation.coordinate.longitude;
}

@end
