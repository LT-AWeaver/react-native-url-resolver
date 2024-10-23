#import "RNUrlResolver.h"

@implementation RNUrlResolver

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(resolveUrl:(NSURL *)encodedURL
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)
{
    if (encodedURL == nil) {
        reject(0, @"Unable to handle user activity: No URL provided", nil);
    } else {
        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *task = [session dataTaskWithURL:encodedURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (response == nil || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
                reject(0, @"Unable to handle URL", nil);
            } else {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                NSString *urlAsString = [httpResponse valueForHTTPHeaderField:@"Location"];
                if ([urlAsString length] == 0) {
                  resolve([httpResponse URL].absoluteString);
                } else {
                  resolve(urlAsString);
                }
            }
        }];
        [task resume];
        
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    // Stops the redirection, and returns (internally) the response body.
    completionHandler(nil);
}

@end
