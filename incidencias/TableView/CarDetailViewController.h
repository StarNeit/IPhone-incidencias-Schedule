//
//  CarDetailViewController.h
//  AddItemTableViewDemo
//
//  Created by Arthur Knopper on 16-06-13.
//  Copyright (c) 2013 Arthur Knopper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarDetailViewController : UIViewController

@property (nonatomic, strong) NSString *carName;
@property (nonatomic, strong) IBOutlet UITextField *name;

@property (nonatomic, strong) NSString *expone;
@property (nonatomic, strong) NSString *telefono;
@property (nonatomic, strong) NSString *fecha;
@property (nonatomic, strong) NSString *hora;
@property (nonatomic, strong) NSString *nombres;
@property (nonatomic, strong) NSString *apellidos;
@property double latitud;
@property double longitud;
@property (nonatomic, strong) NSString *foto;

@end
