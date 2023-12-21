//
//  ViewController.h
//  test
//
//  Created by 叶常青 on 2023/11/23.
//

#import <UIKit/UIKit.h>
#import <gforceprofile/gforceprofile.h>



@interface ViewController : UIViewController
{

}
@property (nonatomic, retain) IBOutlet UIButton *scanButton;
@property (nonatomic, retain) IBOutlet UIButton *connectButton;
@property (nonatomic, retain) IBOutlet UIButton *versionButton;

@property (nonatomic, retain) IBOutlet UILabel *deviceText;
@property (nonatomic, retain) IBOutlet UILabel *statusText;
@property (nonatomic, retain) IBOutlet UILabel *versionText;

- (IBAction)onScan:(id)sender;
- (IBAction)onConnect:(id)sender;
- (IBAction)onVersion:(id)sender;
@end

