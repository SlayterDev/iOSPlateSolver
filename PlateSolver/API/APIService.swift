//
//  APIService.swift
//  PlateSolver
//
//  Created by Brad Slayter on 6/27/22.
//

import Foundation

class APIService: ObservableObject {
    struct Constants {
        static let apiKey = "apiKey"
        static let apiBase = "http://nova.astrometry.net/api/"
        static let annotatedBase = "http://nova.astrometry.net/annotated_display/"
        static let statusBase = "http://nova.astrometry.net/status/"
        
        static let sessionKey = "sessionKey"
        static let lastSubmission = "lastSubmission"
    }
    
    enum SubmissionStatus: String {
        case notStarted = "Not Started"
        case processing = "Processing"
        case done = "Done"
    }
    
    enum ErrorState: String {
        case noAPIKey = "No API Key"
        case unauthorized = "Invalid API Key"
    }
    
    var subId: Int?
    @Published var status: SubmissionStatus = .notStarted
    @Published var solvedUrl: String?
    @Published var errorState: ErrorState?
    
    var apiKey: String? {
        didSet {
            login()
        }
    }
    
    var timer: Timer?
    
    init() {
        if let key = UserDefaults().string(forKey: Constants.apiKey) {
            self.apiKey = key
        } else {
            errorState = .noAPIKey
        }
    }
    
    func apiUrl(withPath path: String) -> URL {
        return URL(string: Constants.apiBase + path)!
    }
    
    func login() {
        guard let apiKey = apiKey else {
            return
        }
        
        errorState = nil
        var request = URLRequest(url: apiUrl(withPath: "login"))
        request.httpMethod = "POST"
        request.setFormURLEncoded([URLQueryItem(name: "request-json", value: "{\"apikey\": \"\(apiKey)\"}")])
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else {
                print("No data returned")
                print(error?.localizedDescription ?? "No error")
                self?.errorState = .unauthorized
                return
            }
            
            do {
                let json = try JSONDecoder().decode(AuthResponse.self, from: data)
                print(json)
                
                UserDefaults().set(json.session, forKey: Constants.sessionKey)
            } catch {
                print(error)
                self?.errorState = .unauthorized
            }
        }
        
        task.resume()
    }
    
    func uploadImage(_ image: Data) {
        timer?.invalidate()
        guard let sessionKey = UserDefaults().string(forKey: Constants.sessionKey) else {
            login()
            return
        }
        
        var request = URLRequest(url: apiUrl(withPath: "upload"))
        request.httpMethod = "POST"
        
        do {
            try request.setMultipartFormData([
                "request-json": "{\"publicly_visible\": \"y\", \"allow_modifications\": \"d\", \"session\": \"\(sessionKey)\", \"allow_commercial_use\": \"d\"}",
                "file": image
            ], encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data else {
                print("No data returned")
                print(error?.localizedDescription ?? "No error")
                return
            }
            
            do {
                let json = try JSONDecoder().decode(SubmissionResponse.self, from: data)
                print(json)
                
                DispatchQueue.main.async {
                    self.status = .processing
                    self.subId = json.subid
                    UserDefaults().set(self.subId, forKey: Constants.lastSubmission)
                    self.timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
                        self?.updateSubmissionStatus()
                    }
                }
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    func updateSubmissionStatus() {
        guard let subId = subId, subId != 0 else {
            return
        }
        
        let request = URLRequest(url: apiUrl(withPath: "submissions/\(subId)"))
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data else {
                print("No data returned")
                print(error?.localizedDescription ?? "No error")
                return
            }
            
            do {
                let json = try JSONDecoder().decode(SubmissionStatusResponse.self, from: data)
                print(json)
                let calibrations = json.jobCalibrations
                if calibrations.count > 0 {
                    DispatchQueue.main.async {
                        self.timer?.invalidate()
                        self.status = .done
                        if let jobId = calibrations.first?.first {
                            self.solvedUrl = "\(Constants.annotatedBase)\(jobId)"
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    func currentSubUrl() -> URL? {
        guard let subId = subId else {
            return nil
        }

        return URL(string: "\(Constants.statusBase)\(subId)")
    }
}
