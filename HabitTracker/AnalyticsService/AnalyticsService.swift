import AppMetricaCore

struct AnalyticsService {
    static func initialise() {
        guard let configuration = AppMetricaConfiguration(apiKey: "5855bedc-08aa-43ca-bacb-aa2e7a40337c") else { return }
        AppMetrica.activate(with: configuration)
    }
    
    static func reportEvent(name: String, params: [String : String]) {
        AppMetrica.reportEvent(name: name, parameters: params, onFailure: { error in
            print("[AnalyticsService]:", error.localizedDescription)
        })
    }
}

