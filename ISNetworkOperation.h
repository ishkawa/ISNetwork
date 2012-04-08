#import <UIKit/UIKit.h>

@interface ISNetworkOperation : NSOperation {
    BOOL _isExecuting;
    BOOL _isFinished;
}

@property (retain, nonatomic) NSURLRequest *request;
@property (retain, nonatomic) NSURLResponse *response;
@property (retain, nonatomic) NSMutableData *data;
@property (retain, nonatomic) NSURLConnection *connection;
@property (copy, nonatomic) void (^handler)(NSURLResponse *response, id object, NSError *error);

+ (NSOperationQueue *)sharedOperationQueue;
+ (id)operationWithRequest:(NSURLRequest *)request;
- (id)processData:(NSData *)data;
- (void)enqueueWithHandler:(void (^)(NSURLResponse *response, id object, NSError *error))handler;

@end
