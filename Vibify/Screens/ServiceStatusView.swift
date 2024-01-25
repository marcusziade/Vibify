import Foundation
import SwiftUI

struct ServiceStatusView: View {
    
    @State private var engines: [Engine] = []
    
    var body: some View {
        NavigationView {
            List(engines, id: \.id) { engine in
                Label(
                    engine.id,
                    systemImage: engine.ready ? "checkmark.circle.fill" : "xmark.circle.fill"
                )
                .foregroundColor(engine.ready ? .green : .red)
            }
            .navigationTitle("Engines")
            .task {
                await status()
            }
        }
    }
    
    private func status() async {
        guard let apiKey = ProcessInfo.processInfo.environment["API_KEY"] else {
            fatalError("No API key")
        }
        
        let endpoint = EnginesEndpoint(apiKey: apiKey)
        guard let request = endpoint.urlRequest else {
            fatalError("Invalid request")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                fatalError("Unexpected status code \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
            }
            
            let enginesResponse = try JSONDecoder().decode(EnginesResponse.self, from: data)
            debugPrint(enginesResponse)
            engines = enginesResponse.data
        } catch {
            debugPrint("Error: \(error)")
        }
    }
}

#Preview {
    ServiceStatusView()
}
