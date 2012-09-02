#import "ISNetworkClientTests.h"
#import "ISNetworkClient.h"

@implementation ISNetworkClientTests

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

- (void)testSendRequest
{
    NSURL *URL = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [ISNetworkClient sendRequest:request
                         handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                             if (error || response.statusCode != 200) {
                                 STFail(@"counld not complete operation");
                             }
                             
                             [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1f]];
                             NSUInteger count = [ISNetworkClient sharedClient].operationQueue.operationCount;
                             STAssertTrue(count == 0, @"could not dequeue operation.");
                             self.finished = YES;
                         }];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1f]];
    NSUInteger count = [ISNetworkClient sharedClient].operationQueue.operationCount;
    STAssertTrue(count == 1, @"could not enqueue operation");
}

- (void)testCancelAllOperations
{
    NSInteger maxCount = 10;
    NSUInteger count;
    
    for (NSInteger i=0; i<maxCount; i++) {
        NSURL *URL = [NSURL URLWithString:@"http://www.google.com"];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        [ISNetworkClient sendRequest:request
                             handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                                 if (error || response.statusCode != 200) {
                                     STFail(@"counld not complete operation");
                                 }
                             }];
    }
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1f]];
    count = [ISNetworkClient sharedClient].operationQueue.operationCount;
    STAssertTrue(count == maxCount, @"could not enqueue operations");
    
    [ISNetworkClient cancelAllOperations];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1f]];
    count = [ISNetworkClient sharedClient].operationQueue.operationCount;
    STAssertTrue(count == 0, @"could not cancel operations");
    
    self.finished = YES;
}

- (void)testSharedClient
{
    ISNetworkClient *client1 = [ISNetworkClient sharedClient];
    ISNetworkClient *client2 = [ISNetworkClient sharedClient];
    
    STAssertEqualObjects(client1, client2, @"shared client did change");
    self.finished = YES;
}

@end
