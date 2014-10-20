//
//  ViewController.m
//  test1
//
//  Created by UruCode on 10/20/14.
//
//

#import "ViewController.h"
#import "TFHpple.h"


@interface ViewController ()
@property NSURL *urlToDownload;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.urlToDownload = [[NSURL alloc] initWithString: @"https://www.facebook.com/thebeatles"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)download:(id)sender {
    
    NSData  * data      = [NSData dataWithContentsOfURL:self.urlToDownload];
    
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
    
    NSString *xPathQueryString = @"meta[@property=\"og:title\"]/@content";
    NSArray * elements  = [doc searchWithXPathQuery:xPathQueryString];
    
    for (TFHppleElement *element in elements ){
        
        int ;
      //  [element]
    }
   
    
    
//    TFHppleElement * element = [elements objectAtIndex:0];
//    [e text];                       // The text inside the HTML element (the content of the first text node)
//    [e tagName];                    // "a"
//    [e attributes];                 // NSDictionary of href, class, id, etc.
//    [e objectForKey:@"href"];       // Easy access to single attribute
//    [e firstChildWithTagName:@"b"]; // The first "b" child node
}

@end
