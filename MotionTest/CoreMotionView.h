//
//  CoreMotionView.h
//  MotionTest
//
//  Created by Kevin Loken on 11-07-22.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMotion/CoreMotion.h>

@interface CoreMotionView : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITextField *_textfield;
    IBOutlet UIButton    *_startButton;
    
    NSString    *_activity;
    NSMutableArray *_data;
    NSTimer *_timer;
    
    CMMotionManager *_motionManager;
    NSOperationQueue *_queue;
    
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
