#import "ISNetworkOperation.h"
#import "ISNetworkClient.h"

@interface ISNetworkOperation ()

@property BOOL isExecuting;
@property BOOL isFinished;

@end

@implementation ISNetworkOperation 

@synthesize priority   = _priority;
@synthesize request    = _request;
@synthesize response   = _response;
@synthesize data       = _data;
@synthesize connection = _connection;
@synthesize handler    = _handler;

@synthesize isExecuting = _isExecuting;
@synthesize isFinished  = _isFinished;

#pragma mark - KVO

- (BOOL)isConcurrent
{
    return YES;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return YES;
}

#pragma mark - life cycle

+ (id)operationWithRequest:(NSURLRequest *)request
{
    return [self operationWithRequest:request handler:nil];
}

+ (id)operationWithRequest:(NSURLRequest *)request handler:(void (^)(NSHTTPURLResponse *, id, NSError *))handler
{
    ISNetworkOperation *operation = [[[[self class] alloc] init] autorelease];
    operation.request = request;
    operation.handler = handler;
    
    return operation;
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
    self.request    = nil;
    self.response   = nil;
    self.data       = nil;
    self.connection = nil;
    self.handler    = nil;

    [super dealloc];
}

#pragma mark - action

- (void) start
{
    if ([self isCancelled]) {
        self.isExecuting = NO;
        self.isFinished = YES;
        return;
    }

    self.isExecuting = YES;
    self.isFinished = NO;
    
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
    [self.connection cancel];
    [self finish];
    
    [super cancel];
}

- (void)finish
{
    self.isExecuting = NO;
    self.isFinished = YES;
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


#pragma mark - depricated

+ (NSOperationQueue *)sharedOperationQueue
{
    return [ISNetworkClient sharedClient].operationQueue;
}

+ (void)sendRequest:(NSURLRequest *)request handler:(void (^)(NSHTTPURLResponse *, id, NSError *))handler
{
    ISNetworkOperation *operation = [self operationWithRequest:request handler:handler];
    [[ISNetworkClient sharedClient].operationQueue addOperation:operation];
}

- (void)enqueueWithHandler:(void (^)(NSHTTPURLResponse *, id, NSError *))handler
{
    self.handler = handler;
    [[ISNetworkClient sharedClient].operationQueue addOperation:self];
}

@end
