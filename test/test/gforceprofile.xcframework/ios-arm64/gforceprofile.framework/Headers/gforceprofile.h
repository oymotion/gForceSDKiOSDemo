//
//  gforceprofile.h
//  gforceprofile
//
//  Created by oymotion on 2023/12/11.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEPeripheral.h"
#import "gforcedefines.h"
//! Project version number for gforceprofile.
FOUNDATION_EXPORT double gforceprofileVersionNumber;

//! Project version string for gforceprofile.
FOUNDATION_EXPORT const unsigned char gforceprofileVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <gforceprofile/PublicHeader.h>

typedef void (^onlyResponseCallback)(GF_RET_CODE resp);
typedef void (^getFeatureMapCallback)(GF_RET_CODE resp, int featureBitmap);
typedef void (^getBatteryLevelCallback)(GF_RET_CODE resp, int batteryLevel);
typedef void (^getControllerFirmwareVersionCallback)(GF_RET_CODE resp, NSString* firmwareVersion);
typedef void (^getEmgRawDataConfigCallback)(GF_RET_CODE resp, int sampRate, int channelMask, int dataLen, int resolution);


@protocol gForceDelegate
- (void)ongForceErrorCallback: (NSError*)err;
- (void)ongForceStateChange: (BLEState)newState;
- (void)ongForceScanResult:(NSArray*) bleDevices;
- (void)ongForceNotifyData:(NSData*) rawData;

@end


@interface gForceProfile : NSObject
{
    
}
@property (atomic, weak) id<gForceDelegate> delegate;
@property (atomic, assign, readonly) BLEState state;
-(id)init;
-(BOOL)startScan;
-(void)stopScan;
-(BOOL)connect:(BLEPeripheral*)peripheral;
-(void)disconnect;
-(BOOL)startDataNotification;
-(BOOL)stopDataNotification;

-(GF_RET_CODE)getFeatureMap:(getFeatureMapCallback)cb timeout:(NSTimeInterval)timeout;
-(GF_RET_CODE)getBatteryLevel:(getBatteryLevelCallback)cb timeout:(NSTimeInterval)timeout;
-(GF_RET_CODE)getControllerFirmwareVersion:(getControllerFirmwareVersionCallback)cb timeout:(NSTimeInterval)timeout;


-(GF_RET_CODE)setDataNotifSwitch:(DataNotifyFlags)flags cb:(onlyResponseCallback)cb timeout:(NSTimeInterval)timeout;

-(GF_RET_CODE)getEmgRawDataConfig:(getEmgRawDataConfigCallback)cb timeout:(NSTimeInterval)timeout;
-(GF_RET_CODE)setEmgRawDataConfig:(int)sampRate channelMask:(int)channelMask dataLen:(int) dataLen resolution:(int)resolution cb:(onlyResponseCallback)cb timeout:(NSTimeInterval)timeout;
@end
