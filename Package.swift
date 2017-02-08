import PackageDescription

let package = Package(
    name: "StencilJS",
    dependencies: [
        .Package(url: "https://github.com/kylef/Stencil.git", majorVersion: 0, minor: 7),
    ]
)
