//
//  AccelerometerView.m
//  MotionTest
//
//  Created by Kevin Loken on 11-07-21.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

#import "AccelerometerView.h"
#import <AudioToolbox/AudioToolbox.h>

#define kDelayBeforeRecording 5
#define kRecordForThisManySeconds 10

@implementation AccelerometerView

@synthesize activity = _activity;
@synthesize textfield = _textfield;
@synthesize startButton = _startButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[self navigationItem] setTitle:@"Accelerometer"];
        
        _data = [[NSMutableArray alloc] initWithCapacity:(60 * 10)];
        
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"tap" ofType:@"aif"];
        if ( soundPath ) {
            NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
            OSStatus err = AudioServicesCreateSystemSoundID((CFURLRef)soundURL, &shortSound);
            if ( err != kAudioServicesNoError ) {
                NSLog(@"Could not load %@, error code: %ld", soundURL, err);
            }
        }

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[self view] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    [_startButton setTitle:@"Disabled" forState:UIControlStateDisabled];
    
    [[self startButton] setEnabled:NO];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [_textfield release], _textfield = nil;
    [_activity release], _activity = nil;
    [_data release], _data = nil;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIAccelerometer sharedAccelerometer]setDelegate:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc
{
    [_textfield release], _textfield = nil;
    [_activity release], _activity = nil;
    [_data release], _data = nil;
    
    AudioServicesDisposeSystemSoundID(shortSound);
    [super dealloc];
}

#pragma mark - Interface Functions

-(void)startRecording:(id)sender
{
    NSLog(@"recording button pressed ...");
    [_startButton setEnabled:NO];
    [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:kDelayBeforeRecording target:self selector:@selector(start) userInfo:nil repeats:NO];
}

-(void)start
{
    NSLog(@"recording started !");
    
    
    // [_timer release], _timer = nil;
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(shortSound);
    
    [NSTimer scheduledTimerWithTimeInterval:kRecordForThisManySeconds target:self selector:@selector(stop) userInfo:nil repeats:NO];
    
    UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
    [accel setDelegate:self];  
    [accel setUpdateInterval:1.0/60.0];
}

-(void)stop
{
    NSLog(@"recording stopped !");
    
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [self saveFile];

    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(shortSound);
    
    [_startButton setEnabled:YES];
    [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
}

-(NSString*)makeFilename
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
    
    NSDate* now = [NSDate date];
    NSString* timedate = [dateFormatter stringFromDate:now];
    NSString* filename = [NSString stringWithFormat:@"%@-%@.xml", _activity, timedate];
    
    [dateFormatter release], dateFormatter = nil;
    // [timedate release], timedate = nil;
    // [now release], now = nil;
    
    return filename;
}

-(void)saveFile
{
    NSString *fileName = [self makeFilename];
    
    NSLog(@"would save with filename: %@", fileName);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    NSLog(@"documentsDirectory => %@", documentsDirectory);
    
    BOOL result = [_data writeToFile:documentsDirectory atomically:YES];
    if (!result ) {
        NSLog(@"failed to write the file?");
    } 
    
    [_data removeAllObjects];   
    
}

#pragma mark - UITextField delegate functions

/*
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text

- (BOOL)textFieldShouldClear:(UITextField *)textField;               // called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
*/

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _textfield) {
        [_textfield resignFirstResponder];
        return YES;
    }
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ( textField == _textfield ) {
        self.activity = [textField text];
        if ([self.activity length] > 0) {
            [_startButton setEnabled:YES];
        }
    }
}

#pragma mark - UIAccelerometer delegate functions

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    NSMutableDictionary* sample = [NSMutableDictionary dictionaryWithCapacity:4];
    [sample setObject:[NSNumber numberWithDouble:acceleration.timestamp]  forKey:@"timestamp"];
    
    [sample setObject:[NSNumber numberWithDouble:acceleration.x] forKey:@"x"];
    [sample setObject:[NSNumber numberWithDouble:acceleration.y] forKey:@"y"];
    [sample setObject:[NSNumber numberWithDouble:acceleration.z] forKey:@"z"];
    
    [_data addObject:sample];

    // [sample release], sample = nil;
}

@end
