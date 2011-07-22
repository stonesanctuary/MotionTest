//
//  AccelerometerView.h
//  MotionTest
//
//  Created by Kevin Loken on 11-07-21.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AccelerometerView : UIViewController< UITextFieldDelegate, UIAccelerometerDelegate >
{
    IBOutlet UITextField *_textfield;
    IBOutlet UIButton    *_startButton;
    
    NSString    *_activity;
    NSMutableArray *_data;
    UIAccelerometer *_accelerometer;
    NSTimer *_timer;
    
    SystemSoundID shortSound;
}

@property (nonatomic, retain) NSString  *activity;
@property (nonatomic, retain) UITextField *textfield;
@property (nonatomic, retain) UIButton *startButton;

-(IBAction)startRecording:(id)sender;


-(void)start;
-(void)stop;
-(void)saveFile;
-(NSString*)makeFilename;

@end
