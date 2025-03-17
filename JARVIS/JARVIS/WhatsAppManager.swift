import Foundation

class WhatsAppManager {
    private let apiUrl = "https://graph.facebook.com/v17.0/TU_NUMERO_DE_WHATSAPP/messages"
    private let accessToken = "TU_ACCESS_TOKEN"
    private let phoneNumberId = "TU_PHONE_NUMBER_ID"

    func fetchLatestMessages(completion: @escaping (String) -> Void) {
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion("Error al obtener mensajes de WhatsApp: \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let messages = json["messages"] as? [[String: Any]] else {
                completion("No se recibieron datos válidos de WhatsApp")
                return
            }

            var summary = "Resumen de mensajes de WhatsApp: "
            for message in messages.prefix(5) { // Tomamos los últimos 5 mensajes
                if let from = message["from"] as? String, let text = message["text"] as? [String: String], let body = text["body"] {
                    summary += "\n- \(from): \(body.prefix(50))..." // Muestra solo los primeros 50 caracteres
                }
            }

            completion(summary)
        }
        task.resume()
    }
}
