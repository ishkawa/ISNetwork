#import "ISViewController.h"
#import "ISDetailViewController.h"

@implementation ISViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.tweets = @[];
        self.imageCache = [[[NSCache alloc] init] autorelease];
        
        self.navigationItem.title = @"ISNetwork";
        self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                       target:self
                                                       action:@selector(refresh)] autorelease];
    }
    return self;
}

- (void)dealloc
{
    self.tweets = nil;
    self.imageCache = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    if (![self.tweets count]) {
        [self refresh];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [ISNetworkClient cancelAllOperations];
    [super viewWillDisappear:animated];
}

- (void)refresh
{
    [ISNetworkClient cancelAllOperations];
    
    NSURL *URL = [NSURL URLWithString:@"https://api.twitter.com/1/search.json?q=twitter&rpp=100"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [ISNetworkClient sendRequest:request
                  operationClass:[ISJSONNetworkOperation class]
                         handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                             if (error || response.statusCode != 200) {
                                 return;
                             }
                             self.tweets = [object objectForKey:@"results"];
                             [self.tableView reloadData];
                         }];
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
    }
    NSDictionary *tweet = [self.tweets objectAtIndex:indexPath.row];
    cell.textLabel.text = [tweet objectForKey:@"from_user"];
    cell.detailTextLabel.text = [tweet objectForKey:@"text"];
    
    NSURL *URL = [NSURL URLWithString:[tweet objectForKey:@"profile_image_url"]];
    cell.imageView.image = [self.imageCache objectForKey:URL];
    if (cell.imageView.image == nil) {
        cell.imageView.image = [UIImage imageNamed:@"white"];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [ISNetworkClient sendRequest:request
                      operationClass:[ISImageNetworkOperation class]
                             handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                                 if (error || response.statusCode != 200) {
                                     return;
                                 }
                                 UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                                 cell.imageView.image = object;
                                 
                                 [self.imageCache setObject:object forKey:URL];
                             }];
    }
    
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tweet = [self.tweets objectAtIndex:indexPath.row];
    ISDetailViewController *viewController = [[[ISDetailViewController alloc] initWithTweet:tweet] autorelease];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
