//
//  YPDirectoryDetailViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 12/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPDirectoryDetailViewController.h"
#import "CoreMacro.h"
#import "YPGlobalHelper.h"


@interface YPDirectoryDetailViewController ()

@end

@implementation YPDirectoryDetailViewController

- (void)viewDidLoad
{
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  
  [YPGlobalHelper showNotificationInViewController:self message:@"loading" style:JGProgressHUDStyleDark];
  if (self.data) {
    [self loadData];
    NSLog(@"have data");
  }
}

- (void)loadData {
  [self prettifyData];
  [self updateTableHeader];
  [self.tableView reloadData];
  [YPGlobalHelper hideNotificationView];
}

- (void)updateTableHeader
{
  self.title = [self.data valueForKey:@"Name"];
  self.nameLabel.text = [self.data valueForKey:@"Name"];
  
  
  NSString *subheaderString = @"";
  for (NSString *item in [self.data allKeys]) {
    if ([item isEqualToString:@"Title"]) {
      subheaderString = [self.data valueForKey:item];
      [self.data removeObjectForKey:item];
    } else if ([item isEqualToString:@"Division"] && [subheaderString isEqualToString:@""]) {
      subheaderString = [self.data valueForKey:item];
      [self.data removeObjectForKey:item];
    } else if ([item isEqualToString:@"Curriculum Code"] || [item isEqualToString:@"Office Address"] || [item isEqualToString:@"Residential College"] || [item isEqualToString:@"Name"]) [self.data removeObjectForKey:item];
  }
  
}

- (void)prettifyData
{
  NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:self.data.count];
  NSArray *keys = [[self.data allKeys] sortedArrayUsingSelector:@selector(compare:)];
  for (NSString *raw in keys) {
    NSString *index = [raw stringByReplacingOccurrencesOfString:@":" withString:@""];
    index = [index stringByReplacingOccurrencesOfString:@"Student Phone" withString:@"Phone"];
    index = [index stringByReplacingOccurrencesOfString:@"Residential College Name" withString:@"College"];
    index = [index stringByReplacingOccurrencesOfString:@"Email Address" withString:@"Email"];
    index = [index stringByReplacingOccurrencesOfString:@"Office Phone" withString:@"Phone"];
    index = [index stringByReplacingOccurrencesOfString:@"Organization" withString:@"Org"];
    index = [index stringByReplacingOccurrencesOfString:@"Home Org ID" withString:@"Org ID"];
    index = [index stringByReplacingOccurrencesOfString:@"US Mailing Address" withString:@"Address"];
    index = [index stringByReplacingOccurrencesOfString:@"Campus Location" withString:@"Location"];
    [result setObject:[self.data objectForKey:raw] forKey:index];
  }
  self.data = result;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                                        reuseIdentifier:@"Info Cell"];
  NSString *title = [[[self.data allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row];
  cell.textLabel.text = title;
  cell.detailTextLabel.text = [self.data objectForKey:title];
  
  
  cell.userInteractionEnabled = ([title isEqualToString:@"Email"] || [title isEqualToString:@"Phone"]) ? YES : NO;
  
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  UITableViewCell*cell = [self.tableView cellForRowAtIndexPath:indexPath];
  if ([cell.textLabel.text isEqualToString:@"Email"]) {
    if ([MFMailComposeViewController canSendMail]) {
      MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
      mailer.mailComposeDelegate = self;
      NSArray *toRecipients = [NSArray arrayWithObjects:cell.detailTextLabel.text, nil];
      [[mailer navigationBar] setTintColor:[UIColor whiteColor]];
      [mailer setToRecipients:toRecipients];
      [self presentViewController:mailer animated:YES completion:nil];
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Yale is unable to launch the email service. Your device doesn't support the composer sheet."
                                                     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
    }
  }
  if ([cell.textLabel.text isEqualToString:@"Phone"]) {
    NSString *phoneNo = cell.detailTextLabel.text;
    if (phoneNo.length < 11) phoneNo = [@"203-" stringByAppendingString:phoneNo];
    self.phoneURL = [@"tel://" stringByAppendingString:phoneNo];
    [self createActionSheetWithNumber:phoneNo];
  }
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
  switch (result) {
    case MFMailComposeResultCancelled:
      DLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
      break;
    case MFMailComposeResultSaved:
      DLog(@"Mail saved: you saved the email message in the drafts folder.");
      break;
    case MFMailComposeResultSent:
      DLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
      break;
    case MFMailComposeResultFailed:
      DLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
      break;
    default:
      DLog(@"Mail not sent.");
      break;
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createActionSheetWithNumber:(NSString *)number
{
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Do you want to call %@? For undergraduate this is the number of dorm landline, which is usually not set up.", number] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"Call %@", number], @"Copy to Clipboard", nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
  [actionSheet showInView:self.view];
}

- (void)createActionSheetWithString:(NSString *)string
{
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy to Clipboard", nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
  [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex != [actionSheet cancelButtonIndex]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.phoneURL]];
}

@end
