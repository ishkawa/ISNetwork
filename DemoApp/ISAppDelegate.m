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
    ISViewController *viewController = [[[ISViewController alloc] init] autorelease];
    UINavigationController *navigationController =
    [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
