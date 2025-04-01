import AppMetricaCore

struct AnalyticsService {
    static func initialise() {
        guard let configuration = AppMetricaConfiguration(apiKey: Constants.metricaApiKey ) else { return }
        AppMetrica.activate(with: configuration)
    }
    
    static func reportEvent(name: String, params: [String : String]) {
        AppMetrica.reportEvent(name: name, parameters: params, onFailure: { error in
            print("[AnalyticsService]:", error.localizedDescription)
        })
    }
}

