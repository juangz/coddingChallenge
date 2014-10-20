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
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property UIActivityIndicatorView *spinner;
@property UIImageView *spinnerView;
@property NSString * webTitle;
@property NSString * webImage;
@property NSString * webDescription;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // set image to the textField
    [self.textField setLeftViewMode:UITextFieldViewModeAlways];
    
    UIImageView* imgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"linkImage.png"]];
    [imgView setFrame:CGRectMake(0, self.textField.frame.size.height/2, self.textField.frame.size.height/2, self.textField.frame.size.height/4)];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
   
    
    // set appeareance for the navigation bar
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadow.shadowColor = [UIColor redColor];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"GUIDEPOST";
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:172/255.0 blue:98/255.0 alpha:1];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"GillSans" size:25.0f]}];
   
    
    
    self.textField.leftView= imgView;
    self.urlToDownload = [[NSURL alloc] initWithString: @"https://www.facebook.com/thebeatles"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)endEditting:(id)sender {
    UITextField *textEdit =(UITextField*) sender;
    NSMutableString *textCompleted = [[NSMutableString alloc]initWithString:textEdit.text];
    
    if (!([textCompleted hasPrefix:@"http://"] || [textCompleted hasPrefix:@"https://"])){
        [textCompleted insertString:@"http://" atIndex:0];
    }
    BOOL isValid = [self validateUrl:textCompleted];
    
    if (!isValid){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid url" message:@"The introduced url is not valid" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
        [alert show];

    }
    
}

- (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

- (IBAction)download:(id)sender {

    [self.textField resignFirstResponder];
    [self showSpinner];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.urlToDownload];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:urlRequest  delegate:self];
    
//    NSData  * data      = [NSData dataWithContentsOfURL:self.urlToDownload];
//    
//    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
//    
//    NSString *xPathQueryString = @"//meta[@property=\"og:title\"]/@content";
//    NSArray * elements  = [doc searchWithXPathQuery:xPathQueryString];
//    
//    for (TFHppleElement *element in elements ){
//        
//        int ;
//      //  [element]
//    }
   
    
    
//    TFHppleElement * element = [elements objectAtIndex:0];
//    [e text];                       // The text inside the HTML element (the content of the first text node)
//    [e tagName];                    // "a"
//    [e attributes];                 // NSDictionary of href, class, id, etc.
//    [e objectForKey:@"href"];       // Easy access to single attribute
//    [e firstChildWithTagName:@"b"]; // The first "b" child node
    
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"didReceiveResponse");
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"didReceiveData");
    
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
    NSDictionary * attributes;
    BOOL hasOG = YES;
    
    NSString *xPathQueryString = @"//meta[@property='og:title'] | //meta[@property='og:image'] | //meta[@property='og:description']";
    NSArray * elements  = [doc searchWithXPathQuery:xPathQueryString];
    
    
    if([elements count] < 3){
        hasOG = NO;
        xPathQueryString = @"//title | //meta[@name='description']";
        elements = [doc searchWithXPathQuery:xPathQueryString];
    }
    
    for (TFHppleElement *element in elements ){
        
        attributes = [element attributes];
        if(hasOG){
            
            if([((NSString *)[attributes objectForKey:@"property"]) isEqual:@"og:title"]){
                self.webTitle = (NSString *)[attributes objectForKey:@"content"];
            }
            else if([((NSString *)[attributes objectForKey:@"property"]) isEqual:@"og:image"]){
                self.webImage = (NSString *)[attributes objectForKey:@"content"];
            }
            else if([((NSString *)[attributes objectForKey:@"property"]) isEqual:@"og:description"]){
                self.webDescription = (NSString *)[attributes objectForKey:@"content"];
            }
        }
        else{
            
            if([[element tagName] isEqual:@"title"]){
                self.webTitle = [element text];
            }
            // assume that the other node is the description
            else if([[element attributes] count] > 0){
                
                self.webDescription = [[element attributes] objectForKey:@"content"];
            }
            
        }
    }
    [self stopSpinner];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"connectionDidFinishLoading");
    
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
    
    [self stopSpinner];
    
}

-(void) showSpinner{
    self.spinnerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spinnerView.png"]];
    [self.spinnerView setFrame:self.downloadButton.bounds];
    self.downloadButton.enabled = NO;
    [self.downloadButton addSubview:self.spinnerView];
    
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame =self.downloadButton.bounds;

    [self.downloadButton addSubview:self.spinner];
    [self.spinner startAnimating];;
    
}

-(void) stopSpinner{
    [self.spinner stopAnimating];
}

@end
