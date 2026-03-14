# Swift 闭包高级 Demo

## 简介

展示 Swift 闭包的高级特性：逃逸闭包、自动闭包、捕获列表。

## 启动和使用

```bash
cd swift-closure-advanced-demo
swift run
```

## 教程

### 逃逸闭包 (@escaping)

闭包在函数返回后才执行，需要标记 `@escaping`

### 自动闭包 (@autoclosure)

自动将表达式包装成闭包

### 捕获列表

```swift
{ [weak self] in
    // 防止循环引用
}
```
