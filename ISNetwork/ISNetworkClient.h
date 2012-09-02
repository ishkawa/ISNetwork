#import <Foundation/Foundation.h>

@interface ISNetworkClient : NSObject

@property BOOL managesActivityIndicator;
@property (readonly, retain, nonatomic) NSOperationQueue *operationQueue;

+ (ISNetworkClient *)sharedClient;
+ (void)sendRequest:(NSURLRequest *)request handler:(void (^)(NSHTTPURLResponse *response, id object, NSError *error))handler;

@end
