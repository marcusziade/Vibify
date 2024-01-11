import SwiftUI

struct NumberOfSongsCounterView: View {
    @Binding var numberOfSongs: Int
    let range: ClosedRange<Int> = 1...25
    let step: Int = 5
    
    var body: some View {
        VStack {
            Text("Number of Songs")
                .font(.headline)
                .padding(.bottom, 8)
            
            HStack(spacing: 20) {
                Button(action: {
                    withAnimation(animationStyle) {
                        decrementValue()
                    }
                }) {
                    Image(systemName: "minus.circle")
                        .font(.largeTitle)
                        .foregroundColor(
                            numberOfSongs > range.lowerBound ? .blue : .gray
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(numberOfSongs == range.lowerBound)
                
                Text("\(numberOfSongs)")
                    .font(.title)
                    .frame(minWidth: 40, alignment: .center)
                    .padding(.horizontal, 12)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button(action: {
                    withAnimation(animationStyle) {
                        incrementValue()
                    }
                }) {
                    Image(systemName: "plus.circle")
                        .font(.largeTitle)
                        .foregroundColor(
                            numberOfSongs < range.upperBound ? .blue : .gray
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(numberOfSongs == range.upperBound)
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    private var animationStyle: Animation {
        Animation.snappy
    }
    
    private func incrementValue() {
        if numberOfSongs < range.upperBound {
            numberOfSongs += step
            if numberOfSongs == 6 {
                numberOfSongs = 5
            }
        }
    }
    
    private func decrementValue() {
        if numberOfSongs > range.lowerBound {
            numberOfSongs -= step
            if numberOfSongs == 0 {
                numberOfSongs = 1
            }
        }
    }
}

// Custom Button Style for a scaling effect on press
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

#Preview {
    NumberOfSongsCounterView(numberOfSongs: .constant(0))
}
