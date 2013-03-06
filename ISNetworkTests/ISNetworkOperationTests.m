#import "ISNetworkOperationTests.h"
#import "ISNetworkOperation.h"

@implementation ISNetworkOperationTests

- (void)setUp
{
    [super setUp];
    
    self.finished = NO;
}

- (void)tearDown
{
    do {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1f]];
    } while (!self.isFinished);
    
    [super tearDown];
}

#pragma mark - normal operation

- (void)testGETRequest
{
    self.finished = YES;
    NSURL *URL = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
 
    ISNetworkOperation *operation =
    [ISNetworkOperation operationWithRequest:request
                                     handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                                         if (error || response.statusCode != 200) {
                                             STFail(@"could not complete GET request.");
                                             self.finished = YES;
                                         }
                                         self.finished = YES;
                                     }];
    [operation start];
}

- (void)testPOSTRequest
{
    NSURL *URL = [NSURL URLWithString:@"http://posttestserver.com/post.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    ISNetworkOperation *operation =
    [ISNetworkOperation operationWithRequest:request
                                     handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                                         if (error || response.statusCode != 200) {
                                             STFail(@"could not complete GET request.");
                                         }
                                         self.finished = YES;
                                     }];
    [operation start];
}

- (void)testCompletionHandlerRunsOnMainThread
{
    NSURL *URL = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    ISNetworkOperation *operation =
    [ISNetworkOperation operationWithRequest:request
                                     handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                                         STAssertTrue([NSThread isMainThread], nil);
                                         self.finished = YES;
                                     }];
    [operation start];
}

- (void)testFailureHandlerRunsOnMainThread
{
    NSURL *URL = [NSURL URLWithString:@"http://www.gdsfasdfjjjlsad.co"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    ISNetworkOperation *operation =
    [ISNetworkOperation operationWithRequest:request
                                     handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                                         STAssertTrue([NSThread isMainThread], nil);
                                         self.finished = YES;
                                     }];
    [operation start];
}

- (void)testDeallocOnCancelBeforeStart
{
    __weak id woperation = nil;
    @autoreleasepool {
        NSURL *URL = [NSURL URLWithString:@"http://www.google.com"];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        ISNetworkOperation *operation = [ISNetworkOperation operationWithRequest:request handler:nil];
        woperation = operation;
        [operation cancel];
        [NSThread sleepForTimeInterval:.1];
    }
    
    STAssertNil(woperation, nil);
    self.finished = YES;
}

- (void)testDeallocOnCancelAfterStart
{
    __weak id woperation = nil;
    @autoreleasepool {
        NSURL *URL = [NSURL URLWithString:@"http://www.google.com"];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        ISNetworkOperation *operation = [ISNetworkOperation operationWithRequest:request handler:nil];
        woperation = operation;
        [operation start];
        [operation cancel];
        [NSThread sleepForTimeInterval:.1];
    }
    
    STAssertNil(woperation, nil);
    self.finished = YES;
}
#pragma mark - error handling

- (void)testInvalidHosts
{
    NSLog(@"this test may take long time...");
    
    // invalid host (does not exist)
    NSURL *URL = [NSURL URLWithString:@"http://www.afdsapfspefsadfadsd.fasdsfqwertyuiooo"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    ISNetworkOperation *operation =
    [ISNetworkOperation operationWithRequest:request
                                     handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                                         BOOL isExpectedDomain = [error.domain isEqualToString:NSURLErrorDomain];
                                         BOOL isExpectedCode   = (error.code == -1003 || error.code == -1001);
                                         if (isExpectedCode && isExpectedDomain) {
                                             // expected error
                                             // --
                                             // description: "A server with the specified hostname could not be found."
                                             // domain: NSURLErrorDomain
                                             // code: -1003
                                             // --
                                             // description: "The request timed out."
                                             // domain: NSURLErrorDomain
                                             // code: -1001
                                            
                                             self.finished = YES;
                                             return;
                                         }
                                         self.finished = YES;
                                         STFail(@"counld not handle host error.");
                                     }];
    [operation start];
}

- (void)testNotFound
{
    // invalid path (host exists)
    NSURL *URL = [NSURL URLWithString:@"http://www.google.com/hgafhasifsgwifeioa;efwehhujiko"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    ISNetworkOperation *operation =
    [ISNetworkOperation operationWithRequest:request
                                     handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                                         if (response.statusCode == 404) {
                                             self.finished = YES;
                                             return;
                                         }
                                         self.finished = YES;
                                         STFail(@"counld not handle 404 response.");
                                     }];
    [operation start];
}

@end
