// PlistToXMLConverter.m

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

const char *convertPlistAtPathToXMLCString(const char *filePath, char *error_buffer);

#ifdef __cplusplus
}
#endif

@interface PlistToXMLConverter : NSObject

+ (NSString *)convertPlistToXMLString:(id)plistObject error:(NSError **)error;
+ (NSString *)convertPlistAtPathToXMLString:(NSString *)filePath error:(NSError **)error;

@end

@implementation PlistToXMLConverter

+ (NSString *)convertPlistToXMLString:(id)plistObject error:(NSError **)error {

  NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:plistObject format:NSPropertyListXMLFormat_v1_0 options:0 error:error];

  if (xmlData) {
    return [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
  } else {
    return nil;
  }
}

+ (NSString *)convertPlistAtPathToXMLString:(NSString *)filePath error:(NSError **)error {

  NSData *plistData = [NSData dataWithContentsOfFile:filePath];

  if (!plistData) {
    if (error) {
      *error = [NSError errorWithDomain:@"PlistToXMLConverterError" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Could not read plist data from file." }];
    }
    return nil;
  }

  id plistObject = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:NULL error:error];

  if (plistObject) {
    return [self convertPlistToXMLString:plistObject error:error];

  } else {
    return nil;
  }
}

@end

const char *convertPlistAtPathToXMLCString(const char *filePath, char *error_buffer) {
  @autoreleasepool {
    NSError *error = nil;
    NSString *nsFilePath = [NSString stringWithUTF8String:filePath];
    NSString *xmlString = [PlistToXMLConverter convertPlistAtPathToXMLString:nsFilePath error:&error];

    if (error && error_buffer) {
      strncpy(error_buffer, [[error localizedDescription] UTF8String], 1024);
      return NULL;
    }

    if (xmlString) {
      return strdup([xmlString UTF8String]);
    } else {
      return NULL;
    }
  }
}
