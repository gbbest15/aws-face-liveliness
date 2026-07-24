// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "aws_liveliness",
    platforms: [.iOS("14.0")],
    products: [
        .library(name: "aws-liveliness", targets: ["aws_liveliness"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/aws-amplify/amplify-swift", from: "2.0.0"),
        .package(url: "https://github.com/aws-amplify/amplify-ui-swift-liveness", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "aws_liveliness",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Amplify", package: "amplify-swift"),
                .product(name: "AWSCognitoAuthPlugin", package: "amplify-swift"),
                .product(name: "AWSPredictionsPlugin", package: "amplify-swift"),
                .product(name: "FaceLiveness", package: "amplify-ui-swift-liveness")
            ]
        )
    ]
)