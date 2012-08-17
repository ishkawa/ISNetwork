#import <UIKit/UIKit.h>

@interface ISNetworkOperation : NSOperation <NSURLConnectionDataDelegate>

@property dispatch_queue_priority_t priority;
@property (retain, nonatomic) NSURLRequest *request;
@property (retain, nonatomic) NSHTTPURLResponse *response;
@property (retain, nonatomic) NSMutableData *data;
@property (retain, nonatomic) NSURLConnection *connection;
@property (copy, nonatomic) void (^handler)(NSHTTPURLResponse *response, id object, NSError *error);

+ (NSOperationQueue *)sharedOperationQueue;
+ (NSOperationQueue *)sharedPostOperationQueue;
+ (id)operationWithRequest:(NSURLRequest *)request;
- (id)processData:(NSData *)data;
- (void)enqueueWithHandler:(void (^)(NSHTTPURLResponse *response, id object, NSError *error))handler;
+ (void)sendRequest:(NSURLRequest *)request
            handler:(void (^)(NSHTTPURLResponse *response, id object, NSError *error))handler;

@end
