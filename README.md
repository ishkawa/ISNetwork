## Files

- `ISNetwork/`  
ISNetwork objects.

- `ISNetworkTests/`  
unit test objects.

- `DemoApp/`  
objects for sample application.

## Usage

- add files in `ISNetwork/` and `NSDictionary-URLQuery/` to your xcode project.
- import ISNetwork

```objectivec
#import "ISNetwork.h"
```

- set up NSURLRequest

```objectivec
NSURL *URL = [NSURL URLWithString:@"http://www.github.com"];
NSURLRequest *reqeust = [NSURLRequest requestWithURL:URL];
```

- send request

```objectivec
NSURL *URL = [NSURL URLWithString:@"http://www.google.com"];
NSURLRequest *request = [NSURLRequest requestWithURL:URL];

[ISNetworkClient sendRequest:request
              operationClass:[ISJSONNetworkOperation class]
                     handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                         if (error || response.statusCode != 200) {
                             // error
                             return;
                         }
                         // completion
                     }];
```


## ARC support

please add `-fno-obj-arc` compile option to files of ISNetwork.
