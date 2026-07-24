import SwiftUI
import FaceLiveness
import Amplify
import AWSPredictionsPlugin
import UIKit

enum LivenessPresenter {

    private static var hostingController: UIHostingController<AnyView>?

    static func present(from viewController: UIViewController,
                         sessionID: String,
                         region: String,
                         completion: @escaping (Result<Void, Error>) -> Void) {

        // isPresented binding — the view sets this to false internally when it's done
        var isPresentedValue = true
        let isPresentedBinding = Binding<Bool>(
            get: { isPresentedValue },
            set: { newValue in
                isPresentedValue = newValue
                if newValue == false {
                    dismiss()
                }
            }
        )

        let livenessView = FaceLivenessDetectorView(
            sessionID: sessionID,
            region: region,
            isPresented: isPresentedBinding,
            onCompletion: { result in
                DispatchQueue.main.async {
                    dismissAndFinish {
                        switch result {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        )

        let hosting = UIHostingController(rootView: AnyView(livenessView))
        hosting.modalPresentationStyle = .fullScreen
        self.hostingController = hosting

        DispatchQueue.main.async {
            viewController.present(hosting, animated: true)
        }
    }

    private static func dismiss() {
        hostingController?.dismiss(animated: true)
        hostingController = nil
    }

    private static func dismissAndFinish(_ afterDismiss: @escaping () -> Void) {
        guard let hosting = hostingController else {
            afterDismiss()
            return
        }
        hosting.dismiss(animated: true) {
            afterDismiss()
        }
        hostingController = nil
    }
}
