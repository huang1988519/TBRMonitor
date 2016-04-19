# TBRMonitor

iOS App 性能监控（内存、电量、网络预警）

---

## Usage
**Objective-c**
```
@interface AppDelegate () <TBRMonitorDelegate>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [TBRMonitor startMonotorWithDelegate:self];
    return YES;
}
```  

然后实现 TBRMonitorDelegate 监听数据

```
-(void)applicationRecieveBadUrl:(NSDictionary *)dic {
    NSLog(@"bad url : %@",dic);
}
- (void)applicationMemoryUsed:(float)usedSpace free:(float)freeSpace {
    NSLog(@"used: %f    free: %f",usedSpace, freeSpace);
}
-(void)applicationElectricityChanged:(float)level {
    NSLog(@"current electricity: %f",level);

}
```
---
## 主要功能

**Request**

通过集成 NSURLProtocol 协议，覆盖协议中的方法，以实现拦截App中的网络请求  

已实现功能：
* 监测 失败URL ，并通知 " < TBRMonitorDelegate>"  
* 统计失败、成功 Request 个数
* 本地URL 日志文件，路径为  
  * Debug   -> /Documents/Record.txt
  * Release -> /Documents/.Record.txt

* 通过在main bundle创建 Host.plist ,root类型为 NSArray ，监听指定 `host

缺失功能：
* 到达率
* 网络延迟分析
* ip地址解析



**Memory**

已实现功能:
* 一帧每秒，快照memory使用情况，并 ```-(void)applicationMemoryUsed:(float)usedSpace free:(float)freeSpace;
``` used 和 free 空间，已  ```kb``` 为单位

**电量使用情况**

* 手机电量使用状况。刷新时机为“每当电量有变化时才会通知”。代理方法为``-(void)applicationElectricityChanged:(float)level;
 ``


**CPU使用**

* 明天加上。。。


**UI 绘制**
* Window 绘制监控数据


---


## Install

#### manual （不推荐）
 * 拖动 TBRMonitorFramework 文件夹到 工程所在文件夹，然后可以引入源文件，也可以使用工程生成framework使用
 * import <TBRMonitor.h>

#### Cocoapods  
* 安装cocoapods
* 在Podfile文件添加 TBRMonitor
    ```
    pod 'TBRMonitor', :git => 'https://github.com/huang1988519/TBRMonitor.git'

    ```   
    因为是在测试阶段，不对外公开，暂时不会支持pod ```search TBRMonitor```   

*  ``` pod update --no-repo-update ```  
*  ``` import <TBRMonitor.h>```

等待完成。等待loading结束，集成成功。  
#### carthage
* 创建 Cartfile
* 编辑 Cartfile -> 插入 ```github  "huang1988519/TBRMonitor"```
* ```carthage update```
* embedded Carthage/Build/iOS/TBRMonitorFramework.framework 到你的target


## 生成Api文档：
```
> chmod +x GenerateDocument.sh
> /GenerateDocument.sh
...
input company name
input company id
input project name
input "is generate xcode docs" yes/other
generate...
sucess!
```

> 如果使用过程中有问题，请发邮件 huang1988519@126.com
