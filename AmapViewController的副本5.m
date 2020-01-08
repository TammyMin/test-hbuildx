//
//  ViewController+AmapViewController.m
//  redcity
//
//  Created by tammy on 2017/12/4.
//  Copyright © 2017年 tammy. All rights reserved.
//

#import "AmapViewController.h"
#import "CustomAnnotationView.h"

extern NSString *locationInfo;//获取省份城市
extern NSString *locationDetailAddress;
extern double startlatitude;
extern double startlongitude;
extern int isNavigation;
extern int SelectCoordinate;
extern float lookDistance;//用户可见距离
@interface AmapViewController ()<MAMapViewDelegate, AMapLocationManagerDelegate,CustomAnnotaionViewDelegate,AMapSearchDelegate>
@property (nonatomic, strong) UIButton *gpsButton;
@property (nonatomic, strong) NSMutableArray *routeIndicatorInfoArray;
@end

@implementation AmapViewController
static AmapViewController *amapVC;
+(AmapViewController*) shareSingleController{
    //可用id代替返回可用的指针对象 instance是方法名
  //静态变量,生命周期是整个程序，在下一次该函数调用时仍可使用
    if(amapVC==nil ) {
        //指针为空就创建
        amapVC = [[AmapViewController alloc] init];
    //指针st指向单例模式 Singleton
}
return amapVC;//不是空就继续使用
}
#pragma mark life code
- (void)viewDidLoad {
    [super viewDidLoad];
     NSLog(@"viewDidLoad");
   // _merchantRedPacket = [[NSArray alloc]init];

     [self InitAMap];
    [self initButton];
//
    
}
- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidApper:%lu",_merchantRedPacket.count);
  
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}
- (void)dealloc
{

    NSLog(@"单例是否销毁成功.....dealloc");
    if (self._mapView !=nil) {
        [self._mapView removeFromSuperview];
        self._mapView.delegate = nil;

    }
   
}


#pragma mark AmapViewDelegate

- (void)mapInitComplete:(MAMapView *)mapView
{
   //  [self._mapView reloadMap];
   
}
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MACircle class]])
    {
        if (SelectCoordinate ==0) {
         
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        circleRenderer.lineWidth    = 2.f;
        circleRenderer.strokeColor  = [UIColor whiteColor];
        circleRenderer.fillColor    = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        return circleRenderer;
        }
    }
    return nil;
}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return NULL;
    }
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *customReuseIndetifier = @"annotationReuseIndetifier";
        CustomAnnotationView *annotationView = (CustomAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
            // must set to NO, so we can show the custom callout view.
            if (SelectCoordinate == 1) {
                annotationView.draggable = YES;
            }
            else
            {
                annotationView.draggable = NO;
            }
            annotationView.canShowCallout = NO;
            annotationView.calloutOffset = CGPointMake(0,0);
        }
        annotationView.delegate = self;
        if (SelectCoordinate == 1) {
            annotationView.portrait = [UIImage imageNamed:@"ic_launcher"] ;
        }
        else
        {
            annotationView.portrait = [UIImage imageNamed:@"hongbao"];
//            for (int i = 0; i < _merchantRedPacket.count -1; i++) {
//                NSString *tempData = _merchantRedPacket[i];
//                NSArray *dataArray = [tempData componentsSeparatedByString:@","];
//
//                if ([annotation.title isEqualToString:[NSString stringWithFormat:@"%@,%@,%@,%@",dataArray[3],dataArray[4],dataArray[0],dataArray[1]]] ) {
//                    annotationView.name =[NSString stringWithFormat:@"%@%@",dataArray[2],@"个"];
//                }
//            }
      
        
        annotationView.centerOffset = CGPointMake(0, -0.5*annotationView.portrait.size.height);
             }
        return annotationView;
    }
    return nil;
}
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view;
{
    if (SelectCoordinate == 0) {
        
        NSLog(@"距离%f",[self GetDisX:view.annotation.coordinate.latitude GetDisY:view.annotation.coordinate.longitude]);
        if ([self GetDisX:view.annotation.coordinate.latitude GetDisY:view.annotation.coordinate.longitude] > (lookDistance/2)) {
            // 初始化对话框
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message: [NSString stringWithFormat:@"当前您的可见距离%d米,赶紧分享好友扩张距离吧！",(int)lookDistance ] preferredStyle:UIAlertControllerStyleAlert];
            // 确定注销
            _okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                
                [self SendUnityCallBack:@"OpenShared" Parameter:@""];
            }];
            _cancelAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
                
            }];
            
            [alert addAction:_okAction];
            [alert addAction:_cancelAction];
            // 弹出对话框
            [self presentViewController:alert animated:true completion:nil];
        }
        else
        {

           
            for (int i = 0;i<self.showRedPacketArray.count; i++) {
                NSString *tempData = self.showRedPacketArray[i];
                NSArray *dataArray = [tempData componentsSeparatedByString:@","];
                NSArray *annotationArray = [view.annotation.title componentsSeparatedByString:@","];
                if ([dataArray[4] isEqualToString:annotationArray[4]] &&
                    [dataArray[5] isEqualToString:annotationArray[5]]) {
                     [self.showRedPacketArray removeObjectAtIndex:i];
                    NSLog(@"remove AnnotationView....%@,.....showredpacketarray count:%lu",view.annotation.title,self.showRedPacketArray.count);
                }
            }
 //         NSArray *annotationArray = [view.annotation.title componentsSeparatedByString:@","];
//            NSString* latitude =[NSString stringWithFormat:@"%@", annotationArray[2]];
//            NSString* latitudeTemp = [latitude substringFromIndex:latitude.length-1];
//            if ([latitudeTemp isEqualToString:@"0"]) {
//                latitude = [latitude substringToIndex:latitude.length-1];
//            }
//
//            NSString*  longitude =[NSString stringWithFormat:@"%@", annotationArray[3]];
//            NSString* longitudeTemp = [longitude substringFromIndex:longitude.length-1];
//            if ([longitudeTemp isEqualToString:@"0"]) {
//                longitude = [longitude substringToIndex:longitude.length-1];
//            }
            NSLog(@"didSelectAnnotationView....%@",view.annotation.title);
            [self playButtonSound];
            [self SendUnityCallBack:@"Recivier_MarkerClick" Parameter:view.annotation.title];
            if (self._mapView != NULL) {
                [self._mapView removeAnnotations:self._mapView.annotations];
                
            }
        }
    }
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState
   fromOldState:(MAAnnotationViewDragState)oldState
{
    if (newState == MAAnnotationViewDragStateEnding) {
          NSLog(@"didChangeDragState...end.%f...%f",view.annotation.coordinate.latitude,view.annotation.coordinate.longitude);
//        NSString* latitude =[NSString stringWithFormat:@"%f", view.annotation.coordinate.latitude];
//        NSString* latitudeTemp = [latitude substringFromIndex:latitude.length-1];
//        if ([latitudeTemp isEqualToString:@"0"]) {
//            latitude = [latitude substringToIndex:latitude.length-1];
//        }
//
//        NSString*  longitude =[NSString stringWithFormat:@"%f",  view.annotation.coordinate.longitude];
//        NSString* longitudeTemp = [longitude substringFromIndex:longitude.length-1];
//        if ([longitudeTemp isEqualToString:@"0"]) {
//            longitude = [longitude substringToIndex:longitude.length-1];
//        }

        self.selectAddressCoordinate = [NSString stringWithFormat:@"%f,%f",view.annotation.coordinate.latitude,view.annotation.coordinate.longitude];
        AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
        
        regeo.location  = [AMapGeoPoint locationWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
        regeo.requireExtension            = YES;
        [self.search AMapReGoecodeSearch:regeo];
    }
    
}
/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        //解析response获取地址描述，具体解析见 Demo
        NSLog(@"regeocode.....%@%@%@",response.regeocode.addressComponent.province,response.regeocode.addressComponent.city,response.regeocode.addressComponent.district);
        self.selectAddress =[NSString stringWithFormat:@"%@%@%@",response.regeocode.addressComponent.province,response.regeocode.addressComponent.city,response.regeocode.addressComponent.district];
        self.selectDetailAddress = response.regeocode.formattedAddress;
    }
}
-(float) GetDisX:(double) x GetDisY:(double) y
{
    MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(x,y));
    MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(startlatitude,startlongitude));
    
    //2.计算距离
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
    return distance;
}
//初始化按钮
-(void)initButton
{
   
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.cancelBtn setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    // 将frame的位置大小复制给Button
    self.cancelBtn.frame = CGRectMake(10.0f, 10.0f, 50, 48);;
    [self.cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancelbtn"] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(OnClickCancelBtn:)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelBtn];
    //设置按钮类型，此处为圆角按钮
    self.userBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.userBtn setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    // 将frame的位置大小复制给Button
    self.userBtn.frame = CGRectMake(10.0f, 10.0f, 70, 75);
    [self.userBtn setBackgroundImage:[UIImage imageNamed:@"userbtn"] forState:UIControlStateNormal];
    [self.userBtn addTarget:self action:@selector(OnClickUserBtn:)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.userBtn];
    //设置按钮类型，此处为圆角按钮
    self.scanBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.scanBtn setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    // 将frame的位置大小复制给Button
    self.scanBtn.frame = CGRectMake(10.0f,[[UIScreen mainScreen] bounds].size.height-90, 80, 85);
    [self.scanBtn setBackgroundImage:[UIImage imageNamed:@"scanbtn"] forState:UIControlStateNormal];
    [self.scanBtn addTarget:self action:@selector(OnClickScanBtn:)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scanBtn];
    //设置按钮类型，此处为圆角按钮
    self.redpacketBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.redpacketBtn setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    // 将frame的位置大小复制给Button
    self.redpacketBtn.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width-90, [[UIScreen mainScreen] bounds].size.height-90, 80, 85);
    [self.redpacketBtn setBackgroundImage:[UIImage imageNamed:@"redpacketbtn"] forState:UIControlStateNormal];
    [self.redpacketBtn addTarget:self action:@selector(OnClickRedPacketBtn:)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.redpacketBtn];
    
}
-(void)OnClickCancelBtn:(id)sender
{
    if (self.selectAddressCoordinate==nil) {
//        NSString* latitude =[NSString stringWithFormat:@"%f", startlatitude];
//        NSString* latitudeTemp = [latitude substringFromIndex:latitude.length-1];
//        if ([latitudeTemp isEqualToString:@"0"]) {
//            latitude = [latitude substringToIndex:latitude.length-1];
//        }
//
//        NSString*  longitude =[NSString stringWithFormat:@"%f",  startlongitude];
//        NSString* longitudeTemp = [longitude substringFromIndex:longitude.length-1];
//        if ([longitudeTemp isEqualToString:@"0"]) {
//            longitude = [longitude substringToIndex:longitude.length-1];
//        }
        self.selectAddressCoordinate = [NSString stringWithFormat:@"%f,%f",startlatitude,startlongitude];
        
    }
    if (self.selectAddress == nil) {
        self.selectAddress = locationInfo;
    }
    if (self.selectDetailAddress ==nil) {
        self.selectDetailAddress =locationDetailAddress;
    }
    NSLog(@"selectCoordinate:%@,%@,%@",self.selectAddressCoordinate,self.selectAddress,self.selectDetailAddress);
     [self SendUnityCallBack:@"Recivier_SelectCoordinate" Parameter:[NSString stringWithFormat:@"%@,%@,%@",self.selectAddressCoordinate,self.selectAddress,self.selectDetailAddress]];
    if (self._mapView != NULL) {
        [self._mapView removeAnnotations:self._mapView.annotations];
        
    }
    self.selectAddressCoordinate = nil;
    self.selectAddress = nil;
    self.selectDetailAddress = nil;
    
}
-(void)OnClickRedPacketBtn:(id)sender
{

  [self SendUnityCallBack:@"Recivier_ClickBtn" Parameter:@"redpacketBtn"];
}
-(void) OnClickUserBtn:(id)sender
{
  [self SendUnityCallBack:@"Recivier_ClickBtn" Parameter:@"userBtn"];
}
-(void) OnClickScanBtn:(id)sender
{
    [self SendUnityCallBack:@"Recivier_ClickBtn" Parameter:@"scanBtn"];
}
-(void) SendUnityCallBack:(NSString*) FunName Parameter:(NSString*) parameter
{
    [self playButtonSound];
    UnityPause(false);
// [self dismissViewControllerAnimated:YES completion:nil];
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.view setFrame:CGRectMake( self.view.frame.size.width, 0 , self.view.frame.size.width, self.view.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         
                         NSLog(@"单例是否销毁成功");
//                         if(self._mapView != nil)
//                         {
//                             [self._mapView removeFromSuperview];
//                             self._mapView.delegate = nil;
//                             self._mapView = nil;
//                         }
//                           [self.view removeFromSuperview];
//                         self.view = nil;
                         
                         UnitySendMessage("GameManager",[FunName UTF8String],[parameter UTF8String]);
                         
                     }];
}
//初始化地图
-(void) InitAMap
{
    // Do any additional setup after loading the view, typically from a nib.
    ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
    [AMapServices sharedServices].enableHTTPS = YES;
    
        ///初始化地图
        self._mapView  = [[MAMapView alloc] initWithFrame:self.view.bounds];
    
   
    ///初始化地图
    self._mapView  = [[MAMapView alloc] initWithFrame:self.view.bounds];
    
     self._mapView.zoomEnabled = YES;
    //普通样式
     self._mapView.mapType = MAMapTypeStandard;
    //地图跟着位置移动
    [ self._mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    //设置成NO表示关闭指南针；YES表示显示指南针
     self._mapView.showsCompass= NO;
    //设置成NO表示不显示比例尺；YES表示显示比例尺
     self._mapView.showsScale= NO;
    self._mapView.compassOrigin = CGPointMake(self._mapView.compassOrigin.x, 22);
    self._mapView.scaleOrigin = CGPointMake(self._mapView.scaleOrigin.x, 22);
    //缩放等级
    [ self._mapView setZoomLevel:16 animated:NO];
    [self._mapView setMinZoomLevel:12];
    [self._mapView setMaxZoomLevel:19];
    [self._mapView setCameraDegree:45];
 
       //开启定位
       self._mapView.showsUserLocation = YES;

    self._mapView.delegate = self;
    
    self._mapView.customMapStyleEnabled = YES;
    NSString *path = [NSString stringWithFormat:@"%@/mystyle_sdk.data", [NSBundle mainBundle].bundlePath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [self._mapView setCustomMapStyleWithWebData:data];
    
    ///把地图添加至view
    [self.view addSubview: self._mapView];
    //构造圆
    self.maCircle = [MACircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(startlatitude, startlongitude) radius:lookDistance/2];
    
    //在地图上添加圆
    [self._mapView addOverlay: self.maCircle];
    self.gpsButton = [self makeGPSButtonView];
    self.gpsButton.center = CGPointMake( self.view.bounds.size.width -  CGRectGetMidX(self.gpsButton.bounds) - 20,
                                         CGRectGetMidY(self.gpsButton.bounds) + 10);
    [self.view addSubview:self.gpsButton];
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
}
//定位按钮
- (UIButton *)makeGPSButtonView {
    UIButton *ret = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    ret.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    ret.layer.cornerRadius = 4;
    
    [ret setImage:[UIImage imageNamed:@"gpsStat1"] forState:UIControlStateNormal];
    [ret addTarget:self action:@selector(gpsAction) forControlEvents:UIControlEventTouchUpInside];
    
    return ret;
}
//点击定位按钮定位到当前位置
- (void)gpsAction {
    if(self._mapView.userLocation.updating && self._mapView.userLocation.location) {
        [self._mapView setCenterCoordinate:self._mapView.userLocation.location.coordinate animated:YES];
        [self.gpsButton setSelected:YES];
    }
}
#pragma mark - 弹出对话框
- (void) popUpWindow {
   
    // 初始化对话框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message: [NSString stringWithFormat:@"请进入以下商家扫描商家二维码\n商家名称:%@\n商家地址:%@",self.merchantName,self.merchantAddress] preferredStyle:UIAlertControllerStyleAlert];
    // 确定注销
    _okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        
        UnitySendMessage("GameManager", "RecivierEnterGameScene", "");
       
      //  [self buttonClicked:nil];
    }];
    _cancelAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
        if (isNavigation== 1) {
         //   [self buttonClicked:nil];
        }
    }];
    
    [alert addAction:_okAction];
    [alert addAction:_cancelAction];
    
    // 弹出对话框
    [self presentViewController:alert animated:true completion:nil];
}
-(void)setMerchantRedPacket:(NSArray*)dataArray
{
   
    if (SelectCoordinate == 0) {
      
        _merchantRedPacket = [[NSArray alloc]init];
//        _merchantRedPacket = [NSArray arrayWithObjects:@"22.588092,113.957602,1,111111111,1",
//                              @"22.587894,113.957474,3,111111112,1",
//                              @"22.587735,113.95816,7,oPY-H0TVSATrQ_lxM75aOA5rlfMI,2",
//                              @"22.587735,113.95816,3,oPY-H0TVSATrQ_lxM75aOA5rlfMI1,2",
//                              @"22.587735,113.95816,5,oPY-H0TVSATrQ_lxM75aOA5rlfMI,2"
//                              ,nil];
       
        _merchantRedPacket = dataArray;
         NSLog(@"_merchantRedPacket Count:%lu",_merchantRedPacket.count);
        [self.cancelBtn setHidden:YES];
        [self.userBtn setHidden:NO];
        [self.scanBtn setHidden:NO];
        [self.redpacketBtn setHidden:NO];
        if (self.maCircle!=NULL) {
            [self.maCircle setRadius:lookDistance/2];
            [self.maCircle setCoordinate:CLLocationCoordinate2DMake(startlatitude, startlongitude)];
        }
        if (_merchantRedPacket.count == 0) {
            return;
        }
    }
    else
    {
        if (self._mapView != NULL) {
            [self._mapView removeAnnotations:self._mapView.annotations];
        }
        [self.cancelBtn setHidden:NO];
        [self.userBtn setHidden:YES];
        [self.scanBtn setHidden:YES];
        [self.redpacketBtn setHidden:YES];
        [self.maCircle setRadius:0];
    }
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [self addMarker];
    });
    
}
-(void) addMarker
{
    if (SelectCoordinate == 1) {
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
            pointAnnotation.coordinate = CLLocationCoordinate2DMake(startlatitude,startlongitude);
            [self._mapView addAnnotation:pointAnnotation];
        
        return;
    }
//    for (int i = 0; i <_merchantRedPacket.count -1; i++) {
//        NSString *tempData = _merchantRedPacket[i];
//        NSArray *dataArray = [tempData componentsSeparatedByString:@","];
//        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
//        if ([dataArray[2] intValue] >0) {
//            pointAnnotation.coordinate = CLLocationCoordinate2DMake([dataArray[0] doubleValue], [dataArray[1] doubleValue]);
//            NSLog(@"count:%@",dataArray[2]);
//            pointAnnotation.title =[NSString stringWithFormat:@"%@,%@,%@,%@",dataArray[3],dataArray[4],dataArray[0],dataArray[1]];
//            [self._mapView addAnnotation:pointAnnotation];
//
//        }
//    }
    [self SetMarker];
}
-(void)SetMarker
{
    if (self.showRedPacketArray.count != 0) {
        for (int i = 0; i<self.showRedPacketArray.count; i++) {
             NSArray *dataArray = [self.showRedPacketArray[i] componentsSeparatedByString:@","];
            MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
            pointAnnotation.coordinate = CLLocationCoordinate2DMake([dataArray[4] doubleValue], [dataArray[5] doubleValue]);
            pointAnnotation.title =self.showRedPacketArray[i];
             [self._mapView addAnnotation:pointAnnotation];
        }
        return;
    }
   
    self.nearMerchantArray = [NSMutableArray arrayWithCapacity:50];
     self.nearUserRedPacketArray = [NSMutableArray arrayWithCapacity:50];
    self.showRedPacketArray = [NSMutableArray arrayWithCapacity:20];
    int nearMerchantRedPacketCount = 0;
    int nearUserRedPacketCount = 0;
    int redPacketCount = 0;
    int currentShowMarker = 0;
    int showMarkerCount= 20;
    for (int i = 0; i<_merchantRedPacket.count-1; i++) {
        NSString *tempData = _merchantRedPacket[i];
        NSArray *dataArray = [tempData componentsSeparatedByString:@","];
        if ([self GetDisX:[dataArray[0] doubleValue] GetDisY:[dataArray[1] doubleValue]] < (lookDistance/2)) {
            if ([dataArray[4] intValue] == 1) {
                if (self.nearMerchantArray.count <50) {
                    [self.nearMerchantArray addObject:tempData];
                    nearMerchantRedPacketCount = nearMerchantRedPacketCount+ [dataArray[2] intValue];
                }
            }
            else
            {
                
                if (![dataArray[3] isEqual:@"oPY-H0TVSATrQ_lxM75aOA5rlfMI"]) {
                    if (self.nearMerchantArray.count <50) {
                        [self.nearMerchantArray addObject:tempData];
                        nearMerchantRedPacketCount = nearMerchantRedPacketCount+ [dataArray[2] intValue];
                    }
                }
                else
                {
                    if (self.nearUserRedPacketArray.count <50) {
                        [self.nearUserRedPacketArray addObject:tempData];
                        nearUserRedPacketCount = nearUserRedPacketCount+ [dataArray[2] intValue];
                    }
                }
            }
        }
        else
        {
            if ([dataArray[3] isEqual:@"oPY-H0TVSATrQ_lxM75aOA5rlfMI"]) {
                if (self.nearUserRedPacketArray.count <50) {
                    [self.nearUserRedPacketArray addObject:tempData];
                    nearUserRedPacketCount = nearUserRedPacketCount+ [dataArray[2] intValue];
                }
            }
        }
    }
    NSLog(@"nearMerchantArray count:%lu....redpacketCount:%d",self.nearMerchantArray.count,nearMerchantRedPacketCount);
    NSLog(@"nearUserRedpacket Count:%lu....userRedpacketCount:%d",self.nearUserRedPacketArray.count,nearUserRedPacketCount);
    int indexCount =0;
    if (nearMerchantRedPacketCount != 0) {
        indexCount =self.nearMerchantArray.count <=20? 20/ self.nearMerchantArray.count:1;
        redPacketCount =(int) self.nearMerchantArray.count;
    }
    for (int i = 0; i< indexCount; i++) {
        for (int j = 0; j<redPacketCount; j++) {
            if (currentShowMarker <showMarkerCount && currentShowMarker <nearMerchantRedPacketCount) {
                double lat = 0;
                double lng = 0;
                float fdis = 0.000005f;
                
                int i = arc4random() % 4 ;
                NSString * strLat = [NSString stringWithFormat:@"%f",startlatitude];
                strLat = [strLat substringFromIndex:strLat.length - 3];
                
                NSString * strLng = [NSString stringWithFormat:@"%f",startlongitude];
                strLng = [strLng substringFromIndex:strLng.length - 3];
               
                int randomLat =(arc4random()%[strLat intValue]);
                int randomLng = (arc4random()%[strLng intValue]);
                
                switch (i) {
                    case 0:
                        lat = startlatitude +randomLat*fdis;
                        lng = startlongitude+randomLng*fdis;
                        break;
                    case 1:
                        lat = startlatitude -randomLat*fdis;
                        lng = startlongitude-randomLng*fdis;
                        break;
                    case 2:
                        lat = startlatitude +randomLat*fdis;
                        lng = startlongitude-randomLng*fdis;
                        break;
                    case 3:
                        lat = startlatitude -randomLat*fdis;
                        lng = startlongitude+randomLng*fdis;
                        break;
                        
                }
                if ([self GetDisX:lat GetDisY:lng] < (lookDistance/2)) {
                    int randIndex = arc4random() % redPacketCount ;
                    NSArray *arr =[self.nearMerchantArray[randIndex] componentsSeparatedByString:@","];
                    if ([arr[2] intValue] >= indexCount) {
                        
                        currentShowMarker++;
//                        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
//                        pointAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lng);
                        
                        // NSLog(@"point:%@,%@",arr[0],arr[1]);
//                        pointAnnotation.title =[NSString stringWithFormat:@"%@,%@,%@,%@,%@",arr[3],arr[4],arr[0],arr[1],[NSString stringWithFormat:@"%f,%f",lat,lng]];
//                        [self._mapView addAnnotation:pointAnnotation];
                        [self.showRedPacketArray addObject:[NSString stringWithFormat:@"%@,%@,%@,%@,%@",arr[3],arr[4],arr[0],arr[1],[NSString stringWithFormat:@"%f,%f",lat,lng]]];
                    }
                }
            }
        }
    }
     NSLog(@"showredPacketarray 1 count:%lu",self.showRedPacketArray.count);
    if (self.showRedPacketArray.count >=20) {
        int userRedpacketcount = nearUserRedPacketCount;
        if (userRedpacketcount >=10) {
            userRedpacketcount = 10;
        }
        for (int i = 0; i <userRedpacketcount; i++) {
            currentShowMarker--;
            [self.showRedPacketArray removeLastObject];
        
        }
    }
    NSLog(@"showredPacketarray 2 count:%lu",self.showRedPacketArray.count);
    //oPY-H0TVSATrQ_lxM75aOA5rlfMI
    if (self.showRedPacketArray.count >=10&& self.showRedPacketArray.count <20) {
        if (self.nearUserRedPacketArray.count != 0) {
            for (int i = 0; i <nearUserRedPacketCount; i ++) {
                 NSArray *dataArray = [self.nearUserRedPacketArray[ arc4random() % self.nearUserRedPacketArray.count] componentsSeparatedByString:@","];
                for (int j = 0 ; j< 1; j++) {
                    if (currentShowMarker <showMarkerCount) {
                        double lat = 0;
                        double lng = 0;
                        float fdis = 0.000005f;
                        
                        int i = arc4random() % 4 ;
                        NSString * strLat = [NSString stringWithFormat:@"%f",startlatitude];
                        strLat = [strLat substringFromIndex:strLat.length - 3];
                       // NSLog(@"%@",strLat);
                        NSString * strLng = [NSString stringWithFormat:@"%f",startlongitude];
                        strLng = [strLng substringFromIndex:strLng.length - 3];
                      //  NSLog(@"%@",strLng);
                        int randomLat =(arc4random()%[strLat intValue]);
                        int randomLng = (arc4random()%[strLng intValue]);
                        
                        switch (i) {
                            case 0:
                                lat = startlatitude +randomLat*fdis;
                                lng = startlongitude+randomLng*fdis;
                                break;
                            case 1:
                                lat = startlatitude -randomLat*fdis;
                                lng = startlongitude-randomLng*fdis;
                                break;
                            case 2:
                                lat = startlatitude +randomLat*fdis;
                                lng = startlongitude-randomLng*fdis;
                                break;
                            case 3:
                                lat = startlatitude -randomLat*fdis;
                                lng = startlongitude+randomLng*fdis;
                                break;
                                
                        }
                        if ([self GetDisX:lat GetDisY:lng] < (lookDistance/2)) {
                            currentShowMarker++;
                           // MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
                           // pointAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lng);
                            
                           // pointAnnotation.title =[NSString stringWithFormat:@"%@,%@,%@,%@,%@",dataArray[3],dataArray[4],dataArray[0],dataArray[1],[NSString stringWithFormat:@"%f,%f",lat,lng]];
                           // [self._mapView addAnnotation:pointAnnotation];
                            [self.showRedPacketArray addObject:[NSString stringWithFormat:@"%@,%@,%@,%@,%@",dataArray[3],dataArray[4],dataArray[0],dataArray[1],[NSString stringWithFormat:@"%f,%f",lat,lng]]];
                        }
                    }
                }
            }
        }
    }
    else if (self.showRedPacketArray.count <10)
    {
        
        if (self.showRedPacketArray.count > nearUserRedPacketCount) {
            showMarkerCount =(int)self.showRedPacketArray.count +nearUserRedPacketCount;
        }
        else
        {
            showMarkerCount =(int)self.showRedPacketArray.count *2;
        }
        for (int i = 0; i <nearUserRedPacketCount; i ++) {
            NSArray *dataArray = [self.nearUserRedPacketArray[ arc4random() % self.nearUserRedPacketArray.count] componentsSeparatedByString:@","];
            for (int j = 0 ; j< 1; j++) {
                if (currentShowMarker <showMarkerCount) {
                    double lat = 0;
                    double lng = 0;
                    float fdis = 0.000005f;
                    
                    int i = arc4random() % 4 ;
                    NSString * strLat = [NSString stringWithFormat:@"%f",startlatitude];
                    strLat = [strLat substringFromIndex:strLat.length - 3];
                    // NSLog(@"%@",strLat);
                    NSString * strLng = [NSString stringWithFormat:@"%f",startlongitude];
                    strLng = [strLng substringFromIndex:strLng.length - 3];
                    //  NSLog(@"%@",strLng);
                    int randomLat =(arc4random()%[strLat intValue]);
                    int randomLng = (arc4random()%[strLng intValue]);
                    
                    switch (i) {
                        case 0:
                            lat = startlatitude +randomLat*fdis;
                            lng = startlongitude+randomLng*fdis;
                            break;
                        case 1:
                            lat = startlatitude -randomLat*fdis;
                            lng = startlongitude-randomLng*fdis;
                            break;
                        case 2:
                            lat = startlatitude +randomLat*fdis;
                            lng = startlongitude-randomLng*fdis;
                            break;
                        case 3:
                            lat = startlatitude -randomLat*fdis;
                            lng = startlongitude+randomLng*fdis;
                            break;
                            
                    }
                    if ([self GetDisX:lat GetDisY:lng] < (lookDistance/2)) {
                        currentShowMarker++;
                       // MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
                       // pointAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lng);
                        
                       // pointAnnotation.title =[NSString stringWithFormat:@"%@,%@,%@,%@,%@",dataArray[3],dataArray[4],dataArray[0],dataArray[1],[NSString stringWithFormat:@"%f,%f",lat,lng]];
                       // [self._mapView addAnnotation:pointAnnotation];
                        [self.showRedPacketArray addObject:[NSString stringWithFormat:@"%@,%@,%@,%@,%@",dataArray[3],dataArray[4],dataArray[0],dataArray[1],[NSString stringWithFormat:@"%f,%f",lat,lng]]];
                    }
                }
            }
        }
    }
    NSLog(@"showRedPacketArray 3 count:%lu",self.showRedPacketArray.count);
    if (self.showRedPacketArray.count != 0) {
        for (int i = 0; i<self.showRedPacketArray.count; i++) {
            NSArray *dataArray = [self.showRedPacketArray[i] componentsSeparatedByString:@","];
            MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
            pointAnnotation.coordinate = CLLocationCoordinate2DMake([dataArray[4] doubleValue], [dataArray[5] doubleValue]);
            pointAnnotation.title =self.showRedPacketArray[i];
            [self._mapView addAnnotation:pointAnnotation];
        }
        
    }
    NSLog(@"annotation count:%lu",self._mapView.annotations.count);
}
-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to-from + 1)));
}

- (void)merchantName:(NSString*)name merchantAddress:(NSString*)address
{
    self.merchantName = name;
    self.merchantAddress = address;
}
-(void)setMapCenter:(CLLocationCoordinate2D)value
{
    [self._mapView setCenterCoordinate:value animated:YES];
}
- (void)StartWalkRoute:(CLLocationCoordinate2D )value
{
    
}
-(void)playButtonSound
{
    self.playerSound = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle]URLForResource:@"click.mp3" withExtension:nil] error:nil];//使用本地URL创建
    self.playerSound.volume = 0.3f;
    [self.playerSound prepareToPlay];
    [self.playerSound play];
}
@end
