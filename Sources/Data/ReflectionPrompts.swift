import Foundation

/// Curated prompt banks for daily reflections, weekly mirror questions, and dip-recovery messages.
enum ReflectionPrompts {
  // MARK: - Daily Reflections (phase-aware)

  /// General daily prompts — phase-specific prompts can layer on top.
  static let daily: [String] = [
    "What would the version of you that you're becoming do today?",
    "What's one thing you can do today that your future self will thank you for?",
    "If today were the only evidence of who you are, what would it say?",
    "What are you avoiding that you know matters?",
    "What would you do today if no one could judge the outcome?",
    "What's the gap between what you did yesterday and what you said you'd do?",
    "What's the one thing you'd regret not doing today?",
    "What would courage look like today — specifically?",
    "Where are you performing instead of being real?",
    "What did you learn yesterday that changes how you move today?",
    "If this week were a chapter in your story, what would the title be?",
    "What's pulling your attention away from what matters most?",
    "When did you last feel fully alive? What were you doing?",
    "What would it look like to honor your calling today — not perfectly, just honestly?",
    "What's the hardest truth you're not saying out loud?",
    "If you removed fear from the equation, what would you do differently today?",
    "What's one habit that's serving your future self? What's one that isn't?",
    "Are you building, or are you just busy?",
    "What would peace look like today?",
    "The person you want to become — are your actions today voting for them?",
    "What's one thing you're grateful for that you usually take for granted?",
    "If your mission had a heartbeat, how strong would it be today?",
    "What's the most honest thing you can say about where you are right now?",
    "Who did you let affect your mood yesterday — and why?",
    "What does alignment feel like to you? Did you feel it yesterday?",
    "What would you tell yourself if you were your own mentor?",
    "Where are you settling for comfort when discomfort would grow you?",
    "What are you creating today that didn't exist yesterday?",
    "What's the difference between who you are and who you pretend to be?",
    "If you stripped away everyone else's expectations, what would remain?",
  ]

  // MARK: - Weekly Mirror Questions

  static let mirror: [String] = [
    "What would you do if no one was watching and nothing was guaranteed?",
    "Who affected your mood most this week — and why did you let them?",
    "Your actions last week — do they belong to the person you said you are?",
    "What pattern keeps showing up in your life that you haven't fully addressed?",
    "If your week were a stock chart, what caused the dips — and what caused the rises?",
    "What truth are you dancing around instead of sitting with?",
    "What did you give your energy to this week that didn't deserve it?",
    "What would the person you're becoming think about how you spent this week?",
    "Where did you feel the most resistance this week? What's underneath it?",
    "What did you avoid thinking about this week — and what's there?",
    "If someone watched your week without hearing your words, what would they say your priorities are?",
    "What's the one thing you need to carry into next week — and what do you need to leave behind?",
  ]

  // MARK: - Dip Recovery Messages

  static let dipRecovery: [String] = [
    "Even Apple dipped. You're still a great stock.",
    "The chart dips. That's what charts do. It doesn't stop being a great stock because of a bad Tuesday.",
    "This dip is data, not a verdict. Great stocks always recover.",
    "Every meaningful journey passes through low points. You're still on the arc.",
    "The abyss isn't the end of the story — it's the scene right before the breakthrough.",
    "Your worth isn't measured in single days. Zoom out. The trend is still up.",
    "A dip is not a failure. It's the space between who you were and who you're becoming.",
    "The flame flickers. That doesn't mean the fire is gone.",
    "Rest is not regression. Sometimes the strongest thing you can do is pause.",
    "You're not falling behind. You're gathering momentum for the next surge.",
  ]

  // MARK: - Helpers

  /// Returns a daily prompt — optionally seeded by date for consistency within a day.
  static func dailyPrompt(for date: Date = .now) -> String {
    let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
    return daily[dayOfYear % daily.count]
  }

  /// Returns a weekly mirror prompt — rotates by week number.
  static func weeklyMirror(for date: Date = .now) -> String {
    let weekOfYear = Calendar.current.component(.weekOfYear, from: date)
    return mirror[weekOfYear % mirror.count]
  }

  /// Returns a random dip-recovery message.
  static func randomDipRecovery() -> String {
    dipRecovery.randomElement() ?? dipRecovery[0]
  }
}
