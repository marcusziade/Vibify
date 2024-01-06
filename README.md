# Vibify

<img src="Vibify/Resources/Assets.xcassets/AppIcon.appiconset/vibifyicon-1024.png" width="200" height="200" />

Vibify is an innovative iOS app designed to provide users with personalized music playlist suggestions. Utilizing advanced AI algorithms, Vibify curates playlists that resonate with individual preferences and moods.

## Features

- Personalized playlist generation
- AI-driven music recommendations
- User-friendly interface

## Getting Started

To run Vibify on your local machine, follow these steps:

### Prerequisites

- Xcode 15 or later
- iOS 17 or later

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/Vibify.git
   ```
2. Open `Vibify.xcodeproj` in Xcode.

### API Key Configuration

Vibify uses the OpenAI API to generate music playlists. To run the app, you'll need to set up an API key.

1. Obtain an API key from [OpenAI](https://openai.com/).
2. In Xcode, go to `Product` -> `Scheme` -> `Edit Scheme`.
3. Select `Run` from the side panel.
4. Under `Environment Variables`, click the `+` button to add a new variable.
5. Name the variable `API_KEY` and set its value to your OpenAI API key.

Please ensure you do not commit your API key to your version control system.

## Usage

Once you have configured the API key:

1. Build and run the app in your simulator or device.
2. Interact with the app to receive personalized playlist suggestions.

## Contributing

We welcome contributions to Vibify. Please read our contributing guidelines before submitting a pull request.

```