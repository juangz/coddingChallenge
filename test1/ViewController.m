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
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTV;
@property (weak, nonatomic) IBOutlet UITextField *tittleTF;
@property NSMutableData *downloadedData;
@property UIActivityIndicatorView *spinner;
@property UIImageView *spinnerView;
@property NSString * webTitle;
@property NSString * webImage;
@property NSString * webDescription;

@end

@implementation ViewController

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tittleTF.hidden = YES;
    self.descriptionTV.hidden = YES;
    self.image.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // set image to the textField
    [self.textField setLeftViewMode:UITextFieldViewModeAlways];
    
    UIImageView* imgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"linkImage.png"]];
    //[imgView setFrame:CGRectMake(200, 200, self.textField.frame.size.height/2, self.textField.frame.size.height/4)];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    // add the image to the url
   // self.textField.leftView= imgView;
    
    
    
    [self.view addSubview:imgView];
    [imgView als_addConstraints:@{
                                  @"left ==": @{als_view: self.view.als_left, als_constant:@(130)},
                                  @"width ==": @(30),
                                  @"top ==":  @{als_view: self.view.als_top, als_constant:@(130)},
                                  @"height ==": @(30),
                                  }];
    [self.view bringSubviewToFront:imgView];

    
    
    // set appeareance for the navigation bar
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadow.shadowColor = [UIColor redColor];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"GUIDEPOST";
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:172/255.0 blue:98/255.0 alpha:1];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"GillSans" size:25.0f]}];
   
    
    
    self.urlToDownload = [[NSURL alloc] initWithString: @"https://www.facebook.com/thebeatles"];
    
    
    self.descriptionTV.delegate = self;
    self.descriptionTV.text = @"Add Description...";
   // self.descriptionTV.textColor = [UIColor lightGrayColor];
    
    self.downloadedData = [[NSMutableData alloc] init];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
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
    else{
        self.urlToDownload =[[NSURL alloc] initWithString:textCompleted];
        
        [self download:nil];
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
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"didReceiveResponse");
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"didReceiveData");
    
    
    [self.downloadedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"connectionDidFinishLoading");
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:self.downloadedData];
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
    
    
    NSURL *url = [NSURL URLWithString:self.webImage];
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    
    UIImage *tmpImage = [[UIImage alloc] initWithData:data];
    
    self.image.image = tmpImage;
    
    self.tittleTF.text = self.webTitle;
    self.descriptionTV.text = self.webDescription;
    
    
    
    [self stopSpinner];
    
    
    CGAffineTransform transform = CGAffineTransformMake(1, 0, 0, 1, 0, 280);
    [UIView animateWithDuration:0.25 animations:^{
        self.downloadButton.transform = transform;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
             if (finished){
                 self.tittleTF.hidden = NO;
                 self.descriptionTV.hidden = NO;
                 self.image.hidden = NO;
                 
                 UIImageView *iv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"directions.png"]];

                 [iv setFrame:self.downloadButton.bounds];
                 [iv setContentMode:UIViewContentModeCenter];
                 
                 [self.downloadButton addSubview:iv];
                 [self.downloadButton bringSubviewToFront:iv];
             }
        
    }];
    
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

# pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Add Description..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Add Description...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

@end
