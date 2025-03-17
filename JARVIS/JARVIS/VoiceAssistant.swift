import AVFoundation
import Foundation

class VoiceAssistant {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoice.speechVoices().first { $0.gender == .female }?.identifier ?? AVSpeechSynthesisVoice.speechVoices().first!.identifier)
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }

    func respondToCommand(_ command: String) {
        if command.lowercased().contains("viernes") {
            speak("Sí, Jefe, ¿en qué puedo ayudarle?")
        } else {
            searchInternet(for: command)
        }
    }

    private func searchInternet(for query: String) {
        let apiKey = "TU_API_KEY" // Usa Bing Search API o Google Custom Search
        let searchUrl = "https://api.bing.microsoft.com/v7.0/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        var request = URLRequest(url: URL(string: searchUrl)!)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.speak("Lo siento, Jefe, no pude encontrar la respuesta.")
                print("Error en la búsqueda: \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let webPages = json["webPages"] as? [String: Any],
                  let value = webPages["value"] as? [[String: Any]],
                  let firstResult = value.first,
                  let snippet = firstResult["snippet"] as? String else {
                self.speak("No encontré una respuesta para eso, Jefe.")
                return
            }

            self.speak(snippet)
        }
        task.resume()
    }
}
