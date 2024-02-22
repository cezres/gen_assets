# gen_assets [WIP]


- [x] [根据资源文件目录生成对应的 Dart 代码](#根据资源文件目录生成对应的-dart-代码)
- [ ] [分析项目中未引用的资源文件](#分析项目中未引用的资源文件)
- [ ] [支持云存储部分低频或大型资源文件以减小包体积](#支持云存储部分低频或大型资源文件以减小包体积)


## 如何使用

在 pubspec.yaml 文件的 dev_dependencies 下添加:
```yml
gen_assets:
    git:
        url: https://github.com/cezres/gen_assets.git
        ref: main
```

在工程根目录下添加 gen_assets.yaml 文件:
```yml
# 工具配置示例
input_dir: assets
output: output/assets.g.dart
```


运行
```bash
# 根据配置生成代码文件
dart run gen_assets
# 生成开发环境的代码文件
dart run gen_assets dev
# 输出未使用文件的列表
dart run gen_assets unused
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


## 一些实现上的初略想法

使用 Dart CLI 工程实现，在目标工程的 dev_dependencies 添加此包然后通过 `dart run gen_assets` 执行，根据运行时的路径查找配置文件后执行后续逻辑。


### 根据资源文件目录生成对应的 Dart 代码

- [x] 生成代码的调用结构与实际目录结构一致
- [ ] 支持更多的文件类型，以及其相应的便捷使用函数
    - [ ] 可以考虑 Dart 3.3 的 `extension type` 减少类型包装的开销。
- [ ] 支持排除文件，目录路径、文件路径、文件类型


### 分析项目中未引用的资源文件

由于使用了自动生成的代码引用资源文件，从代码文件中分析类和函数调用，从特征上来说比以前的字符串更容易精准识别。

### 支持云存储部分低频或大型资源文件以减小包体积

- [ ] 业务层调用如何兼容本地资源和网络资源？
    - [ ] 例如图片文件添加构建 Weiget 函数，网络类型资源和本地类型资源接口名称和参数一致，这样业务层无需对来源类型做额外处理
- [ ] 如何分析哪些资源适合云存储?
    - 在开发环境使用不同的配置生成代码，在资源被引用时记录相关参数.
    - 适合云存储资源文件的相关数据指标
        - 首次引用时距离应用启动的时间
        - 资源文件大小
        - 引用的总持续时间
            - 开发环境版本的代码使用自定义的 ImageProvider 能获取到被监听或取消监听
        - 记录应用程序退出时间
    - 根据搜集到的统计数据以及配置文件中的相关限制，输出匹配的资源文件配置表。
    - 根据云存储资源文件的配置表
        - 配置 OSS Key ，使用命令批量上传云存储资源文件
        - 所有文件放在项目目录下，但通过工具命令自动维护 pubspec.yaml 的 assets 依赖
- [ ] 不同版本云存储资源文件的管理？
    - 读取运行目录下的 pubspec.yaml 中的 version 作为存储时区分版本的上级目录
- [ ] 预加载网络资源的组件
    - 添加低优先级的预加载后台任务，需要做好任务调度不影响活跃模块的对网络的使用
    - 根据统计数据，计算更合适的预加载顺序，优先加载引用更多更早的文件
- [ ] CI/CD？

