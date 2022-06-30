//
//  APIModel.swift
//  PlateSolver
//
//  Created by Brad Slayter on 6/29/22.
//

import Foundation

struct AuthResponse: Codable {
    let session: String
}

struct SubmissionResponse: Codable {
    let subid: Int
}

struct SubmissionStatusResponse: Codable {
    let jobCalibrations: [[Int]]
    
    enum CodingKeys: String, CodingKey {
        case jobCalibrations = "job_calibrations"
    }
}
