import SwiftUI

struct TrackingView: View {
    @Binding var isPresented: Bool
    @ObservedObject private var telemetryManager = TelemetryManager.shared
    @State private var isTracking = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: 0x0A0C15).ignoresSafeArea()

                VStack(spacing: 20) {
                    trackingMetrics

                    startStopButton
                }
            }
            .navigationTitle("Ride Tracking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    private var trackingMetrics: some View {
        VStack(spacing: 20) {
            MetricView(title: "G-Force", value: String(format: "%.2f", telemetryManager.gForceZ), unit: "g")
            MetricView(title: "Lateral G", value: String(format: "%.2f", telemetryManager.lateralG), unit: "g")
            MetricView(title: "Speed", value: String(format: "%.0f", telemetryManager.speed), unit: "mph")
            MetricView(title: "Airtime", value: "\(telemetryManager.airtimeMoments)", unit: "moments")
            MetricView(title: "Heart Rate", value: "\(telemetryManager.heartRate)", unit: "bpm")
        }
    }

    private var startStopButton: some View {
        Button(action: {
            isTracking.toggle()
            if isTracking {
                telemetryManager.startTracking()
            } else {
                // Add stop tracking functionality here
            }
        }) {
            Text(isTracking ? "Stop Tracking" : "Start Tracking")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isTracking ? Color.red : Color(hex: 0x545DDF))
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .padding(.horizontal)
    }
}

struct MetricView: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            HStack(alignment: .lastTextBaseline, spacing: 5) {
                Text(value)
                    .font(.system(size: 36, weight: .bold))
                Text(unit)
                    .font(.subheadline)
            }
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: 0x181920))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

