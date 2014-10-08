//
//  FKFlickrFavoritesRemove.m
//  FlickrKit
//
//  Generated by FKAPIBuilder on 19 Sep, 2014 at 10:49.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrFavoritesRemove.h" 

@implementation FKFlickrFavoritesRemove



- (BOOL) needsLogin {
    return YES;
}

- (BOOL) needsSigning {
    return YES;
}

- (FKPermission) requiredPerms {
    return 1;
}

- (NSString *) name {
    return @"flickr.favorites.remove";
}

- (BOOL) isValid:(NSError **)error {
    BOOL valid = YES;
	NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"You are missing required params: "];
	if(!self.photo_id) {
		valid = NO;
		[errorDescription appendString:@"'photo_id', "];
	}

	if(error != NULL) {
		if(!valid) {	
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
			*error = [NSError errorWithDomain:FKFlickrKitErrorDomain code:FKErrorInvalidArgs userInfo:userInfo];
		}
	}
    return valid;
}

- (NSDictionary *) args {
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if(self.photo_id) {
		[args setValue:self.photo_id forKey:@"photo_id"];
	}

    return [args copy];
}

- (NSString *) descriptionForError:(NSInteger)error {
    switch(error) {
		case FKFlickrFavoritesRemoveError_PhotoNotInFavorites:
			return @"Photo not in favorites";
		case FKFlickrFavoritesRemoveError_CannotRemovePhotoFromThatUsersFavorites:
			return @"Cannot remove photo from that user's favorites";
		case FKFlickrFavoritesRemoveError_UserNotFound:
			return @"User not found";
		case FKFlickrFavoritesRemoveError_SSLIsRequired:
			return @"SSL is required";
		case FKFlickrFavoritesRemoveError_InvalidSignature:
			return @"Invalid signature";
		case FKFlickrFavoritesRemoveError_MissingSignature:
			return @"Missing signature";
		case FKFlickrFavoritesRemoveError_LoginFailedOrInvalidAuthToken:
			return @"Login failed / Invalid auth token";
		case FKFlickrFavoritesRemoveError_UserNotLoggedInOrInsufficientPermissions:
			return @"User not logged in / Insufficient permissions";
		case FKFlickrFavoritesRemoveError_InvalidAPIKey:
			return @"Invalid API Key";
		case FKFlickrFavoritesRemoveError_ServiceCurrentlyUnavailable:
			return @"Service currently unavailable";
		case FKFlickrFavoritesRemoveError_WriteOperationFailed:
			return @"Write operation failed";
		case FKFlickrFavoritesRemoveError_FormatXXXNotFound:
			return @"Format \"xxx\" not found";
		case FKFlickrFavoritesRemoveError_MethodXXXNotFound:
			return @"Method \"xxx\" not found";
		case FKFlickrFavoritesRemoveError_InvalidSOAPEnvelope:
			return @"Invalid SOAP envelope";
		case FKFlickrFavoritesRemoveError_InvalidXMLRPCMethodCall:
			return @"Invalid XML-RPC Method Call";
		case FKFlickrFavoritesRemoveError_BadURLFound:
			return @"Bad URL found";
  
		default:
			return @"Unknown error code";
    }
}

@end
