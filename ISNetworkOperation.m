#import "ISNetworkOperation.h"

@implementation ISNetworkOperation

@synthesize request = _request;
@synthesize response = _response;
@synthesize data = _data;
@synthesize connection = _connection;
@synthesize handler = _handler;

#pragma mark - life cycle

static NSOperationQueue *_sharedOperationQueue;

+ (NSOperationQueue *)sharedOperationQueue
{
    if (_sharedOperationQueue == nil) {
        _sharedOperationQueue = [[NSOperationQueue alloc] init];
    }
    return _sharedOperationQueue;
}

+ (id)operationWithRequest:(NSURLRequest *)request
{
    ISNetworkOperation *operation = [[[[self class] alloc] init] autorelease];
    operation.request = request;
    
    return operation;
}

+ (void)sendRequest:(NSURLRequest *)request handler:(void (^)(NSURLResponse *, id, NSError *))handler
{
    [[self operationWithRequest:request] enqueueWithHandler:handler];
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

- (void)enqueueWithHandler:(void (^)(NSURLResponse *, id, NSError *))handler
{
    self.handler = handler;
    [[[self class] sharedOperationQueue] addOperation:self];
}

- (void)main
{
    [self manageStatusBarIndicatorView];
    self.data = [NSMutableData data];
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    CFRunLoopRun();
}

- (id)processData:(NSData *)data
{
    return data;
}

- (void)cancel
{
    [self manageStatusBarIndicatorView];
    [self.connection cancel];
    CFRunLoopStop(CFRunLoopGetCurrent());
    
    [super cancel];
}

- (void)manageStatusBarIndicatorView
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:0.5];
        if ([[self class] sharedOperationQueue].operationCount) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        } else {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    });
}

#pragma mark - URL connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self manageStatusBarIndicatorView];
    id object = [self processData:self.data];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.handler) {
            self.handler(self.response, object, nil);
            self.handler = nil;
        }
    });
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self manageStatusBarIndicatorView];
    NSLog(@"error: %@", [error localizedDescription]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.handler) {
            self.handler(self.response, self.data, error);
            self.handler = nil;
        }
    });
    CFRunLoopStop(CFRunLoopGetCurrent());
}

@end
