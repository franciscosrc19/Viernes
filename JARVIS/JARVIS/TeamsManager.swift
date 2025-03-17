import Foundation

class TeamsManager {
    private let clientId = "TU_CLIENT_ID"
    private let clientSecret = "TU_CLIENT_SECRET"
    private let tenantId = "TU_TENANT_ID"
    private let accessTokenUrl = "https://login.microsoftonline.com/\(tenantId)/oauth2/v2.0/token"
    private let messagesUrl = "https://graph.microsoft.com/v1.0/me/chats/getAllMessages"

    func fetchTeamsMessages(completion: @escaping (String) -> Void) {
        getAccessToken { token in
            guard let token = token else {
                completion("No se pudo obtener el token de acceso")
                return
            }
            
            var request = URLRequest(url: URL(string: self.messagesUrl)!)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion("Error al obtener mensajes: \(error.localizedDescription)")
                    return
                }

                guard let data = data, let jsonString = String(data: data, encoding: .utf8) else {
                    completion("No se recibieron datos válidos")
                    return
                }

                completion("Mensajes recientes de Teams: \(jsonString)")
            }
            task.resume()
        }
    }

    private func getAccessToken(completion: @escaping (String?) -> Void) {
        var request = URLRequest(url: URL(string: accessTokenUrl)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "client_id=\(clientId)&client_secret=\(clientSecret)&scope=https://graph.microsoft.com/.default&grant_type=client_credentials"
        request.httpBody = body.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error al obtener token: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let token = json["access_token"] as? String else {
                completion(nil)
                return
            }

            completion(token)
        }
        task.resume()
    }
}
