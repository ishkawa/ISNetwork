#import "ISNetworkOperation.h"

@interface ISNetworkOperation ()

@property BOOL isExecuting;
@property BOOL isFinished;

@end

@implementation ISNetworkOperation 

@synthesize priority = _priority;
@synthesize request = _request;
@synthesize response = _response;
@synthesize data = _data;
@synthesize connection = _connection;
@synthesize handler = _handler;

@synthesize isExecuting = _isExecuting;
@synthesize isFinished = _isFinished;

#pragma mark - KVO

- (BOOL)isConcurrent
{
    return YES;
}

+ (BOOL) automaticallyNotifiesObserversForKey: (NSString*) key
{
    return YES;
}

#pragma mark - life cycle

+ (NSOperationQueue *)sharedOperationQueue
{
    static NSOperationQueue *queue;
    if (queue == nil) {
        queue = [[NSOperationQueue alloc] init];
    }
    return queue;
}

+ (NSOperationQueue *)sharedPostOperationQueue
{
    static NSOperationQueue *queue;
    if (queue == nil) {
        queue = [[NSOperationQueue alloc] init];
    }
    return queue;
}

+ (id)operationWithRequest:(NSURLRequest *)request
{
    ISNetworkOperation *operation = [[[[self class] alloc] init] autorelease];
    operation.request = request;
    
    return operation;
}

+ (void)sendRequest:(NSURLRequest *)request handler:(void (^)(NSHTTPURLResponse *, id, NSError *))handler
{
    [[self operationWithRequest:request] enqueueWithHandler:handler];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.priority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
        self.data = [NSMutableData data];
    }
    return self;
}

- (void)dealloc
{
    self.handler = nil;
    [_request release], _request = nil;
    [_response release], _response = nil;
    [_data release], _data = nil;
    [_connection release], _connection = nil;
    [super dealloc];
}

#pragma mark - action

- (void)enqueueWithHandler:(void (^)(NSHTTPURLResponse *, id, NSError *))handler
{
    self.handler = handler;
    if ([self.request.HTTPMethod isEqualToString:@"POST"]) {
        [[[self class] sharedPostOperationQueue] addOperation:self];
    } else {
        [[[self class] sharedOperationQueue] addOperation:self];
    }
}

- (void) start
{
    if ([self isCancelled]) {
        self.isExecuting = NO;
        self.isFinished = YES;
        return;
    }

    self.isExecuting = YES;
    self.isFinished = NO;
    
    [self manageStatusBarIndicatorView];
    dispatch_async(dispatch_get_global_queue(self.priority, 0), ^{
        self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (id)processData:(NSData *)data
{
    return data;
}

- (void)cancel
{
    [self manageStatusBarIndicatorView];
    [self.connection cancel];
    [self finish];
    
    [super cancel];
}

- (void)finish
{
    [self manageStatusBarIndicatorView];
    
    self.isExecuting = NO;
    self.isFinished = YES;
}

- (void)manageStatusBarIndicatorView
{
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([[self class] sharedOperationQueue].operationCount) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        } else {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    });
}

#pragma mark - URL connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    id object = [self processData:self.data];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.handler) {
            self.handler(self.response, object, nil);
            self.handler = nil;
        }
    });
    [self finish];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error: %@", [error localizedDescription]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.handler) {
            self.handler(self.response, self.data, error);
            self.handler = nil;
        }
    });
    [self finish];
}

@end
