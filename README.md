# PAssert

Power Assert for Swift

* Source

```ViewController.sfift
let num1 = 0
let num2 = 10
PAssert.assert(num1, >, num2) // false
PAssert.assert(num2, ==, 10)  // true
```

* Xcode Debug Area

```
=== Assertion Failed ===========================================================
DATE: 2015-04-09 17:02:04
FILE: ViewController.swift
LINE: 22
FUNC: viewDidLoad()

=> PAssert.assert(num1, >, num2)
                  |     |  |
                  |     |  10
                  |     |
                  |     false
                  |
                  0

[2015-04-09 17:02:04 ViewController.swift:23 viewDidLoad()] 10
```

## Installation

###CocoaPods

* PodFile

```POdFile
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'PAssert', :git => 'https://github.com/keygx/PAssert.git'
```
* install

```
$ pod install
```


## Usage

* Add DEBUG flag.

Pods > TARGETS > Pods-PAssert > Swift Compiler - Custom Flags > Other Swift Flags > Debug > -DDEBUG

![xcode](https://qiita-image-store.s3.amazonaws.com/0/15905/0d527e94-c83d-817d-e5ea-9b45ba542ea0.png)
<http://qiita.com/keygx/items/8c88cc1a39bb452c883f>

## License

PAssert is released under the MIT license. See LICENSE for details.

## Author

Yukihiko Kagiyama (keygx) <https://twitter.com/keygx>

