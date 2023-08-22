//
//  ViewController.swift
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

import UIKit

class ViewController: UITableViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    switch indexPath.section {
    case 0:
      alert(at: indexPath.row)
    case 1:
      textFieldAlert(at: indexPath.row)
    default:
      break
    }
  }

  func alert(at index: Int) {
    Task {
      switch index {
      case 0:
        await alert()
      case 1:
        await alertWithDestructiveAction()
      case 2:
        await actionSheet()
      case 3:
        alertWithoutAsync()
      default:
        break
      }
    }
  }

  func textFieldAlert(at index: Int) {
    Task {
      switch index {
      case 0:
        await alertWithTextField()
      case 1:
        await alertWithMultipleTextFields()
      default:
        break
      }
    }
  }
}

extension ViewController {
  func alert() async {
    let alert = Alert(style: .alert)
      .title("Title")
      .message("Message")
      .action(.default("Done"))

    _ = await alert.present(from: self)

    print("finished")
  }

  func alertWithoutAsync() {
    let alert = Alert(style: .alert)
      .title("Title")
      .message("Message")
      .action(.default("Done"))

    alert.present(from: self)

    print("presented")
  }

  func alertWithDestructiveAction() async {
    let alert = Alert(style: .alert)
      .title("Delete")
      .message("Are you sure?")
      .action(.cancel("Cancel"))
      .action(.destructive("Delete"))

    switch await alert.present(from: self) {
    case .done:
      print("Delete")
    case .cancel:
      print("Cancel")
    }
  }

  func actionSheet() async {
    let sheet = Alert(style: .actionSheet)
      .title("Select")
      .message("Select a fruit")
      .action(.cancel("Cancel"))
      .action(.default("Apple", item: "🍎"))
      .action(.default("Grapes", item: "🍇"))
      .action(.default("Peach", item: "🍑"))
      .popoverPresentation { popover in // for ipad
        popover.sourceView = self.view
        popover.sourceRect = self.view.bounds
      }

    switch await sheet.present(from: self) {
    case .done(let item):
      print("Select \(item)") // item is [🍎, 🍇, 🍑]
    case .cancel:
      print("Cancel")
    }
  }
}

extension ViewController {
  func alertWithTextField() async {
    let alert = Alert(style: .alert)
      .title("Name")
      .addTextField {
        $0.placeholder = "Enter a name"
      }
      .action(.cancel("Cancel"))
      .action(.default("Done"))

    switch await alert.present(from: self) {
    case .done(_, let texts):
      print("Name is \(texts[0])")
    case .cancel:
      print("Cancel")
    }
  }

  func alertWithMultipleTextFields() async {
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
        let id = texts[0]
        let password = texts[1]
        for action in actions where action.style != .cancel {
          action.isEnabled = !id.isEmpty && !password.isEmpty
        }
      }
      .action(.cancel("Cancel"))
      .action(.default("Connect"))

    switch await alert.present(from: self) {
    case .done(_, let texts):
      print("account: \(texts[0]), password: \(texts[1])")
    case .cancel:
      print("Cancel")
    }
  }
}
