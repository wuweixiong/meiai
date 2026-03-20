# XindongrijiApp

XindongrijiApp 是心动日记 `xindongriji-project` 的 iOS 15+ Objective-C 原生客户端。

## 分层结构

- `ViewController/`：登录、注册、日记列表、日记编辑/详情、标签管理、个人中心、主 Tab 路由
- `Network/HTTPClient`：AFNetworking 统一封装（JWT 头、超时、异常处理、GET/POST/PUT/DELETE、后端 API 对接）
- `Model/`：`UserModel`、`DiaryModel`、`TagModel`（MJExtension JSON 解析）
- `DB/CoreDataManager`：用户与日记缓存、离线写入、待同步队列、网络恢复后自动同步
- `Utils/`：`TokenManager`、`DateUtils`、`ToastUtils`、`FormValidator`、`AppRouter`
- `Resource/`：`Info.plist`、`LaunchScreen.storyboard`、CoreData 模型

## 后端基地址

`Network/HTTPClient.m` 默认地址：

```objc
static NSString * const kXDJBaseURL = @"http://127.0.0.1:8080/api/v1";
```

真机联调请改成局域网可访问地址。

## 运行

```bash
cd XindongrijiApp
pod install
open XindongrijiApp.xcworkspace
```

## 说明

- 当前 `xindongriji-backend` 暂无修改密码接口，`ProfileViewController` 已预留调用位（`/users/me/password`）。
- `Info.plist` 已开启 `NSAppTransportSecurity -> NSAllowsArbitraryLoads = YES` 用于开发联调。
- `TZImagePickerController` 仍可按需在 `Podfile` 解注释后启用。
