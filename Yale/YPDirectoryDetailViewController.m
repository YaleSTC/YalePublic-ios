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
#import "YPTheme.h"
#import <AddressBookUI/AddressBookUI.h>

@implementation YPDirectoryDetailViewController

+ (NSDictionary *)prettifyData:(NSDictionary *)data
{
  NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:data.count];
  NSArray *keys = [[data allKeys] sortedArrayUsingSelector:@selector(compare:)];
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
    if (![index isEqualToString:@"Residential College"] && ![index isEqualToString:@"Curriculum Code"]) [result setObject:[data objectForKey:raw] forKey:index];
  }
  return [result copy];
}

+ (NSDictionary *)parseAddress:(NSString *)address
{
  // address formatted like "Computer Science\nPO BOX 208285\nNew Haven, CT 06520-8285"
  NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
  NSMutableArray *lines = [[address componentsSeparatedByString:@"\n"] mutableCopy];
  [lines removeObject:@"()"];
  NSString *lastLine = lines.lastObject;
  [lines removeLastObject];
  [addressDictionary setObject:[lines componentsJoinedByString:@"\n"] forKey:(NSString *)kABPersonAddressStreetKey];
  if ([lastLine rangeOfString:@", "].length != 2) {
    return nil;
  }
  NSString *lastLineBeforeComma = [lastLine substringToIndex:[lastLine rangeOfString:@", "].location];
  NSString *lastLineAfterComma = [lastLine substringFromIndex:[lastLine rangeOfString:@", "].location+2];
  if ([lastLineAfterComma rangeOfString:@" "].length != 1) {
    return nil;
  }
  NSString *state = [lastLineAfterComma substringToIndex:[lastLineAfterComma rangeOfString:@" "].location];
  NSString *zip = [lastLineAfterComma substringFromIndex:[lastLineAfterComma rangeOfString:@" "].location+1];
  [addressDictionary setObject:lastLineBeforeComma forKey:(NSString *)kABPersonAddressCityKey];
  [addressDictionary setObject:state forKey:(NSString *)kABPersonAddressStateKey];
  [addressDictionary setObject:zip forKey:(NSString *)kABPersonAddressZIPKey];
  [addressDictionary setObject:@"United States" forKey:(NSString *)kABPersonAddressCountryKey];
  [addressDictionary setObject:@"us" forKey:(NSString *)kABPersonAddressCountryCodeKey];
  return [addressDictionary copy];
}

#define COLLEGE_ADDRESSES @{@"Silliman College":@"505 College Street", @"Timothy Dwight College":@"345 Temple Street", @"Morse College":@"304 York Street", @"Ezra Stiles College":@"302 York Street", @"Pierson College":@"261 Park Street", @"Davenport College":@"248 York Street", @"Calhoun College":@"189 Elm Street", @"Berkeley College":@"205 Elm Street", @"Trumbull College":@"241 Elm Street", @"Saybrook College":@"242 Elm Street", @"Jonathan Edwards College":@"68 High Street", @"Branford College":@"74 High Street"}

+ (ABRecordRef)personReferenceForData:(NSDictionary *)data
{
  ABRecordRef contact = ABPersonCreate();
  NSString *name = data[@"Name"];
  NSMutableArray *words = [[name componentsSeparatedByString:@" "] mutableCopy];
  NSString *firstName;
  NSString *middleName;
  NSString *lastName;
  NSString *nickname = data[@"Known As"];
  if (words.count == 1) {
    lastName = words[0];
  } else if (words.count == 2 || words.count > 3) {
    lastName = [words lastObject];
    [words removeLastObject];
    firstName = [words componentsJoinedByString:@" "];
  } else {
    firstName = words[0];
    middleName = words[1];
    lastName = words[2];
  }
  NSMutableArray *otherData = [[data.allKeys sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
  NSString *phoneNumber = data[@"Phone"];
  if (phoneNumber && phoneNumber.length < 11) phoneNumber = [@"203" stringByAppendingString:phoneNumber];
  NSString *email = data[@"Email"];
  if (firstName) ABRecordSetValue(contact, kABPersonFirstNameProperty, (__bridge CFStringRef)firstName, nil);
  if (middleName) ABRecordSetValue(contact, kABPersonMiddleNameProperty, (__bridge CFStringRef)middleName, nil);
  if (lastName) ABRecordSetValue(contact, kABPersonLastNameProperty, (__bridge CFStringRef)lastName, nil);
  if (nickname) ABRecordSetValue(contact, kABPersonNicknameProperty, (__bridge CFStringRef)nickname, nil);
  NSString *title = data[@"Title"];
  if (title) ABRecordSetValue(contact, kABPersonJobTitleProperty, (__bridge CFStringRef)title, nil);
  NSString *college = data[@"College"];
  NSString *collegeAddress;
  ABMutableMultiValueRef addressMultipleValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
  
  if (college && (collegeAddress = COLLEGE_ADDRESSES[college])) {
    [otherData removeObject:@"College"];
    
    NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
    [addressDictionary setObject:[NSString stringWithFormat:@"%@\n%@", college, collegeAddress] forKey:(NSString *)kABPersonAddressStreetKey];
    [addressDictionary setObject:@"New Haven" forKey:(NSString *)kABPersonAddressCityKey];
    [addressDictionary setObject:@"Connecticut" forKey:(NSString *)kABPersonAddressStateKey];
    [addressDictionary setObject:@"06511" forKey:(NSString *)kABPersonAddressZIPKey];
    [addressDictionary setObject:@"United States" forKey:(NSString *)kABPersonAddressCountryKey];
    [addressDictionary setObject:@"us" forKey:(NSString *)kABPersonAddressCountryCodeKey];
    ABMultiValueAddValueAndLabel(addressMultipleValue, (__bridge CFTypeRef)(addressDictionary), (__bridge CFTypeRef)@"college", NULL);
  }
  NSString *address = data[@"Address"];
  if (address) {
    [otherData removeObject:@"Address"];
    NSDictionary *addressDictionary = [self parseAddress:address];
    if (addressDictionary) ABMultiValueAddValueAndLabel(addressMultipleValue, (__bridge CFTypeRef)(addressDictionary), (__bridge CFTypeRef)@"work", NULL);
  }
  NSString *officeAddress = data[@"Office Address"];
  if (officeAddress) {
    [otherData removeObject:@"Office Address"];
    NSString *location = data[@"Location"];
    if (location) {
      [otherData removeObject:@"Location"];
      officeAddress = [[location stringByAppendingString:@"\n"] stringByAppendingString:officeAddress];
    }
    NSDictionary *addressDictionary = [self parseAddress:officeAddress];
    if (addressDictionary) ABMultiValueAddValueAndLabel(addressMultipleValue, (__bridge CFTypeRef)(addressDictionary), (__bridge CFTypeRef)@"office", NULL);
  }
  
  ABRecordSetValue(contact, kABPersonAddressProperty, addressMultipleValue, nil);
  
  NSString *division = data[@"Division"];
  if (division) {
    [otherData removeObject:@"Division"];
    ABRecordSetValue(contact, kABPersonDepartmentProperty, (__bridge CFStringRef)division, nil);
  }
  ABRecordSetValue(contact, kABPersonOrganizationProperty, (__bridge CFStringRef)@"Yale University", nil);
  
  ABMutableMultiValueRef phoneNumbers = ABMultiValueCreateMutable(kABMultiStringPropertyType);
  
  if (phoneNumber) ABMultiValueAddValueAndLabel(phoneNumbers, (__bridge CFStringRef)phoneNumber, kABPersonPhoneMainLabel, NULL);
  ABRecordSetValue(contact, kABPersonPhoneProperty, phoneNumbers, nil);
  
  ABMutableMultiValueRef emails = ABMultiValueCreateMutable(kABMultiStringPropertyType);
  if (email) ABMultiValueAddValueAndLabel(emails, (__bridge CFStringRef)email, (__bridge CFStringRef)@"school", NULL);
  ABRecordSetValue(contact, kABPersonEmailProperty, emails, nil);
  
  [otherData removeObject:@"Address"];
  [otherData removeObject:@"Phone"];
  [otherData removeObject:@"Email"];
  [otherData removeObject:@"Known As"];
  [otherData removeObject:@"Name"];
  [otherData removeObject:@"Title"];
  
  NSString *notes = [NSString string];
  for (NSString *key in otherData) {
    notes = [notes stringByAppendingFormat:@"%@: %@\n", key, data[key]];
  }
  ABRecordSetValue(contact, kABPersonNoteProperty, (__bridge CFStringRef)notes, nil);
  
  return contact;
}

+ (ABUnknownPersonViewController *)unknownPersonVCForData:(NSDictionary *)data
{
  ABUnknownPersonViewController *unknownPersonVC = [[ABUnknownPersonViewController alloc] init];
  unknownPersonVC.allowsAddingToAddressBook = YES;
  unknownPersonVC.allowsActions = YES;
  unknownPersonVC.displayedPerson = [self.class personReferenceForData:[self.class prettifyData:data]];
  return unknownPersonVC;
}

@end
