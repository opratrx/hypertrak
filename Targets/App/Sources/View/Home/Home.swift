//
//  ScrollIntoSheet.swift
//  (c) Théo Arrouye 2024
//
//


import SwiftUI
import CoreMotion
import HealthKit

class TelemetryManager: ObservableObject {
    static let shared = TelemetryManager()

    private let motionManager = CMMotionManager()
    private let healthStore = HKHealthStore()

    @Published var gForceZ: Double = 0.0
    @Published var lateralG: Double = 0.0
    @Published var speed: Double = 0.0
    @Published var airtimeMoments: Int = 0
    @Published var heartRate: Int = 0

    func startTracking() {
        startMotionTracking()
        startHeartRateTracking()
    }

    private func startMotionTracking() {
        motionManager.startDeviceMotionUpdates(to: .main) { data, error in
            guard let motion = data else { return }

            let acceleration = motion.userAcceleration
            self.gForceZ = acceleration.z * 9.81  // Convert to m/s²
            self.lateralG = motion.rotationRate.y * 9.81
        }
    }

    private func startHeartRateTracking() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { _, completionHandler, _ in
            self.fetchHeartRate()
            completionHandler()
        }
        healthStore.execute(query)
    }

    private func fetchHeartRate() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: nil) { _, results, _ in
            if let sample = results?.first as? HKQuantitySample {
                self.heartRate = Int(sample.quantity.doubleValue(for: .count().unitDivided(by: .minute())))
            }
        }
        healthStore.execute(query)
    }
}

struct HomeView: View {
  let backgroundColor: Color = .black
  let sheetColor: Color = .white

  @State var offset: CGFloat = 0

  @State var viewHeight: CGFloat = 0
  @State var headerHeight: CGFloat = 0
  @State var headerHeight2: CGFloat = 0
  @State var contentOffset: CGFloat = 0

  @State var safeAreaInsets: EdgeInsets = EdgeInsets()

  @State private var scrollPosition = ScrollPosition(edge: .top)

  let data = SectionData.getMockData()

  var sheetOpenFactor: CGFloat = 2.0

  var sheetHeight: CGFloat {
    let defaultHeight = viewHeight - headerHeight
    let offset = contentOffset > 0 ? contentOffset * sheetOpenFactor : contentOffset
    let maximumHeight = viewHeight + safeAreaInsets.top

    return max(0, min(maximumHeight, defaultHeight + offset))
  }

  var sheetAtTopOffset: CGFloat {
    (headerHeight + safeAreaInsets.top) / sheetOpenFactor
  }

  var scrollHeaderPadding: CGFloat {
    let offsetToUse = min(contentOffset, sheetAtTopOffset)
    let neededPadding = headerHeight2 - (headerHeight - offsetToUse)
    let clamped = max(0, neededPadding)
    return clamped + 10 /// add 10 to give a little extra padding inside our 'sheet' always
  }

  var secondHeaderOffset: CGFloat {
    max(0, contentOffset - sheetAtTopOffset)
  }

  var body: some View {
    ZStack(alignment: .top) {
      // (1) back everything with sheet color going behind safe areas
      sheetColor
        .ignoresSafeArea(edges: .all)
        .zIndex(0)

      // (2) above that, put the top half background color, going behind the top safe area
      // (not the bottom edge since we will see that behind the sheet)
      backgroundColor
        .ignoresSafeArea(edges: .top)
        .zIndex(1)

      // (3) The header for when the sheet is closed
      HeaderView(style: .sheetClosed)
        // (4) We observe the size of this view to do some calculations with
        .onGeometryChange(for: CGFloat.self) { proxy in
          proxy.size.height
        } action: { newHeight in
          headerHeight = newHeight
        }
        // (5) Put it on top when the sheet is closed so it can be interacted with
        .zIndex(contentOffset > 0 ? 2 : 6)

      // (6) The sheet itself
      sheet
        .zIndex(3)

      // (7) Our scroll view
      ScrollView(.vertical, showsIndicators: false) {
        // (8) Stub for header space in scrollview
        Color.clear
          .frame(height: headerHeight)
          // (9) This padding makes sure the bottom content aligns with the headers
          // in either state (see the property to see the maths)
          .padding(.bottom, scrollHeaderPadding)

        // (10) The sheet content
        ForEach(data, id: \.title) { data in
          SectionView(data: data)
        }
      }
      // (11) Observe the scroll content offset to drive our UI between states
      .onScrollGeometryChange(for: CGFloat.self) { geometry in
        geometry.contentOffset.y + geometry.contentInsets.top
      } action: { _, newOffset in
        contentOffset = newOffset
      }
      // (12) Automatically close/open the sheet if user lets go between states
      .onScrollPhaseChange { old, new in
        guard old != new, new == .idle else { return }
        scrollToNearestSheetPosition()
      }
      // (13) This is how we will drive the offset of the scrollview programatically
      .scrollPosition($scrollPosition)
      .zIndex(4)

      // (14) The header for when the sheet is open
      HeaderView(style: .sheetOpen)
        // (15) We observe the size of this view to do some calculations with
        .onGeometryChange(for: CGFloat.self) { proxy in
          proxy.size.height
        } action: { newHeight in
          headerHeight2 = newHeight
        }
        .frame(maxHeight: .infinity, alignment: .top)
        // (16) We mask this view with our sheet so that it appears on top of the old one as the
        // sheet passes it
        .mask {
          sheet
        }
        // (17) Since this header isn't actually inside the scroll view, we need
        // to offset it ourselves when it should scroll.
        .offset(y: -secondHeaderOffset)
        .zIndex(5)
    }
    // (18) We observe the height and safe area of the full view
    // in order to use in our calculations
    .onGeometryChange(for: CGFloat.self) { proxy in
      proxy.size.height
    } action: { newHeight in
      if newHeight > viewHeight {
        viewHeight = newHeight
      }
    }
    .onGeometryChange(for: EdgeInsets.self) { proxy in
      proxy.safeAreaInsets
    } action: { newInsets in
        guard safeAreaInsets == EdgeInsets() else { return }
      safeAreaInsets = newInsets
    }
  }

  private var sheet: some View {
    Color.clear
      .ignoresSafeArea()
      .background(alignment: .bottom) {
        sheetColor
          .clipShape(
            .rect(cornerRadii:
                .init(
                  topLeading: 30,
                  bottomLeading: 0,
                  bottomTrailing: 0,
                  topTrailing: 30
                )
            )
          )
          .frame(height: sheetHeight)
          .overlay(alignment: .top) {
            // (19) Display the grabber
            Capsule()
              .foregroundStyle(.secondary).colorScheme(.dark)
              .frame(width: 60, height: 5)
              .offset(y: -15)
              .opacity(contentOffset > 0 ? 0 : 1) // (19b) only if the sheet is closed
          }
      }
  }

  private func scrollToNearestSheetPosition() {
    // only do this if the sheet is between states
    guard contentOffset > 0, contentOffset < sheetAtTopOffset else {
      return
    }

    // scroll to open/close which is closest
    let target = contentOffset > sheetAtTopOffset / 2 ? sheetAtTopOffset : 0
    withAnimation(.spring) {
      scrollPosition.scrollTo(y: target)
    }
  }
}

// MARK: - Header view (sheet open/closed variants)
struct HeaderView: View {

  enum Style {
    case sheetClosed
    case sheetOpen

    fileprivate var colorScheme: ColorScheme {
      switch self {
      case .sheetOpen: .light
      case .sheetClosed: .dark
      }
    }
  }

  let style: Style

  var body: some View {
    VStack {
      header

      switch style {
      case .sheetOpen:
        addNewButton
      case .sheetClosed:
        MetricsView()
      }
    }
    .colorScheme(style.colorScheme)
    .padding(.bottom)
  }

  private var header: some View {
    VStack(alignment: .leading) {
      Text("HyperTrak")
        .foregroundStyle(.primary)
      Text("Analytics")
        .foregroundStyle(.secondary)
        .font(.title.bold())
    }
    .font(.largeTitle.bold())
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal)
  }

  @State private var isShowingAlert: Bool = false

    private var addNewButton: some View {
        Button(action: {
            TelemetryManager.shared.startTracking()
        }) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .shadow(color: .black.opacity(0.2), radius: 6)
                .overlay {
                    Text("Start Tracking")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }
        }
        .padding()
    }
}

// MARK: Metrics View
struct MetricsView: View {
    @ObservedObject var telemetryManager = TelemetryManager.shared

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                MetricCellView(metric: Metric(title: "G-Force", symbolName: "chart.xyaxis.line", count: Int(telemetryManager.gForceZ), letter: "G"))
                MetricCellView(metric: Metric(title: "Lateral G", symbolName: "rotate.3d", count: Int(telemetryManager.lateralG), letter: "G"))
                MetricCellView(metric: Metric(title: "Speed", symbolName: "speedometer", count: Int(telemetryManager.speed), letter: "MPH"))
                MetricCellView(metric: Metric(title: "Airtime", symbolName: "hare", count: telemetryManager.airtimeMoments, letter: "Moments"))
                MetricCellView(metric: Metric(title: "Heart Rate", symbolName: "heart", count: telemetryManager.heartRate, letter: "BPM"))
            }
            .padding()
        }
    }
}

struct MetricCellView: View {
  let metric: Metric

  var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      Image(systemName: metric.symbolName)
        .font(.largeTitle)
        .foregroundStyle(.secondary)

      Spacer()

        Text("\(metric.count) \(metric.letter)")
        .font(.headline.bold())
        .foregroundStyle(.white)

      Text(metric.title)
        .font(.headline)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
    .padding()
    .frame(width: 140, height: 140, alignment: .leading)
    .background(Color(UIColor.systemGray5))
    .clipShape(.rect(cornerRadius: 15))
  }
}

// MARK: - Bottom List Subviews
struct SectionView: View {
  let data: SectionData

  var body: some View {
    Section {
      ForEach(data.items, id: \.self) { col in
        ListCellView(color: col)
      }
    } header: {
      if let title = data.title {
        Text(title)
          .font(.headline)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.top)
      }
    }
    .padding(.horizontal)
  }
}

struct ListCellView: View {
  let color: Color

  var body: some View {
    HStack {
      color
        .frame(width: 60, height: 60)
        .clipShape(.rect(cornerRadius: 10))

      VStack(alignment: .leading) {
        Text("LORUM IPSUM")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        Text("Lorum ipsum dolor and other things")
          .lineLimit(1)
          .font(.headline)
          .foregroundStyle(.primary)

        Text("Lorum")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.white)
    .clipShape(.rect(cornerRadius: 10))
    .shadow(color: .black.opacity(0.2), radius: 6)
  }
}

// MARK: - Data Models & Mock Data
struct Metric {
  let title: LocalizedStringKey
  let symbolName: String
  let count: Int
  let letter: String
}

extension Metric {
  static func getMockData() -> [Metric] {
    [
        .init(title: "G-Force", symbolName: "chart.xyaxis.line", count: 4, letter: "G"),
        .init(title: "Lateral G", symbolName: "rotate.3d", count: 1, letter: "G"),
        .init(title: "Speed", symbolName: "speedometer", count: 300, letter: "MPH"),
        .init(title: "Airtime", symbolName: "hare", count: 0, letter: "Moments")
    ]
  }
}

struct SectionData {
  let title: String?
  let items: [Color]
}

extension SectionData {
  static func getMockData() -> [SectionData] {
    [
      .init(title: nil, items: [.blue, .green]),
      .init(title: "December 01", items: [.red, .yellow, .orange]),
      .init(title: "November 31", items: [.purple, .pink, .black, .gray, .blue, .green])
    ]
  }
}

// MARK: - Preview
#Preview {
  HomeView()
}
