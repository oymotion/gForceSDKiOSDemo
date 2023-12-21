//
//  ViewController.m
//  test
//
//  Created by 叶常青 on 2023/11/23.
//

#import "ViewController.h"
#import "AppDelegate.h"

const int TIMEOUT = 5;
const int MAX_CHANNEL_COUNT = 8;

@interface ViewController ()<gForceDelegate>

@property (atomic, weak) gForceProfile* profile;
@property (atomic, strong) BLEPeripheral* device;
@property (atomic, assign) int sampleRate;
@property (atomic, assign) int channelMask;
@property (atomic, assign) int dataLen;
@property (atomic, assign) int resolution;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.profile = delegate.profile;
    self.profile.delegate = self;
}

- (IBAction)onScan:(id)sender{
    self.deviceText.text = @"scaning";
    [self.profile startScan];
}

- (IBAction)onConnect:(id)sender{
    if (self.profile.state == BLEStateConnected || self.profile.state == BLEStateRuning){
        [self.profile disconnect];
    }else if (self.device != nil){
        [self.profile connect:self.device];
    }
}

- (IBAction)onVersion:(id)sender{
    [self.profile getControllerFirmwareVersion:^(GF_RET_CODE resp, NSString *firmwareVersion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.versionText.text = firmwareVersion;
        });
        
    } timeout:TIMEOUT];
    
    [self.profile setDataNotifSwitch: (DNF_EMG_RAW | DNF_QUATERNION | DNF_EULERANGLE) cb:^(GF_RET_CODE resp) {
        NSLog(@"got set data notify response %ld", (long)resp);
        
    } timeout:TIMEOUT];
    
    [self.profile getEmgRawDataConfig:^(GF_RET_CODE resp, int sampRate, int channelMask, int dataLen, int resolution) {
        NSLog(@"got old emg config:%ld %d %d %d %d", (long)resp, sampRate, channelMask, dataLen, resolution);
        
        //we enable high 4 channels for demo, channelMask is bitmap
        [self.profile setEmgRawDataConfig:500 channelMask:0xF0 dataLen:128 resolution:resolution cb:^(GF_RET_CODE resp) {
            NSLog(@"set new emg config: %ld", (long)resp);
            
        } timeout:TIMEOUT];
        
        [self.profile getEmgRawDataConfig:^(GF_RET_CODE resp, int sampRate, int channelMask, int dataLen, int resolution) {
            NSLog(@"got new emg config:%ld %d %d %d %d",(long)resp, sampRate, channelMask, dataLen, resolution);
            
            self.sampleRate = sampRate;
            self.channelMask = channelMask;
            self.dataLen = dataLen;
            self.resolution = resolution;
            
            //start data transfer
            
            [self.profile startDataNotification];
            
        } timeout:TIMEOUT];
        
    } timeout:TIMEOUT];
    

}
#pragma mark - gForceDelegate
- (void)ongForceErrorCallback: (NSError*)err{
    NSLog(@"got gforce error %@", err);
}
- (void)ongForceStateChange: (BLEState)newState{
    if (newState == BLEStateConnected){
        self.statusText.text = @"Connected";
    }else if (newState == BLEStateRuning){
        self.statusText.text = @"Running";
    }else{
        self.statusText.text = @"Not Connected";
    }
}

- (void)ongForceScanResult:(NSArray *)bleDevices{

    int maxRSSI = -1000;
    BLEPeripheral* bleDeviceMax = nil;
    for (BLEPeripheral* bleDevice in bleDevices) {
        NSLog(@"Found device: %@, mac: %@, rssi: %@", bleDevice.peripheralName, bleDevice.macAddress, bleDevice.rssi);
        if ([bleDevice.rssi intValue] > maxRSSI){
            maxRSSI = [bleDevice.rssi intValue];
            bleDeviceMax = bleDevice;
        }
    }
    if (bleDeviceMax != nil){
        self.deviceText.text = [NSString stringWithFormat:@"name: %@\n mac: %@\n rssi: %@", bleDeviceMax.peripheralName, bleDeviceMax.macAddress, bleDeviceMax.rssi];
        self.device = bleDeviceMax;
    }else{
        self.deviceText.text = @"scan finish";
    }
    
}


- (void)ongForceNotifyData:(NSData *)rawData {
    if (rawData.length > 1){
        unsigned char* result = (unsigned char*)rawData.bytes;
        if (result[0] == NTF_EMG_ADC_DATA){
            NSLog(@"got emg data:%lu ", (unsigned long)rawData.length);
            int totalSamples = rawData.length - 1;
            int readOffset = 1;

            for (int channelIndex = 0;channelIndex < MAX_CHANNEL_COUNT;++channelIndex){
                if ((_channelMask & (1 << channelIndex)) > 0){
                    unsigned char adcData = result[readOffset++];
                    //do your logic
                }
                if (readOffset > totalSamples){
                    break;
                }
            }
        }else if (result[0] == NTF_QUAT_FLOAT_DATA){
            //4 float w,x,y,z
            float w,x,y,z;
            memcpy(&w, result + 1, 4);
            memcpy(&x, result + 5, 4);
            memcpy(&y, result + 9, 4);
            memcpy(&z, result + 13, 4);
            NSLog(@"got quaternion data:%lu| %f| %f| %f| %f", (unsigned long)rawData.length, w, x, y, z);
        }else if (result[0] == NTF_EULER_DATA){
            //3 float x,y,z
            float x,y,z;
            memcpy(&x, result + 1, 4);
            memcpy(&y, result + 5, 4);
            memcpy(&z, result + 9, 4);
            NSLog(@"got euler angle data:%lu| %f| %f| %f", (unsigned long)rawData.length, x, y, z);
        }
        
    }
}
@end
