# Swift 闭包高级 Demo

## 简介

本 demo 展示 Swift 闭包的高级特性：逃逸闭包、自动闭包、捕获列表。这些是编写高质量 Swift 代码的必备知识。

## 基本原理

### 逃逸闭包 vs 非逃逸闭包

Swift 中的闭包分为两种：

1. **非逃逸闭包**：在函数返回前执行完毕
2. **逃逸闭包**：在函数返回后才执行

```
非逃逸闭包：
┌─────────────────┐
│ 调用函数         │
│   闭包执行       │
│   返回结果       │
└─────────────────┘

逃逸闭包：
┌─────────────────┐
│ 调用函数         │
│   保存闭包       │
│   返回结果       │ ───► 闭包稍后执行
└─────────────────┘
```

### 自动闭包

自动闭包（@autoclosure）自动把表达式包装成闭包，实现**惰性求值**。

### 捕获列表

捕获列表用于管理闭包对外部变量的引用，避免循环引用。

---

## 启动和使用

### 环境要求

- Swift 5.0+
- macOS 或 Linux

### 安装和运行

```bash
cd swift-closure-advanced-demo
swift run
---

## 教程

### 逃逸闭包 (@escaping)

当闭包需要**在函数返回后**执行时，需要使用 `@escaping`：

```swift
var completionHandlers: [() -> Void] = []

func withEscapingClosure(completion: @escaping () -> Void) {
    // 保存闭包，稍后执行
    completionHandlers.append(completion)
}

var value = 10
withEscapingClosure {
    value = 20  // 闭包在函数返回后执行
}
print("value: \(value)")  // 20
```

**为什么需要 @escaping？**

编译器默认假设闭包在函数返回前执行完，这样可以：
- 进行更多优化
- 避免内存管理问题

但对于异步操作，需要闭包逃逸：

```swift
func fetchData(completion: @escaping (String) -> Void) {
    DispatchQueue.global().async {
        // 异步操作
        completion("数据")
    }
}
```

### 自动闭包 (@autoclosure)

自动闭包把传入的表达式自动包装成闭包：

```swift
func logIfTrue(_ condition: @autoclosure () -> Bool) {
    if condition() {  // 调用时才求值
        print("条件为真")
    }
}

logIfTrue(2 > 1)  // 传入表达式，自动包装成闭包
```

**使用场景**：
- 日志和调试
- 断言
- 避免不必要的计算

### 捕获列表

捕获列表显式控制闭包如何捕获变量：

```swift
class Calculator {
    var multiplier = 3
    func multiply(_ value: Int) -> Int {
        return value * multiplier
    }
}

let calc = Calculator()
let multiply = { [calc] in calc.multiply(10) }
print("使用捕获列表: \(multiply())")
```

**常见捕获列表**：

| 捕获列表 | 说明 |
|----------|------|
| `[self]` | 强引用 self |
| `[weak self]` | 弱引用 self（可能为 nil） |
| `[unowned self]` | 无主引用（不安全，可能崩溃） |

### 内存管理与循环引用

闭包和类之间可能产生循环引用：

```swift
class Person {
    let name: String
    var closure: (() -> Void)?

    init(name: String) {
        self.name = name
        // 循环引用：self -> closure, closure -> self
        closure = { [self] in
            print("Hello, \(name)")
        }
    }
}
```

**解决方案**：使用 `[weak self]` 或 `[unowned self]`

```swift
class Person {
    let name: String
    var closure: (() -> Void)?

    init(name: String) {
        self.name = name
        closure = { [weak self] in
            guard let self = self else { return }
            print("Hello, \(self.name)")
        }
    }
}
```

### @autoclosure 和 @escaping 组合

```swift
func asyncLog(_ message: @autoclosure @escaping () -> String) {
    DispatchQueue.main.async {
        print(message())
    }
}

asyncLog("异步日志")  // 表达式自动包装成闭包
```

---

## 关键代码详解

### @escaping 的内存管理

```swift
func withEscapingClosure(completion: @escaping () -> Void) {
    completionHandlers.append(completion)
}
```

编译器需要知道闭包会"逃逸"，因此：
- 不能在闭包中直接引用非逃逸参数
- 闭包会进行堆分配，需要 ARC 管理

### 捕获列表的原理

```swift
{ [weak self] in
    self?.doSomething()
}
```

编译后会变成：

```swift
// 编译器生成
__main_block_impl_0 {
    __weak MyClass *weakSelf = self;
    // ...
    if (weakSelf) {
        [weakSelf doSomething];
    }
}
```

---

## 总结

闭包高级特性是 Swift 开发必备：

1. **@escaping** — 处理异步回调，需要手动管理生命周期
2. **@autoclosure** — 惰性求值，避免不必要的计算
3. **捕获列表** — 避免循环引用，特别是 `[weak self]`

最佳实践：
- 异步回调使用 `@escaping`
- 日志/调试使用 `@autoclosure`
- 类中的闭包使用 `[weak self]` 避免循环引用
- 避免使用 `[unowned self]`（除非确定 self 不会为 nil）
