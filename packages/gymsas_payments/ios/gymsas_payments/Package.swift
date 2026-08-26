// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "gymsas_payments",
    platforms: [.iOS("13.0")],
    products: [
        .library(name: "gymsas-payments", targets: ["gymsas_payments"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/mercadopago/sdk-ios", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "gymsas_payments",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "CoreMethods", package: "sdk-ios"),
                .product(name: "MercadoPagoCheckout", package: "sdk-ios")
            ]
        )
    ]
)
