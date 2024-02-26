# gen_assets [WIP]


- [x] [根据资源文件目录生成对应的 Dart 代码](#生成代码)
    - [ ] 缓存策略，无、弱引用、短时、长时、永久，LruCache，内存警告时释放。
    - [ ] 国际化、浅色/深色
    - [ ] 根据配置文件中的限制，对部分类型的大型文件例如大JSON文件的解码及实例化使用 compute
- [ ] 分析项目中未引用的资源文件
- [x] [检查重复文件](#检查重复文件)
- [ ] 相似文件
- [ ] 压缩文件
    - [x] [压缩图片文件至 WebP 格式](#压缩图片文件)
    - [x] [JSON 移除空格换行缩进](#压缩-json-文件)
- [ ] CI/CD
- [ ] 云存储部分低频或大型资源文件以减小包体积
- [ ] [一些实现上的初略想法](#一些实现上的初略想法)

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
# 资源文件根目录
input_dir: assets

# 生成的代码路径
output: output/assets.g.dart
```

### 生成代码

运行
```bash
$ dart run gen_assets
```

对于以下目录结构的代码
```
assets/
├── images/
    |── download.png
    |── download_1.png
    |── refresh.png
    |── share.png
|── fonts/
    |── Roboto-Regular.ttf
|── json/
    |── test1.json
|── lottie/
    |── test1.json
```

[生成的文件](https://github.com/cezres/gen_assets/blob/main/output/assets.g.dart)

生成文件后的使用方式
```dart
Assets.images.download.path; // 'assets/images/download.png'
Assets.images.download.image(); // Image.asset('assets/images/download.png')
Assets.fonts.robotoRegular.name; // 'Roboto-Regular'
Assets.json.test1.json(); // Future<Map<String, dynamic>>
Assets.json.test1.parse(T.fromJson); // Future<T>
Assets.lottie.test1.lottie(); // LottieBuilder.asset('assets/lottie/test1.json')
```

### 检查重复文件

```bash
dart run gen_assets list-duplicates
```

**输出:**
```shell
Duplicate Files:
[/assets/images/download.png, /assets/images/download_1.png]
Duplicate File Count: 1
Total Extra Size: 0.0008 MB
```

### 压缩图片文件

需要先确保本机安装了 Google WebP [下载并安装 WebP](https://developers.google.com/speed/webp/download?hl=zh-cn)。

**更新 gen_assets.yaml 文件:**
```yaml
# 需要转换到 webp 格式的图片文件后缀
convert_to_webp: [png, jpg, jpeg]

# cwebp 的路径，用于压缩图片文件
cwebp_path: /usr/local/bin/cwebp
```

**压缩图片，并保留原始文件，完成后输出减少的体积:**
```bash
dart run gen_assets cwebp
```

**输出:**
```shell
1/3 /assets/images/download.png --> /assets/images/download.webp
2/3 /assets/images/share.png --> /assets/images/share.webp
3/3 /assets/images/refresh.png --> /assets/images/refresh.webp
Original size: 3.969 KB
New size: 1.645 KB
Compression ratio: 41.4370%
```

**列出已被压缩的原始文件，输入 'Y' 确认后删除:**
```shell
dart run gen_assets list-cwebp-original
```

**输出:**
```shell
1. /assets/images/refresh.png
2. /assets/images/download.png
3. /assets/images/share.png
Enter 'Y' to delete all original images:
Y
All original images deleted.
```

### 压缩 JSON 文件

**移除空格换行缩进:**
```shell
dart run gen_assets cjson
```

**输出:**
```shell
162 --> 98 -- /assets/json/test1.json
15385 --> 4004 -- /assets/lottie/test1.json
18960 --> 4524 -- /assets/lottie/test2.json
Total reduction of 0.0247 MB
```

## 一些实现上的初略想法

使用 Dart CLI 工程实现，在目标工程的 dev_dependencies 添加此包然后通过 `dart run gen_assets` 执行，根据运行时的路径查找配置文件后执行后续逻辑。


### 根据资源文件目录生成对应的 Dart 代码

- [x] 生成代码的调用结构与实际目录结构一致
- [ ] 支持更多的文件类型，以及其相应的便捷使用函数
    - [x] png、jpeg、webp、...
    - [ ] svg
    - [x] json
    - [ ] ini
    - [x] lottie
    - [ ] 其它
    - [ ] Dart 3.3 可以使用 `extension type` 减少类型包装的开销。
- [ ] 支持排除文件，目录路径、文件路径、文件类型


### 分析项目中未引用的资源文件

- [ ] 静态分析。
    - 由于使用了自动生成的代码引用资源文件，从代码文件中分析类和函数中的引用，从特征上来说比之前的字符串更容易识别。
    - 对于间接引用或引用但不会执行的部分不易精准识别。
- [ ] 动态分析。
    - 开发环境使用不同的配置生成代码以在引用时记录相关数据。

### 根据配置文件中的限制，对部分类型的大型文件的加载和预处理使用 compute

- [ ] 使用 TransferableTypedData 和 Isolate.exit 不会产生额外的复制，但有 Isolate 的创建损耗，考虑合并短时间内(同一帧间隔)的任务。

### CI/CD?

例如使用 GitHub Actions，在指定分支的资源文件目录和`gen_assets.yaml`发生变更时触发，执行命令并检查或自动提交[Commit 或 PR]。

### 云存储部分低频或大型资源文件以减小包体积

- [ ] 业务层调用如何兼容本地资源和网络资源？
    - [ ] 例如图片文件添加构建 Weiget 函数，网络类型资源和本地类型资源接口名称和参数一致，这样业务层无需对来源类型做额外处理
- [ ] 如何配置需要云存储的文件
    - 在配置文件中指定
    - 根据统计数据和配置文件中的限制自动生成匹配的资源文件列表
        - 在开发环境使用不同的配置生成代码，在资源被引用时记录相关参数.
        - 适合云存储资源文件的相关数据指标
            - 引用时距离应用启动的时间
            - 引用时所处的页面/组件
                - 通过 StackTrace.current 获取函数调用栈，从中获取引用的组件名称。
                - x 通过 context 向上查询最近的 scaffold.appBar.title
            - 文件大小
            - 引用次数
    - 根据云存储资源文件的配置表
        - 配置 oss key ，使用命令批量上传云存储资源文件
        - 所有文件全量放在项目目录下，但通过工具自动维护 pubspec.yaml 的 assets 依赖
- [ ] 不同版本的文件？
    - 读取运行目录下的 pubspec.yaml 中的 version 作为存储时区分版本的上级目录
- [ ] 预加载网络资源
    - 添加低优先级的预加载后台任务，需要做好任务调度不影响活跃模块的对网络的使用
    - 根据统计数据及当前页面状态，使用更合适的预加载顺序
- [ ] CI/CD？

### 多 packages 工程的资源管理？