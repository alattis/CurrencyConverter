//
//  CCViewController.m
//  CurrencyConversion
//
//  Created by andrew lattis on 3/3/17.
//  Copyright © 2017 andrew lattis. All rights reserved.
//

#import "CCViewController.h"
#import "CurrencyConversion-Swift.h"

typedef enum : NSUInteger {
    PickerValueNone,
    PickerValueTo,
    PickerValueFrom,
} PickerValue;


@interface CCViewController () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *fromButton;
@property (weak, nonatomic) IBOutlet UIButton *toButton;

@property (nonatomic, strong) NSArray *sortedCurrencies;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic) PickerValue pickerSelecting;

- (IBAction)tapGestureDetected:(id)sender;
- (IBAction)fromButtonPressed:(UIButton *)sender;
- (IBAction)toButtonPressed:(UIButton *)sender;

@end


@implementation CCViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [[ConversionManager shared] refreshRatesWithHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success == NO) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Network Error" message:@"Oops, couldn't get the latest rates.." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                
                return;
            }
            
            [self conversionManagerDidRefreshRates];
        });

    }];
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.numberFormatter.maximumFractionDigits = 2;
    
    self.pickerView.alpha = 0.0;
}


- (IBAction)tapGestureDetected:(id)sender {
    [self.view endEditing:YES];
    [self hidePicker];
}

- (IBAction)fromButtonPressed:(UIButton *)sender {
    BOOL animated=false;
    if (self.pickerView.alpha == 1.0) {
        animated = true;
    }
    [self.pickerView selectRow:[self.sortedCurrencies indexOfObject:self.fromButton.titleLabel.text] inComponent:0 animated:animated];
    [self showPicker];
    self.pickerSelecting = PickerValueFrom;
}

- (IBAction)toButtonPressed:(UIButton *)sender {
    BOOL animated=false;
    if (self.pickerView.alpha == 1.0) {
        animated = true;
    }
    [self.pickerView selectRow:[self.sortedCurrencies indexOfObject:self.toButton.titleLabel.text] inComponent:0 animated:animated];
    [self showPicker];
    self.pickerSelecting = PickerValueTo;
}


- (void) showPicker {
    [UIView animateWithDuration:.3 animations:^{
        [self.view endEditing:YES];
        self.pickerView.alpha = 1.0;
    }];
}


- (void) hidePicker {
    [UIView animateWithDuration:.3 animations:^{
        self.pickerView.alpha = 0.0;
    }];
    self.pickerSelecting = PickerValueNone;
}


- (void) updateConversion {
    CGFloat value = [[self.numberFormatter numberFromString:self.fromTextField.text] floatValue];
    
    [self updateConversionWithValue:value reversed:false];
}


- (void)updateConversionWithValue:(CGFloat)value reversed:(BOOL)reversed {
    NSString *fromCurrency = self.fromButton.titleLabel.text;
    NSString *toCurrency = self.toButton.titleLabel.text;

    if (reversed) {
        CGFloat fromValue = [[ConversionManager shared] convertWithAmount:value from:toCurrency to:fromCurrency];
        self.fromTextField.text = [self.numberFormatter stringFromNumber:@(fromValue)];
    } else {
        CGFloat toValue = [[ConversionManager shared] convertWithAmount:value from:fromCurrency to:toCurrency];
        self.toTextField.text = [self.numberFormatter stringFromNumber:@(toValue)];
    }
}


-(void)conversionManagerDidRefreshRates {
    self.sortedCurrencies = [[[[ConversionManager shared] rates] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.pickerView reloadAllComponents];
    
    [self.fromButton setTitle:[[ConversionManager shared] baseRate] forState:UIControlStateNormal];
    [self.toButton setTitle:self.sortedCurrencies.firstObject forState:UIControlStateNormal]; //this isn't great, but it works for this data set
}



#pragma mark - Picker View Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.sortedCurrencies.count;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0 && row < self.sortedCurrencies.count) {
        return self.sortedCurrencies[row];
    }
    
    return @"";
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.pickerSelecting == PickerValueTo) {
        [self.toButton setTitle:self.sortedCurrencies[row] forState:UIControlStateNormal];
    } else if (self.pickerSelecting == PickerValueFrom) {
        [self.fromButton setTitle:self.sortedCurrencies[row] forState:UIControlStateNormal];
    }
    [self updateConversion];
}



#pragma mark - Text Field Methods

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self hidePicker];
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *fullString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    CGFloat value = [[self.numberFormatter numberFromString:fullString] floatValue];

    BOOL reversed = false;
    if (textField == self.toTextField) {
        reversed = true;
    }
    
    [self updateConversionWithValue:value reversed:reversed];
    
    return YES;
}

@end
