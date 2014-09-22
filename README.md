# Q-iOS base framework

![design](doc/images/design.png)


项目基于[iOS-Universal-Framework](https://github.com/kstenerud/iOS-Universal-Framework)，编译后生产QBaseFramework.

添加QBaseFramework到新的iOS项目里即可使用。

## Features

- 支持iOS5+
- 默认ARC

## Develop mode

### native

ios base framework is used for native

### hybrid

when need webview

- create a project with cordova
- use ios base framework
- some function can use CDViewcontroller

## 代码管理

使用git submodule

分支管理 http://www.juvenxu.com/2010/11/28/a-successful-git-branching-model/


- 开发分支是`dev`
- 当前稳定分支是`master`

## 依赖

[dependency libs](doc/dependency.md)


## 进度

### v0.1.0

jsonmodel 作为model核心，其他的db操作等都扩展到jsonmodel里

- [ ] afnetworking
- [ ] jsonmodel
- [ ] fmdb(sqlite) 
- [ ] mvc(base class)
- [ ] utils


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## 版本历史

- v0.1.0 初始化版本

## 欢迎fork和反馈

- write by `i5ting` shiren1118@126.com
- write by `健翔` andy_ios@163.com

如有建议或意见，请在issue提问或邮件

## License

this repo is released under the [MIT
License](http://www.opensource.org/licenses/MIT).