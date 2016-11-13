//
//  main.m
//  incidencias
//
//  Created by PLEASE on 23/01/16.
//  Copyright © 2016 zaltan nyhether. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

double g_latitude;
double g_longitude;

int g_curindex;

NSString *ga_expone[40];
NSString *ga_telefono[40];
NSString *ga_fecha[40];
NSString *ga_hora[40];
NSString *ga_nombres[40];
NSString *ga_apellidos[40];
double ga_latitud[40];
double ga_longitud[40];
NSString *ga_foto[200];

int lang; // 0:english, 1:spanish


void showAlertMessage(NSString *str){
    if (str==nil) return;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:str
                                                   delegate:nil  cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

bool compareString(NSArray *str1, NSArray *str2)
{
    //if (str1 == nil || str2 == nil) return false;
    if ([(NSString*)str1 compare:(NSString*)str2]==NSOrderedSame)
        return true;
    return false;
}

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
