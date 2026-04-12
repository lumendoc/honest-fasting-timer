import Foundation

actor GeminiWrapper {
    private let apiKey: String
    private let baseURL = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent")!
    
    init(apiKey: String = AppConfig.geminiApiKey) {
        self.apiKey = apiKey
    }
    
    func generate(prompt: String, systemInstruction: String? = nil) async throws -> String {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var contents: [[String: Any]] = []
        if let system = systemInstruction {
            contents.append(["role": "user", "parts": [["text": system]]])
        }
        contents.append(["role": "user", "parts": [["text": prompt]]])
        
        let body: [String: Any] = [
            "contents": contents,
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 1024
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GeminiError.apiError(String(data: data, encoding: .utf8) ?? "Unknown")
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let first = candidates.first,
              let content = first["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else {
            throw GeminiError.decodingFailed
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    enum GeminiError: Error {
        case apiError(String)
        case decodingFailed
    }
}
