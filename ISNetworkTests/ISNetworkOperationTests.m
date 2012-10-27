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
    NSURL *URL = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
 
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

- (void)testHandlerRunsOnMainThread
{
    NSURL *URL = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    ISNetworkOperation *operation =
    [ISNetworkOperation operationWithRequest:request
                                     handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                                         if (![[NSThread currentThread] isMainThread]) {
                                             STFail(@"completion handler did not run on main thread.");
                                         }
                                         self.finished = YES;
                                     }];
    [operation start];
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
