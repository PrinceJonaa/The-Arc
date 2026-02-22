import Foundation
import UserNotifications

/// Manages local notification scheduling for morning/evening reminders.
@MainActor
final class NotificationManager: ObservableObject {
  @Published var morningEnabled = false {
    didSet { reschedule() }
  }
  @Published var eveningEnabled = false {
    didSet { reschedule() }
  }
  @Published var morningTime: Date = defaultMorningTime() {
    didSet { reschedule() }
  }
  @Published var eveningTime: Date = defaultEveningTime() {
    didSet { reschedule() }
  }
  @Published var isAuthorized = false

  private let center = UNUserNotificationCenter.current()

  static let morningID = "com.thearc.morning-flame"
  static let eveningID = "com.thearc.evening-reflection"

  // MARK: - Permissions

  func requestPermission() async {
    do {
      let granted = try await center.requestAuthorization(
        options: [.alert, .sound, .badge]
      )
      isAuthorized = granted
    } catch {
      isAuthorized = false
    }
  }

  func checkAuthorizationStatus() async {
    let settings = await center.notificationSettings()
    isAuthorized = settings.authorizationStatus == .authorized
  }

  // MARK: - Scheduling

  func reschedule() {
    center.removeAllPendingNotificationRequests()

    if morningEnabled && isAuthorized {
      scheduleMorning()
    }
    if eveningEnabled && isAuthorized {
      scheduleEvening()
    }
  }

  private func scheduleMorning() {
    let content = UNMutableNotificationContent()
    content.title = "🔥 Daily Flame"
    content.body = morningPrompt()
    content.sound = .default

    let components = Calendar.current.dateComponents(
      [.hour, .minute], from: morningTime
    )
    let trigger = UNCalendarNotificationTrigger(
      dateMatching: components, repeats: true
    )

    let request = UNNotificationRequest(
      identifier: Self.morningID,
      content: content,
      trigger: trigger
    )
    center.add(request)
  }

  private func scheduleEvening() {
    let content = UNMutableNotificationContent()
    content.title = "📝 Evening Reflection"
    content.body = eveningPrompt()
    content.sound = .default

    let components = Calendar.current.dateComponents(
      [.hour, .minute], from: eveningTime
    )
    let trigger = UNCalendarNotificationTrigger(
      dateMatching: components, repeats: true
    )

    let request = UNNotificationRequest(
      identifier: Self.eveningID,
      content: content,
      trigger: trigger
    )
    center.add(request)
  }

  // MARK: - Prompts

  private func morningPrompt() -> String {
    [
      "How aligned does today feel with why you started?",
      "Your flame is waiting. How are you burning today?",
      "Take 30 seconds to check in with yourself.",
      "The person you're becoming — what would they do today?",
      "Rate your alignment. Build the data. Own your arc.",
    ].randomElement() ?? "How aligned does today feel?"
  }

  private func eveningPrompt() -> String {
    [
      "Before today slips away, capture what mattered.",
      "One sentence about today — that's all it takes.",
      "Your future self wants to know how today felt.",
      "The best data is honest data. How was today?",
      "Speak or write — just capture the truth of today.",
    ].randomElement() ?? "Capture what mattered today."
  }

  // MARK: - Defaults

  private static func defaultMorningTime() -> Date {
    var components = DateComponents()
    components.hour = 9
    components.minute = 0
    return Calendar.current.date(from: components) ?? .now
  }

  private static func defaultEveningTime() -> Date {
    var components = DateComponents()
    components.hour = 20
    components.minute = 0
    return Calendar.current.date(from: components) ?? .now
  }
}
