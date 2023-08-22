//
//  Alert.swift
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

// MARK: - Alert

public struct Alert<Item> {
  public typealias PopoverPresentationHandler = (UIPopoverPresentationController) -> Void

  typealias Modifier = (UIAlertController, CheckedContinuation<Item?, Never>?) -> Void

  let style: UIAlertController.Style
  let popoverPresentationHandler: PopoverPresentationHandler?

  let modifier: Modifier?

  public init(style: UIAlertController.Style) {
    self.init(style: style, popoverPresentationHandler: nil, modifier: nil)
  }

  init(
    style: UIAlertController.Style,
    popoverPresentationHandler: PopoverPresentationHandler?,
    modifier: Modifier?
  ) {
    self.style = style
    self.popoverPresentationHandler = popoverPresentationHandler
    self.modifier = modifier
  }

  public func title(_ title: String) -> Self {
    Alert(style: style, popoverPresentationHandler: popoverPresentationHandler) {
      modifier?($0, $1)
      $0.title = title
    }
  }

  public func message(_ message: String) -> Self {
    Alert(style: style, popoverPresentationHandler: popoverPresentationHandler) {
      modifier?($0, $1)
      $0.message = message
    }
  }

  public func addTextField(_ configurationHandler: ((UITextField) -> Void)? = nil) -> TextFieldAlert<Item> {
    TextFieldAlert(base: self, textChangeObserver: nil)
      .addTextField(configurationHandler)
  }

  public func preferredAction(_ action: Alert<Item>.Action) -> Self {
    Alert(style: style, popoverPresentationHandler: popoverPresentationHandler) { alert, continuation in
      modifier?(alert, continuation)
      let action = UIAlertAction(title: action.title, style: action.style) { _ in
        continuation?.resume(returning: action.item)
      }
      alert.addAction(action)
      alert.preferredAction = action
    }
  }

  public func action(_ action: Alert<Item>.Action) -> Self {
    Alert(style: style, popoverPresentationHandler: popoverPresentationHandler) { alert, continuation in
      modifier?(alert, continuation)
      let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
        continuation?.resume(returning: action.item)
      }
      alert.addAction(alertAction)
    }
  }

  @available(iOS 16.0, tvOS 16.0, *)
  public func severity(_ severity: UIAlertControllerSeverity) -> Self {
    Alert(style: style, popoverPresentationHandler: popoverPresentationHandler) {
      modifier?($0, $1)
      $0.severity = severity
    }
  }

  public func popoverPresentation(_ configurationHandler: @escaping PopoverPresentationHandler) -> Self {
    if style == .actionSheet {
      return Alert(style: style, popoverPresentationHandler: configurationHandler, modifier: modifier)
    } else {
      return self
    }
  }

  @MainActor
  public func present(from viewController: UIViewController, animated: Bool = true) async -> Alert<Item>.Result {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: style)
    if let popoverPresentationController = alertController.popoverPresentationController {
      popoverPresentationHandler?(popoverPresentationController)
    }
    let item = await withCheckedContinuation { continuation in
      modifier?(alertController, continuation)
      viewController.present(alertController, animated: animated)
    }
    if let item {
      return .done(item)
    } else {
      return .cancel
    }
  }
}

extension Alert where Item == Void {
  public func present(from viewController: UIViewController, animated: Bool = true) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: style)
    if let popoverPresentationController = alertController.popoverPresentationController {
      popoverPresentationHandler?(popoverPresentationController)
    }
    modifier?(alertController, nil)
    viewController.present(alertController, animated: animated)
  }
}

// MARK: - Alert.Action

extension Alert {
  public struct Action {
    let title: String
    let style: UIAlertAction.Style
    let item: Item?

    init(title: String, style: UIAlertAction.Style, item: Item?) {
      self.title = title
      self.style = style
      self.item = item
    }

    public static func `default`(_ title: String, item: Item) -> Self {
      return Action(title: title, style: .default, item: item)
    }

    public static func destructive(_ title: String, item: Item) -> Self {
      return Action(title: title, style: .destructive, item: item)
    }

    public static func cancel(_ title: String) -> Self {
      return Action(title: title, style: .cancel, item: nil)
    }
  }
}

extension Alert.Action where Item == Void {
  public static func `default`(_ title: String) -> Self {
    return Alert.Action(title: title, style: .default, item: ())
  }

  public static func destructive(_ title: String) -> Self {
    return Alert.Action(title: title, style: .destructive, item: ())
  }
}

// MARK: - Alert.Result

extension Alert {
  public enum Result {
    case done(Item)
    case cancel
  }
}

#endif
