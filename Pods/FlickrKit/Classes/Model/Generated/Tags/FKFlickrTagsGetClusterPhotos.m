//
//  FKFlickrTagsGetClusterPhotos.m
//  FlickrKit
//
//  Generated by FKAPIBuilder on 19 Sep, 2014 at 10:49.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrTagsGetClusterPhotos.h" 

@implementation FKFlickrTagsGetClusterPhotos



- (BOOL) needsLogin {
    return NO;
}

- (BOOL) needsSigning {
    return NO;
}

- (FKPermission) requiredPerms {
    return -1;
}

- (NSString *) name {
    return @"flickr.tags.getClusterPhotos";
}

- (BOOL) isValid:(NSError **)error {
    BOOL valid = YES;
	NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"You are missing required params: "];
	if(!self.tag) {
		valid = NO;
		[errorDescription appendString:@"'tag', "];
	}
	if(!self.cluster_id) {
		valid = NO;
		[errorDescription appendString:@"'cluster_id', "];
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
	if(self.tag) {
		[args setValue:self.tag forKey:@"tag"];
	}
	if(self.cluster_id) {
		[args setValue:self.cluster_id forKey:@"cluster_id"];
	}

    return [args copy];
}

- (NSString *) descriptionForError:(NSInteger)error {
    switch(error) {
		case FKFlickrTagsGetClusterPhotosError_InvalidAPIKey:
			return @"Invalid API Key";
		case FKFlickrTagsGetClusterPhotosError_ServiceCurrentlyUnavailable:
			return @"Service currently unavailable";
		case FKFlickrTagsGetClusterPhotosError_WriteOperationFailed:
			return @"Write operation failed";
		case FKFlickrTagsGetClusterPhotosError_FormatXXXNotFound:
			return @"Format \"xxx\" not found";
		case FKFlickrTagsGetClusterPhotosError_MethodXXXNotFound:
			return @"Method \"xxx\" not found";
		case FKFlickrTagsGetClusterPhotosError_InvalidSOAPEnvelope:
			return @"Invalid SOAP envelope";
		case FKFlickrTagsGetClusterPhotosError_InvalidXMLRPCMethodCall:
			return @"Invalid XML-RPC Method Call";
		case FKFlickrTagsGetClusterPhotosError_BadURLFound:
			return @"Bad URL found";
  
		default:
			return @"Unknown error code";
    }
}

@end
