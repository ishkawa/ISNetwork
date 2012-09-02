#import <UIKit/UIKit.h>

@interface ISNetworkOperation : NSOperation <NSURLConnectionDataDelegate>

@property dispatch_queue_priority_t priority;
@property (retain, nonatomic) NSURLRequest *request;
@property (retain, nonatomic) NSHTTPURLResponse *response;
@property (retain, nonatomic) NSMutableData *data;
@property (retain, nonatomic) NSURLConnection *connection;
@property (copy, nonatomic) void (^handler)(NSHTTPURLResponse *response, id object, NSError *error);

+ (id)operationWithRequest:(NSURLRequest *)request;
+ (id)operationWithRequest:(NSURLRequest *)request
                   handler:(void (^)(NSHTTPURLResponse *response, id object, NSError *error))handler;

- (id)processData:(NSData *)data;


#pragma mark - depricated in September 1st (2012)

+ (NSOperationQueue *)sharedOperationQueue DEPRECATED_ATTRIBUTE;
- (void)enqueueWithHandler:(void (^)(NSHTTPURLResponse *response, id object, NSError *error))handler DEPRECATED_ATTRIBUTE;
+ (void)sendRequest:(NSURLRequest *)request
            handler:(void (^)(NSHTTPURLResponse *response, id object, NSError *error))handler DEPRECATED_ATTRIBUTE;

@end
