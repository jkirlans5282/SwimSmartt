//
//  List.m
//  SR
//
//  Created by Jacob Kirlan-Stout on 11/28/14.
//  Copyright (c) 2014 Jacob Kirlan-Stout. All rights reserved.
//
#import "List.h"
#import <MessageUI/MessageUI.h>
#import <Foundation/Foundation.h>
#import "DrEditUtilities.h"

@interface List()
-(IBAction)back:(id)sender;
-(IBAction)send:(id)sender;
@property NSString *messageBody;
@property NSString *tempContent;
@property UITextView *textView;
@property NSString *swimmersName;
@end
@implementation List
- (GTLServiceDrive *)driveService {
    static GTLServiceDrive *service = nil;
    
    if (!service) {
        service = [[GTLServiceDrive alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    }
    return service;
}

-(void)viewDidLoad{
    self.tableView.allowsMultipleSelection = YES;
    [self.navigationBar setTitle:[_data objectAtIndex:0]];
    [self.data removeObjectAtIndex:0];
    [[self driveService]setAuthorizer:_auth];
    //NSMutableAttributedString * backString = [[NSMutableAttributedString alloc] initWithString:@"back"];
    //NSMutableAttributedString * clearString = [[NSMutableAttributedString alloc] initWithString:@"clear"];

    //[_back setAttributedTitle:backString forState:UIControlStateNormal];
    //[_clear setAttributedTitle:clearString forState:UIControlStateNormal];

    //[self.navigationBar setLeftBarButtonItems:[NSArray arrayWithObjects:_back,_clear, nil]];

}
-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.swimmersName=[[alertView textFieldAtIndex:0] text];
}
- (IBAction)send:(id)sender
{
    //NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Name" message:@"Please enter the swimmers name\n Example: john d." delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    
    NSMutableArray *messageContent=[[NSMutableArray alloc]init];
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    for(NSIndexPath *path in selectedRows){
        [messageContent addObject:_data[path.row]];
    }
    NSString *emailTitle = @"Swim Smartt";
    NSString *messageTemp=[messageContent componentsJoinedByString:@"\n"];
    _messageBody = [messageContent componentsJoinedByString:@", "];
    mc = [[MFMailComposeViewController alloc]init];
    mc.mailComposeDelegate = self;
    
    [mc setMessageBody:[messageTemp stringByAppendingString:@"\n\n Additional comments:\n"] isHTML:NO];
    [mc setSubject:emailTitle];
    
    if([MFMailComposeViewController canSendMail]){
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Mail issue" message:@"You are unable to send mail at this time, please check your wifi connection" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];

    }

}
- (void)loadFileContent {
    UIAlertView *alert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading file content"
                                                             delegate:self];
    GTMHTTPFetcher *fetcher =
    [self.driveService.fetcherService fetcherWithURLString:self.driveFile.downloadUrl];
    
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        if (error == nil) {
            self.tempContent = [[NSString alloc] initWithData:data
                                                          encoding:NSUTF8StringEncoding];
            [self saveFile];

        } else {
            NSLog(@"An error occurred: %@", error);
            [DrEditUtilities showErrorMessageWithTitle:@"Unable to load file"
                                               message:[error description]
                                              delegate:self];
        }
    }];
}
- (void)saveFile {
    NSString *string;
    if(self.tempContent!=nil){
        NSLog(@"%@",self.swimmersName);
        NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
        
        [dateformate setDateFormat:@"dd/MM/YYYY"];
        NSString *date_String=[dateformate stringFromDate:[NSDate date]];
        
        string= [NSString stringWithFormat:@"%@,%@,%@,%@\n%@",self.swimmersName,self.navigationBar.title,date_String, self.messageBody, self.tempContent];
        NSLog(@"%@",string);
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:@"text/plain"];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesUpdateWithObject:self.driveFile
                            fileId:self.driveFile.identifier
                            uploadParameters:uploadParameters];
    GTLServiceDrive *driveService = [self driveService];
    [driveService setAuthorizer:_auth];
    [driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                  GTLDriveFile *updatedFile,
                                                  NSError *error) {
        if (error == nil) {
            //NSLog(@"File %@", updatedFile);
            self.driveFile=updatedFile;
        } else {
            NSLog(@"An error occurred: %@", error);
        }
    }];
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError * )error
{
    switch(result){
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail Saved");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Sent");
            [self loadFileContent];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            [self dismissViewControllerAnimated:YES completion:NULL];
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_data count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [_data objectAtIndex:indexPath.row];
    return cell;
}
///
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
///

@end