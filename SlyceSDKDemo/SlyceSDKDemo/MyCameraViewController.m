//
//  CustomCameraViewController.m
//  SlyceSDKDemo
//
//  Created by Nathan Gurfinkel on 2/3/15.
//  Copyright (c) 2015 Slyce. All rights reserved.
//

#import "MyCameraViewController.h"
#import "MyProductsViewController.h"
#import "MBProgressHUD.h"
#import <SlyceSDK/SlyceSDK.h>

//This is *your* custom view controller where you want to use the SDK's Camera view
@interface MyCameraViewController () <SFCameraViewDelegate, SFRequestDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) SFCameraView *cameraView;

@property (nonatomic, copy) NSArray *products;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultAdditionalLabel;
@property (weak, nonatomic) IBOutlet UILabel *premiumLabel;

@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation MyCameraViewController


#pragma mark
#pragma mark - UIAlertViewDelegate

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    [_cameraView pauseCapture];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [_cameraView resumeCapture];
}

#pragma mark -
#pragma mark Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ProductsSegue"])
    {
        MyProductsViewController *productsVC = segue.destinationViewController;
        productsVC.products = _products;
    }
}

#pragma mark -
#pragma mark SFCameraViewDelegate

- (void)sfCameraView:(SFCameraView *)cameraView didReceiveResults:(NSDictionary *)results
{
    
    
    NSArray *products = [results objectForKey:@"products"];
    
    NSLog(@"sfCameraView:didReceiveResults:%@", products);
    [self.hud hide:YES];
    _cancelButton.hidden = YES;
    
    self.products = [products copy];
    
    [self performSegueWithIdentifier:@"ProductsSegue" sender:nil];
}

- (void)sfCameraView:(SFCameraView *)cameraView didReceiveResultsExt:(NSString *)results
{
    NSLog(@"sfCameraView:didReceiveResultsExt: %@", results);
    
    [self.hud hide:YES];
    _cancelButton.hidden = YES;
}


- (void)sfCameraView:(SFCameraView *)cameraView didProgressToValue:(CGFloat)value withMessage:(NSString *)message
{
    NSLog(@"sfCameraView:didProgressToValue:%.2f withMessage:%@", value, message);
    self.hud.labelText = message;
}

- (void)sfCameraView:(SFCameraView *)cameraView didProgressExt:(NSString *)progress
{
    NSLog(@"sfCameraView:didProgressExt:%@", progress);
}

- (void)sfCameraView:(SFCameraView *)cameraView didDetectBarcode:(SFBarcode *)barcode
{
    NSLog(@"sfCameraView:didDetectBarcode:%@", barcode.text);
    [self.hud hide:YES];
    _cancelButton.hidden = YES;
    
   // [_cameraView resumeCapture];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:barcode.typeString message:barcode.text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
}

- (void)sfCameraView:(SFCameraView *)cameraView didReceiveBarcodeInfo:(NSURL *)productURL
{
    NSLog(@"sfCameraView:didReceiveBarcodeInfo:%@", productURL);
}

- (void)sfCameraView:(SFCameraView *)cameraView didFailWithError:(NSError *)error
{
    NSString *message = error.domain == SlyceErrorDomain ? [error sf_message] : [error localizedDescription];
    NSLog(@"sfCameraView:didFailWithError:%@", message);
    
    [self.hud hide:YES];
    _cancelButton.hidden = YES;
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}

- (void)sfCameraView:(SFCameraView *)cameraView didReceiveImageInfo:(NSArray *)products
{
    NSLog(@"sfCameraView:didReceiveImageInfo:%@", products);
    [self.hud hide:YES];
    _cancelButton.hidden = YES;
    
    self.products = [products copy];
      
    [self performSegueWithIdentifier:@"ProductsSegue" sender:nil];
}


- (void)sfCameraView:(SFCameraView *)cameraView didDetectImage:(NSDictionary *)imageInfo
{
    NSLog(@"sfCameraView:didDetectImage:%@", imageInfo);
    self.resultLabel.text = [imageInfo description];
    
    [self renderToImage];

}

- (UIImage *)renderToImage
{
    CGRect viewRect = self.view.frame;
    UIGraphicsBeginImageContextWithOptions(viewRect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (void)sfCameraView:(SFCameraView *)cameraView didSnapImage:(UIImage *)image
{
    
    NSLog(@"sfCameraView:didSnapImage:");
    [self.hud show:YES];
    _cancelButton.hidden = NO;
    
    [_cameraView pauseCapture];
    
}

- (void)sfCameraView:(SFCameraView *)cameraView wasTappedInPoint:(CGPoint)point
{
    NSLog(@"sfCameraView:wasTappedInPoint:%@", NSStringFromCGPoint(point));
}

#pragma mark -
#pragma mark View LifeCycle

- (void)viewDidLayoutSubviews
{
    
    //Update the underlying video preview layer to match the frame
    if (self.cameraView)
        self.cameraView.previewLayer.frame = self.view.frame;
     
}

//Call `startCamera` of SFCamera object in `viewDidAppear:`
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Start the camera ONLY after the view has actually appeared, as this operation is CPU consuming!
    [self.cameraView startCamera];
    
    [self.cameraView resumeCapture];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *isPremium = _slyce.isPremiumUser ? @"YES" : @"NO";
    NSString *is2DEnabled = _slyce.is2DSearchEnabled ? @"YES" : @"NO";
    self.premiumLabel.text = [NSString stringWithFormat:@"Premium = %@, 2D Enabled = %@", isPremium, is2DEnabled];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.dimBackground = YES;
    self.hud.labelText = @"Sending image";
    self.hud.animationType = MBProgressHUDAnimationZoom;
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.hud];
    
    [self addCancelButton];
    
    
    self.cameraView = [[SFCameraView alloc] initWithSlyce:_slyce view:self.view options:nil andDelegate:self];
    
    
  //  self.cameraView.shouldUseContinuousRecognition = NO; //Uncomment this line if you don't wish to get notified automatically about recognized barcodes/2D items (Premium) (default is YES)
    
  //  self.cameraView.shouldPauseScannerAfterRecognition = NO; //Uncomment this line if you don't wish the auto scanner to pause after a successful detection (default is YES), default resume capture delay time is '3 sec'.
    
   // self.cameraView.shouldUseContinuousRecognition2D = NO; //Uncomment this line if you don't wish to get notified automatically about recognized 2D items (Premium) (default is YES)
    
   // self.cameraView.shouldUseContinuousRecognitionBarcodes = NO; //Uncomment this line if you don't wish to get notified automatically about recognized Barcodes items (default is YES)
    
   // self.cameraView.shouldPauseScannerDelayTime = 4; //Uncomment this line if you don't wish the auto scanner to pause after a successful detection with your custom delay time.
    
    
    // self.cameraView.detectionDelay2D = 5; // Uncomment this line if you want to add delay before 2D image detection starts or between detections, the default is 0 (Immediate detection).
    
    // self.cameraView.detectionDelay2DSameImage = 7; //Uncomment this line if you want to add delay between same 2D image detections, the default is 3 Sec delay.


}


- (void)viewDidDisappear:(BOOL)animated
{
    
    
    [self.cameraView pauseCapture];
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)flipCamera:(id)sender {
    
    [_cameraView flipCameraPosition];
}


- (void)cancelSearch
{    
    [self.cameraView resumeCapture];
    [self.cameraView.currentRequest cancel];
    [self.hud hide:YES];
    _cancelButton.hidden = YES;
}

- (IBAction)back:(id)sender
{
    [self.cameraView stopCamera];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)snap:(id)sender
{
    self.hud.labelText = @"Sending image";
    [self.cameraView snap];
}

- (IBAction)toggleFlash:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.cameraView turnFlash:sender.selected];
}

#pragma mark -
#pragma mark Helpers

- (void)addCancelButton
{
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitleColor:[UIColor colorWithRed:192/255.f green:30/255.f blue:30/255.f alpha:1] forState:UIControlStateNormal];
    _cancelButton.frame = CGRectMake(self.hud.frame.size.width/2-70/2, self.hud.frame.size.height/2 + 60, 70, 30);
    _cancelButton.translatesAutoresizingMaskIntoConstraints = YES;
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [_cancelButton addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.hidden = YES;
    [self.view addSubview:_cancelButton];
}

@end
