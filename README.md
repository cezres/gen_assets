# gen_assets [WIP]


- [x] [根据资源文件目录生成对应的 Dart 代码](#生成代码)
- [ ] [分析项目中未引用的资源文件](#分析项目中未引用的资源文件)
- [ ] 检查重复文件
- [ ] 相似文件
- [ ] 压缩文件
    - [x] [压缩图片文件至 WebP 格式](#压缩图片文件)
- [ ] [支持云存储部分低频或大型资源文件以减小包体积](#支持云存储部分低频或大型资源文件以减小包体积)
- [ ] CI/CD


## 如何使用

在 pubspec.yaml 文件的 dev_dependencies 下添加:
```yml
gen_assets:
    git:
        url: https://github.com/cezres/gen_assets.git
        ref: main
```

在工程根目录下添加 gen_assets.yaml 配置文件:
```yml
# 示例

# 资源文件根目录
input_dir: assets

# 生成的代码路径
output: output/assets.g.dart

# 工程代码根目录，用于识别未使用的资源文件
source_dir: bin

# 需要转换到webp格式的图片文件后缀
convert_to_webp: [png]

# cwebp 的安装路径 /usr/local/bin/cwebp
cwebp_path: /Users/cezres/Downloads/libwebp-1.3.2-mac-arm64 2/bin/cwebp
```

### 生成代码

运行
```bash
# 根据配置生成代码文件
$ dart run gen_assets
```

对于以下目录结构的代码
```
assets/
├── images/
    |── download.png
    |── refresh.png
    |── share.png
|── fonts/
    |── Roboto-Regular.ttf
```

[生成的文件](https://github.com/cezres/gen_assets/blob/main/output/assets.g.dart)

生成文件后的使用方式
```dart
Assets.images.download.name; // '/assets/images/download.png'
Assets.images.download.image(); // Image.asset('/assets/images/download.png')
Assets.fonts.robotoRegular.name; // '/assets/fonts/Roboto-Regular.ttf'
```


### 压缩图片文件

需要先确保本机安装了 Google WebP [下载并安装 WebP](https://developers.google.com/speed/webp/download?hl=zh-cn)。

**压缩图片，并保留原始文件，完成后输出减少的体积**
```bash
dart run gen_assets --cwebp
```

**输出:**
```shell
Building package executable... 
Built gen_assets:gen_assets.
1/3 /assets/images/download.png --> /assets/images/download.webp
2/3 /assets/images/share.png --> /assets/images/share.webp
3/3 /assets/images/refresh.png --> /assets/images/refresh.webp
Original size: 3.969 KB
New size: 1.645 KB
Compression ratio: 41.4370%
```

**列出已被压缩的原始文件，输入 'Y' 确认后删除**
```shell
dart run gen_assets --list_cwebp_original
```

**输出:**
```shell
Building package executable... 
Built gen_assets:gen_assets.
1. /assets/images/refresh.png
2. /assets/images/download.png
3. /assets/images/share.png
Enter 'Y' to delete all original images:
Y
All original images deleted.
```


## 一些实现上的初略想法

使用 Dart CLI 工程实现，在目标工程的 dev_dependencies 添加此包然后通过 `dart run gen_assets` 执行，根据运行时的路径查找配置文件后执行后续逻辑。


### 根据资源文件目录生成对应的 Dart 代码

- [x] 生成代码的调用结构与实际目录结构一致
- [ ] 支持更多的文件类型，以及其相应的便捷使用函数
    - [ ] 可以考虑 Dart 3.3 的 `extension type` 减少类型包装的开销。
- [ ] 支持排除文件，目录路径、文件路径、文件类型


### 分析项目中未引用的资源文件

由于使用了自动生成的代码引用资源文件，从代码文件中分析类和函数调用，从特征上来说比以前的字符串更容易精准识别。

### CI/CD?

例如使用 GitHub Actions，在指定分支的资源文件目录和`gen_assets.yaml`发生变更时触发，执行命令并自动提交[Commit 或 PR]。

### 支持云存储部分低频或大型资源文件以减小包体积

- [ ] 业务层调用如何兼容本地资源和网络资源？
    - [ ] 例如图片文件添加构建 Weiget 函数，网络类型资源和本地类型资源接口名称和参数一致，这样业务层无需对来源类型做额外处理
- [ ] 如何分析哪些资源适合云存储?
    - 在配置文件中指定
    - 根据统计数据和配置文件中的限制输出匹配的资源文件列表
        - 在开发环境使用不同的配置生成代码，在资源被引用时记录相关参数.
        - 适合云存储资源文件的相关数据指标
            - 首次引用时距离应用启动的时间
            - 资源文件大小
            - 引用的总持续时间
                - 开发环境版本的代码使用自定义的 ImageProvider 能获取到被监听或取消监听
            - 记录应用程序退出时间
    - 根据云存储资源文件的配置表
        - 配置 OSS Key ，使用命令批量上传云存储资源文件
        - 所有文件全量放在项目目录下，但通过工具命令自动维护 pubspec.yaml 的 assets 依赖
- [ ] 不同版本云存储资源文件的管理？
    - 读取运行目录下的 pubspec.yaml 中的 version 作为存储时区分版本的上级目录
- [ ] 预加载网络资源的组件
    - 添加低优先级的预加载后台任务，需要做好任务调度不影响活跃模块的对网络的使用
    - 根据统计数据，计算更合适的预加载顺序，优先加载引用更多更早的文件
- [ ] CI/CD？

