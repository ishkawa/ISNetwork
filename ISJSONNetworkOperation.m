#import "ISJSONNetworkOperation.h"

@implementation ISJSONNetworkOperation

+ (id)operationWithRequest:(NSURLRequest *)request
{
    ISJSONNetworkOperation *operation = [[[ISJSONNetworkOperation alloc] init] autorelease];
    operation.request = request;
    
    return operation;
}

- (id)processData:(NSData *)data
{
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    if (error) {
        NSLog(@"error: %@", error);
        return nil;
    }
    return object;
}

@end
