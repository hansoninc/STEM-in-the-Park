//
//  MyHTTPConnection.m
//  HostDisplay
//
//  Created by Josh Jacob on 8/4/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import "MyHTTPConnection.h"

#import "AppDelegate.h"

#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "HTTPLogging.h"

#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPFileResponse.h"

#import "DDNumber.h"

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;


/**
 * All we have to do is override appropriate methods in HTTPConnection.
 **/

@implementation MyHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    HTTPLogTrace();
    
    // Add support for POST
    
    if ([method isEqualToString:@"POST"])
    {
        if ([path isEqualToString:@"/upload.html"])
        {
            return YES;
        }
    }
    
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    HTTPLogTrace();
    
    // Inform HTTP server that we expect a body to accompany a POST request
    
    if([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload.html"]) {
        // here we need to make sure, boundary is set in header
        NSString* contentType = [request headerField:@"Content-Type"];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }
        
        // enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for( NSString* param in params ) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    HTTPLogTrace();
    
    if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload.html"])
    {
        
        // this method will generate response with links to uploaded file
        NSMutableString* filesStr = [[NSMutableString alloc] init];
        
        for( NSString* filePath in uploadedFiles ) {
            //generate links
            [filesStr appendFormat:@"<a href=\"%@\"> %@ </a><br/>",filePath, [filePath lastPathComponent]];
        }
        NSString* templatePath = [[config documentRoot] stringByAppendingPathComponent:@"upload.html"];
        NSDictionary* replacementDict = [NSDictionary dictionaryWithObject:filesStr forKey:@"MyFiles"];
        // use dynamic file response to apply our links to response template
        return [[HTTPDynamicFileResponse alloc] initWithFilePath:templatePath forConnection:self separator:@"%" replacementDictionary:replacementDict];
    }
    if( [method isEqualToString:@"GET"] && [path hasPrefix:@"/upload/"] ) {
        // let download the uploaded files
        return [[HTTPFileResponse alloc] initWithFilePath: [[config documentRoot] stringByAppendingString:path] forConnection:self];
    }
    
    return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
    HTTPLogTrace();
    
    // set up mime parser
    NSString* boundary = [request headerField:@"boundary"];
    parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    parser.delegate = self;
    
    uploadedFiles = [[NSMutableArray alloc] init];
}

- (void)processBodyData:(NSData *)postDataChunk
{
    HTTPLogTrace();
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    [parser appendData:postDataChunk];
}

#pragma mark multipart form data parser delegate

- (void) processStartOfPartWithHeader:(MultipartMessageHeader*) header {
    // in this sample, we are not interested in parts, other then file parts.
    // check content disposition to find out filename
    
    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    
    if ( (nil == filename) || [filename isEqualToString: @""] ) {
        // it's either not a file part, or
        // an empty form sent. we won't handle it.
        return;
    }
    
    //
    // get directory
    //
    
    AppDelegate *app = (AppDelegate *) [NSApp delegate];
    
    NSString* uploadDirPath = [app getDirectoryUploads];
    
    //
    // get temp file name
    //
    
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    storeFilepath = [uploadDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", uuidStr]];
    assert(storeFilepath != nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    //
    // create file
    //
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:storeFilepath] ) {
        storeFile = nil;
    }
    else {
        HTTPLogVerbose(@"Saving file to %@", storeFilepath);
        if(![[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:true attributes:nil error:nil]) {
            HTTPLogError(@"Could not create directory at path: %@", storeFilepath);
        }
        if(![[NSFileManager defaultManager] createFileAtPath:storeFilepath contents:nil attributes:nil]) {
            HTTPLogError(@"Could not create file at path: %@", storeFilepath);
        }
        storeFile = [NSFileHandle fileHandleForWritingAtPath:storeFilepath];
        [uploadedFiles addObject: [NSString stringWithFormat:@"/upload/%@", filename]];
    }
}

- (void) processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header
{
    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString* name = [[disposition.params objectForKey:@"name"] lastPathComponent];
    
    // get the parameter named name...
    if ([@"name" isEqualToString:name]) {
        NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@ = %@", name, value);
        uploaderName = value;
    }
    if ([@"app" isEqualToString:name]) {
        NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@ = %@", name, value);
        appName = value;
    }
    
    // here we just write the output from parser to the file.
    if( storeFile ) {
        [storeFile writeData:data];
    }
}

- (void) processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
    // as the file part is over, we close the file.
    if( storeFile ) {
        
        AppDelegate *app = (AppDelegate *) [NSApp delegate];
        [app addImage:storeFilepath withName:uploaderName appName:appName];
        
        [storeFile closeFile];
        storeFile = nil;
        storeFilepath = nil;
        uploaderName = nil;
        appName = nil;
    }
}

- (void) processPreambleData:(NSData*) data
{
    // if we are interested in preamble data, we could process it here.
    // NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // NSLog(@"%@", dataString);
}

- (void) processEpilogueData:(NSData*) data 
{
    // if we are interested in epilogue data, we could process it here.
    // NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // NSLog(@"%@", dataString);
}

@end