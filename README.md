# iOS 蓝牙开发CoreBluetooth 


## 简介
 iOS 蓝牙开发基本说明:
 简易流程: 搜索蓝牙设备->连接蓝牙设备->发现设备服务->发现服务特征->往特征里面写入信息(相当于发送信息)/订阅特征(相当于注册通知回调)->断开蓝牙.

### 系统蓝牙框架基本模型设计:
 一个设备里面会有n个服务, 每个服务里面会有n个特征. 手机与蓝牙设备的通讯是通过写入(修改)和订阅特征来完成.
 
 模型说明:
 CBCentralManager: 蓝牙设备管理者, 用于发现周围设备, 连接/断开设备.
 CBPeripheral: 代表蓝牙设备, 可以发现服务, 发现服务的特征, 写入或者订阅特征, 都要用它.
 CBService: 服务, 本身只是数据模型
 CBCharacteristic: 特征, 本身也只是数据模型

### 前置条件
打开APP蓝牙开关

