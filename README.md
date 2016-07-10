# luaKTPlay

为KTPlay提供lua支持

## 如何使用

### iOS

* 首先按照官方文档配置iOS工程
* 将ios目录下的如下文件加入工程：
 * `KTPlayBridge.mm`
 * `KTPlayBridge.h`
 * `KTPlayConversion.h`
 * `KTPlayConversion.m`
* 将ios目录下的`ktplay_ios.lua`拷贝到`src/`下任意目录

### android

* 首先按照官方文档配置android工程
* 将android目录下的如下文件放入工程下，如果是cocos2dx创建的，默认是`projectname/org/cocos2dx/lua`：
 * `KTPlayBridge.java`
 * `KTPlayConversion.java`
* 将ios目录下的`ktplay_android.lua`拷贝到`src/`下任意目录
