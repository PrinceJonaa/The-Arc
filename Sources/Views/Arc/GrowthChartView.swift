import Charts
import SwiftData
import SwiftUI

/// Stock-market-style growth chart of flame scores over 30/60/90 days.
struct GrowthChartView: View {
  @Query(sort: \FlameCheckIn.date)
  private var allCheckIns: [FlameCheckIn]

  @State private var selectedRange: TimeRange = .thirtyDays

  enum TimeRange: String, CaseIterable, Identifiable {
    case thirtyDays = "30D"
    case sixtyDays = "60D"
    case ninetyDays = "90D"

    var id: String { rawValue }

    var days: Int {
      switch self {
      case .thirtyDays: 30
      case .sixtyDays: 60
      case .ninetyDays: 90
      }
    }
  }

  private var filteredCheckIns: [FlameCheckIn] {
    let calendar = Calendar.current
    let cutoff = calendar.date(byAdding: .day, value: -selectedRange.days, to: .now) ?? .now
    return allCheckIns.filter { $0.date >= cutoff }
  }

  private var averageScore: Double {
    guard !filteredCheckIns.isEmpty else { return 0 }
    let total = filteredCheckIns.reduce(0) { $0 + $1.score }
    return Double(total) / Double(filteredCheckIns.count)
  }

  private var trend: String {
    guard filteredCheckIns.count >= 5 else { return "Gathering data…" }
    let halfIndex = filteredCheckIns.count / 2
    let firstHalf = filteredCheckIns.prefix(halfIndex)
    let secondHalf = filteredCheckIns.suffix(halfIndex)

    let firstAvg = Double(firstHalf.reduce(0) { $0 + $1.score }) / Double(firstHalf.count)
    let secondAvg = Double(secondHalf.reduce(0) { $0 + $1.score }) / Double(secondHalf.count)

    if secondAvg > firstAvg + 0.5 {
      return "📈 Trending up"
    } else if secondAvg < firstAvg - 0.5 {
      return "📉 Dipping — but dips are normal"
    } else {
      return "📊 Holding steady"
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      header
      chartContent
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Growth Chart")
          .font(.headline.weight(.semibold))
          .foregroundStyle(.primary)
        Spacer()
        Picker("Range", selection: $selectedRange) {
          ForEach(TimeRange.allCases) { range in
            Text(range.rawValue).tag(range)
          }
        }
        .pickerStyle(.segmented)
        .frame(width: 180)
      }

      HStack(spacing: 16) {
        VStack(alignment: .leading) {
          Text(String(format: "%.1f", averageScore))
            .font(.title.weight(.bold))
            .foregroundStyle(.primary)
          Text("Avg flame")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        Text(trend)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }

  private var chartContent: some View {
    Group {
      if filteredCheckIns.isEmpty {
        emptyChart
      } else {
        chart
      }
    }
  }

  private var emptyChart: some View {
    VStack(spacing: 8) {
      Image(systemName: "chart.line.uptrend.xyaxis")
        .font(.largeTitle)
        .foregroundStyle(.quaternary)
      Text("Check in daily to see your arc")
        .font(.caption)
        .foregroundStyle(.tertiary)
    }
    .frame(height: 200)
    .frame(maxWidth: .infinity)
  }

  private var chart: some View {
    Chart(filteredCheckIns) { checkIn in
      LineMark(
        x: .value("Date", checkIn.date),
        y: .value("Flame", checkIn.score)
      )
      .foregroundStyle(
        LinearGradient(
          colors: [.orange, .red],
          startPoint: .leading,
          endPoint: .trailing
        )
      )
      .interpolationMethod(.catmullRom)

      AreaMark(
        x: .value("Date", checkIn.date),
        y: .value("Flame", checkIn.score)
      )
      .foregroundStyle(
        LinearGradient(
          colors: [.orange.opacity(0.3), .clear],
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .interpolationMethod(.catmullRom)
    }
    .chartYScale(domain: 0...10)
    .chartYAxis {
      AxisMarks(values: [0, 5, 10])
    }
    .frame(height: 200)
  }
}
