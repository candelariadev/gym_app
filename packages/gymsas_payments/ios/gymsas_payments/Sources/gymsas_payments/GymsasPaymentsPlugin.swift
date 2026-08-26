import CoreMethods
import Flutter
import MercadoPagoCheckout
import UIKit

public final class GymsasPaymentsPlugin: NSObject, FlutterPlugin {
  private static var mercadoPagoInitialized = false
  private var checkoutInProgress = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "gymsas/payments",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(GymsasPaymentsPlugin(), channel: channel)
  }

  @MainActor
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "checkout" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard !checkoutInProgress else {
      result(FlutterError(code: "checkout_in_progress", message: "Ya existe un checkout en curso", details: nil))
      return
    }
    guard
      let arguments = call.arguments as? [String: Any],
      let publicKey = arguments["publicKey"] as? String, !publicKey.isEmpty,
      let orderId = arguments["orderId"] as? String, !orderId.isEmpty,
      let clientToken = arguments["clientToken"] as? String, !clientToken.isEmpty,
      let presenter = Self.activeViewController()
    else {
      result(FlutterError(code: "invalid_arguments", message: "Faltan datos para abrir el checkout", details: nil))
      return
    }

    checkoutInProgress = true
    let configuration = MercadoPagoSDK.Configuration(publicKey: publicKey, country: .MEX)
    if Self.mercadoPagoInitialized {
      MercadoPagoSDK.shared.setNewConfiguration(configuration)
    } else {
      MercadoPagoSDK.shared.initialize(configuration)
      Self.mercadoPagoInitialized = true
    }
    let checkout = MercadoPagoCheckout.Builder(
      checkoutType: .cardTransaction(
        order: MPOrder(orderId: orderId, clientToken: clientToken)
      ),
      checkoutAppearance: .init()
    ).build()
    checkout.present(from: presenter) { [weak self] checkoutResult in
      self?.checkoutInProgress = false
      switch checkoutResult {
      case let .success(payment):
        result([
          "outcome": "success",
          "providerStatus": payment.orderStatus,
          "paymentMethodId": payment.paymentMethodId,
        ])
      case let .error(error):
        result(["outcome": "error", "message": error.localizedDescription])
      case .userCancelled:
        result(["outcome": "cancelled"])
      }
    }
  }

  private static func activeViewController() -> UIViewController? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)?
      .rootViewController
  }
}
