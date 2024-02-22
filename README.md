# gen_assets


- [x] 根据资源文件目录生成对应的 Dart 代码
- [ ] 分析项目中未引用的资源文件
- [ ] 支持云存储部分资源文件以减小包体积


## 如何使用

在 pubspec.yaml 文件的 dev_dependencies 下添加:
```
gen_assets:
    git:
        url: https://github.com/cezres/gen_assets.git
        ref: main
```

运行
```
dart run gen_assets
```


## 





