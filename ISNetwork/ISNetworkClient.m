#import "ISNetworkClient.h"
#import "ISNetworkOperation.h"

@interface ISNetworkClient ()

@property (retain, nonatomic) NSOperationQueue *operationQueue;

@end


@implementation ISNetworkClient

#pragma mark - shortcuts

+ (void)cancelAllOperations
{
    [[self sharedClient].operationQueue cancelAllOperations];
}

+ (void)sendRequest:(NSURLRequest *)request
     operationClass:(Class)operationClass
            handler:(void (^)(NSHTTPURLResponse *, id, NSError *))handler
{
    if ([operationClass resolveClassMethod:@selector(operationWithRequest:handler:)]) {
        NSLog(@"invalid operation class.");
        return;
    }
    ISNetworkClient *client = [ISNetworkClient sharedClient];
    ISNetworkOperation *operation = [operationClass operationWithRequest:request handler:handler];
    if (!operation) {
        NSLog(@"could not construct operation.");
        return;
    }
    
    [client.operationQueue addOperation:operation];
}

+ (void)sendRequest:(NSURLRequest *)request handler:(void (^)(NSHTTPURLResponse *, id, NSError *))handler
{
    [self sendRequest:request
       operationClass:[ISNetworkOperation class]
              handler:handler];
}

#pragma mark - life cycle

+ (ISNetworkClient *)sharedClient
{
    static ISNetworkClient *client = nil;
    if (client == nil) {
        client = [[self alloc] init];
    }
    return client;
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

- (void)dealloc
{
    self.operationQueue = nil;
    
    [super dealloc];
}

#pragma mark - key value observation

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
