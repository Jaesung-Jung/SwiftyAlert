//
//  TextFieldAlert.swift
//
//  Copyright © 2022 Jaesung Jung. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#if canImport(UIKit)

import UIKit

public struct TextFieldAlert<Item> {
  let base: Alert<Item>
  let textChangeObserver: TextChangeObserver?

  public func title(_ title: String) -> Self {
    TextFieldAlert(
      base: base.title(title),
      textChangeObserver: textChangeObserver
    )
  }

  public func message(_ message: String) -> Self {
    TextFieldAlert(
      base: base.message(message),
      textChangeObserver: textChangeObserver
    )
  }

  public func addTextField(_ configurationHandler: ((UITextField) -> Void)? = nil) -> Self {
    TextFieldAlert(
      base: Alert(style: base.style, popoverPresentationHandler: nil) {
        base.modifier?($0, $1)
        $0.addTextField(configurationHandler: configurationHandler)
      },
      textChangeObserver: textChangeObserver
    )
  }

  public func preferredAction(_ action: Alert<Item>.Action) -> Self {
    TextFieldAlert(
      base: base.preferredAction(action),
      textChangeObserver: textChangeObserver
    )
  }

  public func action(_ action: Alert<Item>.Action) -> Self {
    TextFieldAlert(
      base: base.action(action),
      textChangeObserver: textChangeObserver
    )
  }

  @available(iOS 16.0, tvOS 16.0, *)
  public func severity(_ severity: UIAlertControllerSeverity) -> Self {
    TextFieldAlert(
      base: base.severity(severity),
      textChangeObserver: textChangeObserver
    )
  }

  public func textChanged(_ handler: @escaping ([String], [UIAlertAction]) -> Void) -> Self {
    TextFieldAlert(base: base, textChangeObserver: TextChangeObserver(handler))
  }

  @MainActor
  public func present(from viewController: UIViewController, animated: Bool = true) async -> TextFieldAlert<Item>.Result {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: base.style)
    let item = await withCheckedContinuation { continuation in
      base.modifier?(alertController, continuation)
      textChangeObserver?.setAlertController(alertController)
      viewController.present(alertController, animated: animated)
    }
    if let item {
      let texts = alertController.textFields?.map { $0.text ?? "" } ?? []
      return .done(item, texts)
    } else {
      return .cancel
    }
  }
}

// MARK: - TextFieldAlert.Result

extension TextFieldAlert {
  public enum Result {
    case done(Item, [String])
    case cancel
  }
}

// MARK: - TextFieldAlert.TextChangeObserver

extension TextFieldAlert {
  class TextChangeObserver {
    let handler: ([String], [UIAlertAction]) -> Void
    var alertController: UIAlertController?

    init(_ handler: @escaping ([String], [UIAlertAction]) -> Void) {
      self.handler = handler
    }

    func setAlertController(_ alertController: UIAlertController) {
      self.alertController = alertController
      for textField in alertController.textFields ?? [] {
        textField.addTarget(self, action: #selector(handleEditingChangedTextField), for: .editingChanged)
      }
      handleEditingChangedTextField()
    }

    @objc func handleEditingChangedTextField() {
      guard let textFields = alertController?.textFields, let actions = alertController?.actions else {
        return
      }
      handler(textFields.map { $0.text ?? "" }, actions)
    }
  }
}

#endif
