import SwiftUI
import UIKit

struct SelectAllTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType
    var returnKeyType: UIReturnKeyType
    var isFocused: Bool
    var selectAllOnFocus: Bool
    var onReturn: () -> Void
    var onBeginEditing: () -> Void

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        textField.keyboardType = keyboardType
        textField.returnKeyType = returnKeyType
        textField.autocorrectionType = .no
        textField.placeholder = placeholder
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.returnKeyType = returnKeyType

        if isFocused && !uiView.isFirstResponder {
            if uiView.window != nil {
                uiView.becomeFirstResponder()
                if selectAllOnFocus {
                    DispatchQueue.main.async {
                        uiView.selectAll(nil)
                    }
                }
            }
        } else if !isFocused && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SelectAllTextField

        init(parent: SelectAllTextField) {
            self.parent = parent
        }

        @objc func textChanged(_ sender: UITextField) {
            parent.text = sender.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onBeginEditing()
            if parent.selectAllOnFocus {
                DispatchQueue.main.async {
                    textField.selectAll(nil)
                }
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onReturn()
            return true
        }
    }
}
