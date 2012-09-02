#import "ISDetailViewController.h"

@interface ISDetailViewController ()

@property (retain, nonatomic) UITextView *textView;
@property (retain, nonatomic) NSDictionary *tweet;

@end

@implementation ISDetailViewController

- (id)initWithTweet:(NSDictionary *)tweet
{
    self = [super init];
    if (self) {
        self.tweet = tweet;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.textView = [[[UITextView alloc] init] autorelease];
    self.textView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    self.textView.frame = CGRectMake(0, 0,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
    
    [self.view addSubview:self.textView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = [self.tweet objectForKey:@"from_user"];
    self.textView.text = [self.tweet objectForKey:@"text"];
}

@end
