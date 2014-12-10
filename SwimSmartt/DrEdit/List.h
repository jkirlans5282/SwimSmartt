
//
//  List.h
//  SR
//
//  Created by Jacob Kirlan-Stout on 11/28/14.
//  Copyright (c) 2014 Jacob Kirlan-Stout. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "DrEditFileEditDelegate.h"
#import "GTLDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "DrEditUtilities.h"
@interface List : UIViewController <UITextViewDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
    MFMailComposeViewController *mc;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSMutableArray *data;
@property(strong, nonatomic)NSMutableArray *selected;
@property GTMOAuth2Authentication *auth;
@property GTLDriveFile *driveFile;
@property id<DrEditFileEditDelegate> delegate;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;

@end