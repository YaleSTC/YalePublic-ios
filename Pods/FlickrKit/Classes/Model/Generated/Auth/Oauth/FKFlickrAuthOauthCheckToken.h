//
//  FKFlickrAuthOauthCheckToken.h
//  FlickrKit
//
//  Generated by FKAPIBuilder on 19 Sep, 2014 at 10:49.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrAPIMethod.h"

typedef enum {
	FKFlickrAuthOauthCheckTokenError_InvalidSignature = 96,		 /* The passed signature was invalid. */
	FKFlickrAuthOauthCheckTokenError_MissingSignature = 97,		 /* The call required signing but no signature was sent. */
	FKFlickrAuthOauthCheckTokenError_InvalidAPIKey = 100,		 /* The API key passed was not valid or has expired. */
	FKFlickrAuthOauthCheckTokenError_ServiceCurrentlyUnavailable = 105,		 /* The requested service is temporarily unavailable. */
	FKFlickrAuthOauthCheckTokenError_WriteOperationFailed = 106,		 /* The requested operation failed due to a temporary issue. */
	FKFlickrAuthOauthCheckTokenError_FormatXXXNotFound = 111,		 /* The requested response format was not found. */
	FKFlickrAuthOauthCheckTokenError_MethodXXXNotFound = 112,		 /* The requested method was not found. */
	FKFlickrAuthOauthCheckTokenError_InvalidSOAPEnvelope = 114,		 /* The SOAP envelope send in the request could not be parsed. */
	FKFlickrAuthOauthCheckTokenError_InvalidXMLRPCMethodCall = 115,		 /* The XML-RPC request document could not be parsed. */
	FKFlickrAuthOauthCheckTokenError_BadURLFound = 116,		 /* One or more arguments contained a URL that has been used for abuse on Flickr. */

} FKFlickrAuthOauthCheckTokenError;

/*

Returns the credentials attached to an OAuth authentication token.


Response:

<oauth>
    <token>72157627611980735-09e87c3024f733da</token>
    <perms>write</perms>
    <user nsid="1121451801@N07" username="jamalf" fullname="Jamal F"/>
</oauth>

*/
@interface FKFlickrAuthOauthCheckToken : NSObject <FKFlickrAPIMethod>

/* The OAuth authentication token to check. */
@property (nonatomic, copy) NSString *oauth_token; /* (Required) */


@end
