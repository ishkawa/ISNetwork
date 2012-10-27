## Requirements

- iOS 5.0 or later.
- ARC

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
[ISNetworkClient sendRequest:request
                     handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                         if (error || response.statusCode != 200) {
                             // error
                             return;
                         }
                         // completion
                     }];
```


## non-ARC support

use [previous version](https://github.com/ishkawa/ISNetwork/commit/c028fa88ca8b5bf0151f3d1e792de79b304b535d).
