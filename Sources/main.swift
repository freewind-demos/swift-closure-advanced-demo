// swift-closure-advanced-demo.swift

// ============ 自动闭包 ============
var customers = ["小明", "小红", "小华"]
let customerProvider = { customers.removeFirst() }
print("下一个顾客: \(customerProvider())")

// ============ 逃逸闭包 ============
var completionHandlers: [() -> Void] = []
func withEscapingClosure(completion: @escaping () -> Void) {
    completionHandlers.append(completion)
}
var value = 10
withEscapingClosure {
    value = 20
}
print("value: \(value)")

// ============ 闭包捕获列表 ============
class Calculator {
    var multiplier = 3
    func multiply(_ value: Int) -> Int {
        return value * multiplier
    }
}
let calc = Calculator()
let multiply = { [calc] in calc.multiply(10) }
print("使用捕获列表: \(multiply())")

// ============ @autoclosure ============
func logIfTrue(_ condition: @autoclosure () -> Bool) {
    if condition() {
        print("条件为真")
    }
}
logIfTrue(2 > 1)

// ============ 内存管理 ============
class Person {
    let name: String
    init(name: String) {
        self.name = name
        print("\(name) 创建")
    }
    deinit {
        print("\(name) 销毁")
    }
}

var closure: (() -> Void)?
var person: Person? = Person(name: "Tom")
closure = { [person] in
    print("闭包中使用: \(person?.name ?? "nil")")
}
closure?()
person = nil
closure?()
