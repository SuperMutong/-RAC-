//
//  RegisterViewController.m
//  Food
//
//  Created by mac on 15/6/30.
//  Copyright (c) 2015年 MAC. All rights reserved.
//

#import "RegisterViewController.h"
#import <Masonry.h>
#import <ReactiveCocoa.h>
#import "RegisterObject.h"
static const int isecond = 120;
@interface RegisterViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UITextField *userPhoneTextField;
@property (nonatomic, strong) UITextField *codeTextField;
@property (nonatomic, strong) UIButton *codeBtn;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *twicePasswordTectfield;
@property (nonatomic, strong) UITextField *inviteTextField;
@property (nonatomic, strong) UIButton *commitBtn;

@property (nonatomic, strong) NSString *requestCodeStr;
@end

@implementation RegisterViewController
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden=NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addViews];
    [self createUI];
    [self listenUserPhone];
    [self addCodeBtnAction];
    [self commitUserInfomationAction];
}


#pragma mark -- 注册
- (void)commitUserInfomationAction{
    [[[[self.commitBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        self.commitBtn.userInteractionEnabled=NO;
    }]
    flattenMap:^RACStream *(id value) {
        return [self commitSignInSignal];
    }]
    subscribeNext:^(id x) {
        self.commitBtn.userInteractionEnabled = YES;
        NSLog(@"x:%@",x);
    }];
}
- (RACSignal *)commitSignInSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (![@"1234" isEqualToString:_codeTextField.text]) {
            [self createAlterWithTitle:@"验证码不正确"];
            self.commitBtn.userInteractionEnabled = YES;
        }
        else if (_passwordTextField.text.length<6){
            self.commitBtn.userInteractionEnabled = YES;
            [self createAlterWithTitle:@"密码不能少于6位"];
        }
        else if (![_passwordTextField.text isEqualToString:_twicePasswordTectfield.text])
        {
            self.commitBtn.userInteractionEnabled = YES;
            [self createAlterWithTitle:@"两次输入的密码不正确"];
        }
        else{
        [RegisterObject  RegisterNewUserWithUserPhone:self.userPhoneTextField.text andUserPassword:self.passwordTextField.text andInvitationCode:self.inviteTextField.text complete:^(NSDictionary *dic) {
            [subscriber sendNext:dic];
            [subscriber sendCompleted];
        }];
        }
        return  nil;
    }];
}

#pragma mark -- UIButtonAction
#pragma mark --获取验证码
//判断手机号位数
- (void)listenUserPhone{
   RACSignal *valiedUserName = [self.userPhoneTextField.rac_textSignal map:^id(id value) {
       return @([self judgeUserPhoneValid]);
   }];
    RAC(self.codeBtn, enabled) = [valiedUserName map:^id(id value) {
        return value;
    }];
}
- (BOOL)judgeUserPhoneValid{
    return _userPhoneTextField.text.length>5;
}
- (void)addCodeBtnAction{
    [[[[self.codeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
     doNext:^(id x) {
         self.codeBtn.userInteractionEnabled=NO;
         [self timeFireMethod:isecond];
     } ]
     flattenMap:^RACStream *(id value) {
         return [self codeSignInSignal];
     }]
     subscribeNext:^(id x) {
         NSLog(@"codeDic:%@",x);
    }];
    
}
- (RACSignal *)codeSignInSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [RegisterObject RequestCodeWithActionCode:@"0002" andUserPhone:self.userPhoneTextField.text complete:^(NSDictionary *dic) {
            [subscriber sendNext:dic];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}
-(void)timeFireMethod:(int)second{
    [_codeBtn setTitle:[NSString stringWithFormat:@"%d秒",second] forState:UIControlStateNormal];
    if (second == 0) {
        _codeBtn.userInteractionEnabled=YES;
        [_codeBtn setBackgroundColor:[UIColor whiteColor]];
        NSLog(@"从新发送");
        _requestCodeStr=nil;
        [_codeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        return;
    }
    double delayInseconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInseconds *NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        if (second != -1) {
            [self timeFireMethod:(second - 1)];
        }
        else{
            return ;
        }
    });
}
#pragma mark --createView
- (UIView *)backView{
    if (!_backView) {
        _backView = [UIView new];
    }
    return _backView;
}

- (UITextField *)userPhoneTextField{
    if (!_userPhoneTextField) {
        _userPhoneTextField = [UITextField new];
        _userPhoneTextField.placeholder=@"请输入手机号";
        _userPhoneTextField.delegate=self;
        _userPhoneTextField.borderStyle=UITextBorderStyleRoundedRect;
        UIImageView *userPhoneImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [userPhoneImageView setImage:[UIImage imageNamed:@"person"]];
        _userPhoneTextField.leftView=userPhoneImageView;
        _userPhoneTextField.leftViewMode=UITextFieldViewModeAlways;
    }
    return _userPhoneTextField;
}
- (UITextField *)codeTextField{
    if (!_codeTextField) {
        self.codeTextField = [[UITextField alloc]init];
        self.codeTextField.delegate=self;
        self.codeTextField.placeholder=@"点击获取验证码";
        self.codeTextField.borderStyle = UITextBorderStyleRoundedRect;
    }
    return _codeTextField;
}
- (UIButton *)codeBtn{
    if (!_codeBtn) {
        self.codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.codeBtn setTitle:@"请输入验证码" forState:UIControlStateNormal];
        self.codeBtn.enabled=NO;
        [self.codeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.codeBtn.layer setCornerRadius:2.0f];
        self.codeBtn.layer.borderWidth=1;
        self.codeBtn.layer.borderColor = [UIColor blackColor].CGColor;
        [self.codeBtn setBackgroundImage:[UIImage imageNamed:@"btn_confirm_disable"] forState:UIControlStateDisabled];
        [self.codeBtn setBackgroundImage:[UIImage imageNamed:@"btn_confirm_normal"] forState:UIControlStateNormal];
    }
    return _codeBtn;
}
- (UITextField *)passwordTextField{
    if (!_passwordTextField) {
        self.passwordTextField = [[UITextField alloc]init];
        self.passwordTextField.delegate=self;
        self.passwordTextField.placeholder=@"请输入密码";
        self.passwordTextField.secureTextEntry=YES;
        self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
        UIImageView *passwordImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [passwordImageView setImage:[UIImage imageNamed:@"person"]];
        self.passwordTextField.leftView=passwordImageView;
        self.passwordTextField.leftViewMode=UITextFieldViewModeAlways;
    }
    return _passwordTextField;
}
- (UITextField *)twicePasswordTectfield{
    if (!_twicePasswordTectfield) {
        self.twicePasswordTectfield = [[UITextField alloc]init];
        self.twicePasswordTectfield.delegate=self;
        self.twicePasswordTectfield.placeholder=@"请再次输入密码";
        self.twicePasswordTectfield.secureTextEntry=YES;
        self.twicePasswordTectfield.borderStyle = UITextBorderStyleRoundedRect;
        UIImageView *twiceImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [twiceImageView setImage:[UIImage imageNamed:@"person"]];
        self.twicePasswordTectfield.leftView=twiceImageView;
        self.twicePasswordTectfield.leftViewMode=UITextFieldViewModeAlways;
    }
    return _twicePasswordTectfield;
}
- (UITextField *)inviteTextField{
    if (!_inviteTextField) {
        self.inviteTextField = [[UITextField alloc]init];
        self.inviteTextField.placeholder = @"请输入邀请码(选填)";
        self.inviteTextField.borderStyle=UITextBorderStyleRoundedRect;
        self.inviteTextField.delegate=self;
    }
    return _inviteTextField;
}
- (UIButton *)commitBtn{
    if (!_commitBtn) {
        self.commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.commitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [self.commitBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.commitBtn.layer setBorderColor:[UIColor blackColor].CGColor];
        [self.commitBtn.layer setCornerRadius:4.0f];
        [self.commitBtn.layer setBorderWidth:1];
    }
    return _commitBtn;
}
#pragma mark --UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(75, 0, 0, 0));
    }];
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(75, 0, 0, 0));
    }];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _inviteTextField) {
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
    return YES;
}
- (void)addViews{
    [self.view addSubview:self.backView];
    [_backView addSubview:self.userPhoneTextField];
    [_backView addSubview:self.passwordTextField];
    [_backView addSubview:self.codeTextField];
    [_backView addSubview:self.codeBtn];
    [_backView addSubview:self.twicePasswordTectfield];
    [_backView addSubview:self.inviteTextField];
    [_backView addSubview:self.commitBtn];
}
- (void)createUI{
    int  leftpadding = 20;
    int   bottomPadding = 10;
    int viewHeight = 40;
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(75, 0, 0, 0));
    }];
    
    //手机号
    [self.userPhoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backView).with.offset(0);
        make.left.equalTo(self.backView).with.offset(leftpadding);
        make.right.equalTo(self.backView).with.offset(-leftpadding);
        make.height.mas_equalTo(viewHeight);
    }];
    //验证码
    [self.codeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userPhoneTextField.mas_bottom).with.offset(bottomPadding);
        make.left.equalTo(self.backView).with.offset(leftpadding);
        make.right.equalTo(self.codeBtn.mas_left).with.offset(-bottomPadding);
        make.height.mas_equalTo(viewHeight);
    }];
    [self.codeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userPhoneTextField.mas_bottom).offset(bottomPadding);
        make.right.equalTo(self.backView).offset(-leftpadding);
        make.left.equalTo(self.codeTextField.mas_right).offset(bottomPadding);
        make.height.mas_equalTo(viewHeight);
    }];
    //请输入密码
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(leftpadding);
        make.right.equalTo(self.backView).offset(-leftpadding);
        make.top.equalTo(self.codeTextField.mas_bottom).offset(bottomPadding);
        make.height.mas_equalTo(viewHeight);
    }];
    //再次输入密码
    [self.twicePasswordTectfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextField.mas_bottom).offset(bottomPadding);
        make.left.equalTo(self.backView).offset(leftpadding);
        make.right.equalTo(self.backView).offset(-leftpadding);
        make.height.mas_equalTo(viewHeight);
    }];
    //邀请码
    [self.inviteTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.twicePasswordTectfield.mas_bottom).with.offset(bottomPadding);
        make.left.equalTo(self.backView).with.offset(leftpadding);
        make.right.equalTo(self.backView).with.offset(-leftpadding);
        make.height.mas_equalTo(viewHeight);
    }];
    //提交按钮
    [self.commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(2*leftpadding);
        make.right.equalTo(self.backView).offset(-2*leftpadding);
        make.top.equalTo(self.inviteTextField.mas_bottom).offset(bottomPadding);
        make.height.mas_equalTo(viewHeight);
    }];
}
- (void)createAlterWithTitle:(NSString *)title{
    UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:title delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alterView show];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end






























