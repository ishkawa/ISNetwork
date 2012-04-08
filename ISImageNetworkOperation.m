#import "ISImageNetworkOperation.h"

@implementation ISImageNetworkOperation

+ (id)operationWithRequest:(NSURLRequest *)request
{
    ISImageNetworkOperation *operation = [[[ISImageNetworkOperation alloc] init] autorelease];
    operation.request = request;
    
    return operation;
}

- (id)processData:(NSData *)data
{
    return [UIImage imageWithData:data];
}

@end
