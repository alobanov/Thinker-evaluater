<p align="center">
   <img width="200" src="https://raw.githubusercontent.com/SvenTiigi/SwiftKit/gh-pages/readMeAssets/SwiftKitLogo.png" alt="thinker Logo">
</p>

<p align="center">
   <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">
   </a>
<!--    <a href="http://cocoapods.org/pods/thinker">
      <img src="https://img.shields.io/cocoapods/v/thinker.svg?style=flat" alt="Version">
   </a> -->
<!--    <a href="http://cocoapods.org/pods/thinker">
      <img src="https://img.shields.io/cocoapods/p/thinker.svg?style=flat" alt="Platform">
   </a> -->
   <a href="https://github.com/Carthage/Carthage">
      <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage Compatible">
   </a>
   <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="SPM">
   </a>
</p>

# thinker
<p align="center">
<b>ℹ️ Parser for evaluating logic expressions.</b>
</p>

For example we have string like `44 >= 43 || 22 == 12`, you need to evaluate this expression and take  a boolean result. So give that line for `thinker` and BOOM you have a result. Example: `let result = ThinkerEvaluater.eval(srt)`

## Features

- [x] Work with types:
   - [x] Numeric constants, as floating point (12345.678)
   - [x] String constants (single quotes: \`foobar\`)
   - [x] Boolean constants: `true` `false`
- [x] Comparison operators: `==`, `>=`, `<=`, `!=`, `>`, `<`
- [x] Logic operators: `&&`, `||`, `OR`, `AND`
- [x] Map value from json, for example `prefix.node.nestedValue`, `var.` will be replaced value from dictionary by key `prefix.node.nestedValue`
- [x] Parenthesis to control order of evaluation `(` `)`

## Roadmap

- [ ] Ternary conditional: `?` `:`
- [ ] Modifiers: `+` `-` `/` `*` `&` `|` `^` `**` `%` `>>` `<<`

## Example

The example application is the best way to see `thinker` in action. Simply open the `thinker.xcodeproj` and run the `Example` scheme.

## Usage

```swift    
XCTAssertEqual(ThinkerEvaluater.eval("2 == 2"), true) // Int
XCTAssertEqual(ThinkerEvaluater.eval("-122.321 == -122.321"), true) // Doube
XCTAssertEqual(ThinkerEvaluater.eval("false != true"), true) // Boolean
XCTAssertEqual(ThinkerEvaluater.eval("`asd` != `ads`"), true) // String
XCTAssertEqual(ThinkerEvaluater.eval("`milk` == `milk` && 2 >= 1 || true == true"), true) // Composite expression

// Usafe with JSON values

let string = "model.int == 21 && model.nested.value != true || model.doubleValue == 3233.23123124 && `model.string` == `stringValue`"
    
let json: [String: Any] = [
   "int": 21,
   "nested": ["value": false],
   "string": "stringValue",
   "doubleValue": 3233.23123124
 ]

let result = ThinkerEvaluater.eval(string, keypathConfig: ("model.", json))

if !result.rest.isEmpty {
  XCTFail(String(result.rest))
}

XCTAssertEqual(result.result, true)

// Parenthesis to control order of evaluation

let expression = "(34 == 34 || false == true) && ((43 >= 23) || (`asd` == `not` || 11 == 11))"
let result = ThinkerEvaluater.eval(expression)
XCTAssertEqual(result.result, true)
```

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

To integrate thinker into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "alobanov/thinker"
```

Run `carthage update` to build the framework and drag the built `thinker.framework` into your Xcode project. 

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase” and add the Framework path as mentioned in [Carthage Getting started Step 4, 5 and 6](https://github.com/Carthage/Carthage/blob/master/README.md#if-youre-building-for-ios-tvos-or-watchos)

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://alobanov@github.com/alobanov/Thinker-evaluater.git", from: "1.0.0")
]
```

Alternatively navigate to your Xcode project, select `Swift Packages` and click the `+` icon to search for `thinker`.

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate thinker into your project manually. Simply drag the `Sources` Folder into your Xcode project.

## Contributing
Contributions are very welcome 🙌

## License

```
thinker
Copyright (c) 2020 thinker lobanov.aw@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
