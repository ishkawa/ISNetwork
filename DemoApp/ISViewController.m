#import "ISViewController.h"

@implementation ISViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadSamplePage];
}

- (void)loadSamplePage
{
    NSURL *URL = [NSURL URLWithString:@"http://www.apple.com"];
    NSURLRequest *reqeust = [NSURLRequest requestWithURL:URL];
    
    [ISNetworkOperation sendRequest:reqeust
                            handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                                if (error || response.statusCode != 200) {
                                    // error
                                    return;
                                }
                                
                                // completion
                                NSString *string = [[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding] autorelease];
                                NSLog(@"result: %@", string);
                            }];
}

@end
