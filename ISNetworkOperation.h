#import <UIKit/UIKit.h>

@interface ISNetworkOperation : NSOperation <NSURLConnectionDataDelegate>

@property (retain, nonatomic) NSURLRequest *request;
@property (retain, nonatomic) NSURLResponse *response;
@property (retain, nonatomic) NSMutableData *data;
@property (retain, nonatomic) NSURLConnection *connection;
@property (copy, nonatomic) void (^handler)(NSURLResponse *response, id object, NSError *error);

+ (NSOperationQueue *)sharedOperationQueue;
+ (id)operationWithRequest:(NSURLRequest *)request;
+ (void)sendRequest:(NSURLRequest *)request handler:(void (^)(NSURLResponse *response, id object, NSError *error))handler;
- (id)processData:(NSData *)data;
- (void)enqueueWithHandler:(void (^)(NSURLResponse *response, id object, NSError *error))handler;

@end
