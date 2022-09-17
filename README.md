# SwiftyAlert

SwiftAlert is simple and elegant way to handle UIAlertController.

## Feature

- Handle action with async/await
- Method chain
- Support UITextField
- Support text based actions enable or disable
- Support Popover

## Requirements

- Swift 5.7+
- iOS 13.0+
- tvOS 13.0+

## Usage

#### Basic Alert

The basic is build an alert with method chain.

![](https://raw.githubusercontent.com/Jaesung-Jung/SwiftyAlert/main/Alert1.png)

```swift
let alert = Alert(style: .alert)
  .title("Title")
  .message("Message")
  .action(.default("Done"))

_ = await alert.present(from: vc)
```

#### Handle Action

When closed alert, result is `.done` or `.cancel`. `.done` contains an item passed in from the action. If passed no item, the type is `Void`.

![](https://raw.githubusercontent.com/Jaesung-Jung/SwiftyAlert/main/Alert2.png)

```swift
let alert = Alert(style: .alert)
  .title("Delete")
  .message("Are you sure?")
  .action(.cancel("Cancel"))
  .action(.destructive("Delete")) // destructive style

switch await alert.present(from: vc) {
case .done:
  print("Delete")
case .cancel:
  print("Cancel")
}
```

#### Action Sheet (Multiple Actions)

This is an action sheet that passes multiple string items. `.done` has a selected item.

When providing an action sheet on the iPad, you can set a popover presentation controller with `popoverPresentation` method.

![](https://raw.githubusercontent.com/Jaesung-Jung/SwiftyAlert/main/Alert3.png)

```swift
let sheet = Alert(style: .actionSheet)
  .title("Select")
  .message("Select a fruit")
  .action(.cancel("Cancel"))
  .action(.default("Apple", item: "🍎"))
  .action(.default("Grapes", item: "🍇"))
  .action(.default("Peach", item: "🍑"))
  .popoverPresentation { popover in // for ipad
    popover.sourceView = sourceView
    popover.sourceRect = sourceRect
  }

switch await sheet.present(from: vc) {
case .done(let item):
  print("Select \(item)") // item is [🍎, 🍇, 🍑]
case .cancel:
  print("Cancel")
}
```

#### Alert with a text field

You can add and configure text fields using the `addTextField` method.

When a text field is added, `.done` has an item and texts.

![](https://raw.githubusercontent.com/Jaesung-Jung/SwiftyAlert/main/Alert4.png)

```swift
let alert = Alert(style: .alert)
  .title("Name")
  .addTextField {
    // Configure text field
    $0.placeholder = "Enter a name"
  }
  .action(.cancel("Cancel"))
  .action(.default("Done"))

switch await alert.present(from: vc) {
case .done(_, let texts):
  print("Name is \(texts[0])")
case .cancel:
  print("Cancel")
}
```

#### Alert with multiple text fields

You can use `textChanged` method for the buttons enable or disable dependng on text input.

![](https://raw.githubusercontent.com/Jaesung-Jung/SwiftyAlert/main/Alert5.png)

```swift
let alert = Alert(style: .alert)
  .title("Login")
  .message("Login to service")
  .addTextField {
    $0.placeholder = "Account"
  }
  .addTextField {
    $0.placeholder = "Password"
    $0.isSecureTextEntry = true
  }
  .textChanged { texts, actions in
    let account = texts[0]
    let password = texts[1]
    for action in actions where action.style != .cancel {
      action.isEnabled = !id.isEmpty && !password.isEmpty
    }
  }
  .action(.cancel("Cancel"))
  .action(.default("Connect"))

switch await alert.present(from: vc) {
case .done(_, let texts):
  print("account: \(texts[0]), password: \(texts[1])")
case .cancel:
  print("Cancel")
}
```

## License

MIT license. [See LICENSE](https://github.com/Jaesung-Jung/SwiftyAlert/blob/main/LICENSE) for details.
