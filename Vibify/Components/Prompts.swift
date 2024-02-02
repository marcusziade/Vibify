import Foundation

struct Prompts {
    // GPT-Vision Prompt
    // Purpose: To generate a playlist that mirrors the mood and aura of a given image.
    // The system accepts an image as input and outputs a playlist of 20-30 songs, closely matching the image's atmosphere.
    // The output should be a numbered list of songs, with no explanations required.
    static let visionPrompt: String =
"""
Examine the provided image, paying close attention to its mood, colors, setting, themes, and emotions.
Based on these observations, compile a playlist of 20-30 songs that resonate with the image's essence.
Each song selected should reflect aspects of the image's emotional tone, energy, and thematic elements,
creating a comprehensive audio counterpart to the visual stimulus.
Present your selections as a numbered list, specifying the title and artist for each song.
Avoid any commentary about your choices, allowing the playlist to communicate the connection to the image on its own.

1.
2.
3.
...
20. (Continue to 30 as needed)

This playlist should serve as an immersive extension of the image, bridging sight and sound to enhance the viewer's experience.
"""
}
