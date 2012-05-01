#import "ISJSONNetworkOperation.h"

@implementation ISJSONNetworkOperation

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
