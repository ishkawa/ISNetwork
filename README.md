## Files

- `ISNetwork/`  
ISNetwork objects.

- `ISNetworkTests/`  
unit test objects.

- `DemoApp/`  
objects for sample application.

- `(NSDictionary-URLQuery)`  
submodule to generate URL query from NSDictionary.  
If you will not use `git submodule`, please get files from [here](https://github.com/ishkawa/NSDictionary-URLQuery)

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
[ISNetworkOperation sendRequest:request
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
