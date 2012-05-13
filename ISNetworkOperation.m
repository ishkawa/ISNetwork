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

- (id)init
{
    self = [super init];
    if (self) {
        _isExecuting = NO;
        _isFinished = NO;
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

#pragma mark - NSOperation statuses

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString*)key {
    if ([key isEqualToString:@"isExecuting"] || [key isEqualToString:@"isFinished"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (BOOL)isFinished
{
    return _isFinished;
}

#pragma mark - action

- (void)enqueueWithHandler:(void (^)(NSURLResponse *, id, NSError *))handler
{
    self.handler = handler;
    [[[self class] sharedOperationQueue] addOperation:self];
}

- (void)start
{
    [self manageStatusBarIndicatorView];
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isExecuting"];
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    } while ([self isExecuting]);
}

- (id)processData:(NSData *)data
{
    return data;
}

- (void)cancel
{
    [self.connection cancel];
    [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
    [super cancel];
}

- (void)manageStatusBarIndicatorView
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        if ([[self class] sharedOperationQueue].operationCount) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        } else {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }];
    [[NSOperationQueue mainQueue] performSelector:@selector(addOperation:)
                                       withObject:operation
                                       afterDelay:0.1];
}

#pragma mark - URL connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.data = [NSMutableData data];
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    id object = [self processData:self.data];
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        self.handler(self.response, object, nil);
        [self manageStatusBarIndicatorView];
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
    [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error: %@", [error localizedDescription]);
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        self.handler(self.response, self.data, error);
        [self manageStatusBarIndicatorView];
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
    [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
}

@end
