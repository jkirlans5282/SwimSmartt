//
//  ViewController.h
//  SR
//
//  Created by Jacob Kirlan-Stout on 11/28/14.
//  Copyright (c) 2014 Jacob Kirlan-Stout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>

#import "DrEditFileEditDelegate.h"

@interface ViewController : UIViewController <DrEditFileEditDelegate>
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSMutableArray *tempData;
@end


