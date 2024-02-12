import ProjectDescription

let project = Project(
    name: "Vibify",
    organizationName: "Marcus Ziade",
    packages: [
        .package(url: "https://github.com/groue/GRDB.swift.git", .branch("master")),
        .package(url: "https://github.com/marcusziade/CachedAsyncImage.git", .branch("master")),
        .package(
            url: "https://github.com/Peter-Schorn/SpotifyAPI.git", .upToNextMajor(from: "2.2.4")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", .branch("master")),
    ],
    targets: [
        Target(
            name: "Vibify",
            destinations: [.iPhone, .iPad, .macWithiPadDesign],
            product: .app,
            bundleId: "com.marcusziade.vibify.app",
            infoPlist: .extendingDefault(with: [
                "CFBundleVersion": "1",
                "CFBundleShortVersionString": "1.0",
                "NSAppleMusicUsageDescription":
                    "This app requires access to your music library to create and manage your playlists.",
                "UISupportedInterfaceOrientations": [
                    "UIInterfaceOrientationPortrait",
                    "UIInterfaceOrientationLandscapeLeft",
                    "UIInterfaceOrientationLandscapeRight",
                ],
                "UISupportedInterfaceOrientations~ipad": [
                    "UIInterfaceOrientationPortrait",
                    "UIInterfaceOrientationPortraitUpsideDown",
                    "UIInterfaceOrientationLandscapeLeft",
                    "UIInterfaceOrientationLandscapeRight",
                ],
                "UIBackgroundModes": ["audio"],
                "UIRequiredDeviceCapabilities": ["armv7"],
                "UIRequiresFullScreen": true,
                "UIStatusBarHidden": true,
                "UIViewControllerBasedStatusBarAppearance": false,
                "NSCameraUsageDescription":
                    "This app requires access to your camera to scan QR codes.",
                "NSMicrophoneUsageDescription":
                    "This app requires access to your microphone to record audio.",
                "NSPhotoLibraryUsageDescription":
                    "This app requires access to your photo library to select a profile picture.",
                "NSUserTrackingUsageDescription":
                    "This app requires access to track you across apps and websites owned by other companies.",
                "NSPhotoLibraryAddUsageDescription":
                    "This app requires access to your photo library to save images.",
                "NSLocationWhenInUseUsageDescription":
                    "This app requires access to your location to show you nearby events.",
            ]),
            sources: ["../Vibify/**"],
            resources: [
                "../Vibify/Resources**/",
                .folderReference(path: "../Vibify/Resources/Assets.xcassets"),
            ],
            dependencies: [
                .package(product: "GRDB"),
                .package(product: "CachedAsyncImage"),
                .package(product: "SpotifyAPI"),
                .package(product: "KeychainAccess"),
            ],
            environmentVariables: [
                "API_KEY": EnvironmentVariable(
                    value: ProjectEnvironmentVariables.apiKey, isEnabled: true),
                "SPOTIFY_CLIENT_ID": EnvironmentVariable(
                    value: ProjectEnvironmentVariables.spotifyClientID, isEnabled: true),
                "SPOTIFY_CLIENT_SECRET": EnvironmentVariable(
                    value: ProjectEnvironmentVariables.spotifyClientSecret, isEnabled: true),
            ]
        )
    ],
    schemes: []
)
