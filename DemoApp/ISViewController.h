#import <UIKit/UIKit.h>

@interface ISViewController : UITableViewController

@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) NSCache *imageCache;

@end
