#import "ISAppDelegate.h"
#import "ISViewController.h"

@implementation ISAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[[ISViewController alloc] init] autorelease];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
