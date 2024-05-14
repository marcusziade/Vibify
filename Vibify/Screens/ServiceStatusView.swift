import Foundation
import SwiftUI

struct ServiceStatusView: View {
    
    @State var engines: [Engine] = []
    
    var body: some View {
        NavigationView {
            List(engines, id: \.id) { engine in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label(
                            engine.id,
                            systemImage: "gearshape.fill"
                        )
                        .font(.headline)
                        .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if engine.ready {
                            Text("Ready")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("Not Ready")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    if let owner = engine.owner {
                        Text("Owner: \(owner)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let permissions = engine.permissions {
                        Text("Permissions: \(permissions)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let created = engine.created {
                        Text("Created: \(dateText(for: created))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .listRowSeparator(.hidden)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            }
            .listStyle(.plain)
            .refreshable {
                await status()
            }
            .navigationTitle("Service Status")
        }
        .task {
            await status()
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
    
    private func dateText(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let created = dateFormatter.string(from: date)
        return created
    }

    private var openAIKey: String? {
#if targetEnvironment(simulator)
        return EnvironmentItem.openAIKey.rawValue
#endif
        return ProcessInfo.processInfo.environment["API_KEY"]
    }
}

#Preview {
    ServiceStatusView(engines: Engine.mocks)
}
