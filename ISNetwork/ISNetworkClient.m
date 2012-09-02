#import "ISNetworkClient.h"
#import "ISNetworkOperation.h"

@interface ISNetworkClient ()

@property (retain, nonatomic) NSOperationQueue *operationQueue;

@end


@implementation ISNetworkClient

+ (ISNetworkClient *)sharedClient
{
    static ISNetworkClient *client = nil;
    if (client == nil) {
        client = [[ISNetworkClient alloc] init];
    }
    return client;
}

+ (void)sendRequest:(NSURLRequest *)request handler:(void (^)(NSHTTPURLResponse *, id, NSError *))handler
{
    ISNetworkClient *client = [ISNetworkClient sharedClient];
    ISNetworkOperation *operation = [ISNetworkOperation operationWithRequest:request handler:handler];
    if (!operation) {
        NSLog(@"could not construct operation.");
        return;
    }
    
    [client.operationQueue addOperation:operation];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.managesActivityIndicator = YES;
        self.operationQueue = [[[NSOperationQueue alloc] init] autorelease];
        
        [self.operationQueue addObserver:self
                              forKeyPath:@"operationCount"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.operationQueue && [keyPath isEqualToString:@"operationCount"]) {
        [self updateIndicatorVisible];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updateIndicatorVisible
{
    if (!self.managesActivityIndicator) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.operationQueue.operationCount) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        } else {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    });
}

@end
