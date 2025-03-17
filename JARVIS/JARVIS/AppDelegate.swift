import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Registrar tareas en segundo plano
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jarvis.backgroundTask", using: nil) { task in
            self.handleBackgroundTask(task as! BGProcessingTask)
        }
        return true
    }

    func handleBackgroundTask(_ task: BGProcessingTask) {
        scheduleBackgroundTask() // Volver a programar la tarea

        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            // Aquí se ejecutará la lógica para revisar el correo
            self.checkForMeetings()

            task.setTaskCompleted(success: true)
        }
    }

    func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: "com.jarvis.backgroundTask")
        request.requiresNetworkConnectivity = true
        request.earliestBeginDate = Date(timeIntervalSinceNow: 300) // Cada 5 minutos

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Error al programar la tarea en segundo plano: \(error)")
        }
    }

    func checkForMeetings() {
        // Aquí se llamará a la API de Gmail o Outlook
        print("Revisando correo para detectar reuniones...")
    }
}
