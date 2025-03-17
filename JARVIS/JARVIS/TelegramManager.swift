import Foundation

class TelegramManager {
    private let botToken = "TU_BOT_TOKEN"
    private let chatId = "TU_CHAT_ID"
    private let apiUrl = "https://api.telegram.org/bot"

    func fetchLatestMessages(completion: @escaping (String) -> Void) {
        let url = URL(string: "\(apiUrl)\(botToken)/getUpdates")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion("Error al obtener mensajes de Telegram: \(error.localizedDescription)")
                return
            }

            guard let data = data, let jsonString = String(data: data, encoding: .utf8) else {
                completion("No se recibieron datos válidos de Telegram")
                return
            }

            completion("Mensajes recientes de Telegram: \(jsonString)")
        }
        task.resume()
    }
}
