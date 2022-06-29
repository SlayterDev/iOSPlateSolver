//
//  URLRequestExtension.swift
//  PlateSolver
//
//  Created by Brad Slayter on 6/28/22.
//

import Foundation

extension URLRequest {
    
    /**
     Configures the URL request for `application/x-www-form-urlencoded` data. The request's `httpBody` is set, and values are set for HTTP header fields `Content-Type` and `Content-Length`.
     
     - Parameter queryItems: The (name, value) pairs to encode and set as the request's body.
     
     - Note: The default `httpMethod` is `GET`, and `GET` requests do not typically have a body. Remember to set the `httpMethod` to e.g. `POST` before sending the request.
     
     - Warning: It is a programmer error if any name or value in `queryItems` contains an unpaired UTF-16 surrogate.
     */
    mutating func setFormURLEncoded(_ queryItems: [URLQueryItem]) {
        setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        func serialize(_ s: String) -> String {
            return s
            // Force-unwrapping because only known failure case is unpaired surrogate, which we've documented above as an error.
                .addingPercentEncoding(withAllowedCharacters: formURLEncodedAllowedCharacters)!
                .replacingOccurrences(of: " ", with: "+")
        }
        
        // https://url.spec.whatwg.org/#concept-urlencoded-serializer
        let output = queryItems.lazy
            .map { ($0.name, $0.value ?? "") }
            .map { (serialize($0), serialize($1)) }
            .map { "\($0)=\($1)" }
            .joined(separator: "&")
        
        let data = output.data(using: .utf8)
        httpBody = data
        
        if let contentLength = data?.count {
            setValue(String(contentLength), forHTTPHeaderField: "Content-Length")
        }
    }
    
    /**
     Configures the URL request for `multipart/form-data`. The request's `httpBody` is set, and a value is set for the HTTP header field `Content-Type`.
     
     - Parameter parameters: The form data to set.
     - Parameter encoding: The encoding to use for the keys and values.
     
     - Throws: `MultipartFormDataEncodingError` if any keys or values in `parameters` are not entirely in `encoding`.
     
     - Note: The default `httpMethod` is `GET`, and `GET` requests do not typically have a response body. Remember to set the `httpMethod` to e.g. `POST` before sending the request.
     - Seealso: https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#multipart-form-data
     */
    public mutating func setMultipartFormData(_ parameters: [String: Any], encoding: String.Encoding) throws {
        
        let makeRandom = { UInt32.random(in: (.min)...(.max)) }
        let boundary = String(format: "------------------------%08X%08X", makeRandom(), makeRandom())
        
        let contentType: String = try {
            guard let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)) else {
                throw MultipartFormDataEncodingError.characterSetName
            }
            return "multipart/form-data; charset=\(charset); boundary=\(boundary)"
        }()
        addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        httpBody = {
            var body = Data()
            
            for (rawName, rawValue) in parameters {
                if !body.isEmpty {
                    body.append("\r\n".data(using: .utf8)!)
                }
                
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                
                if rawValue as? String != nil {
                    body.append("Content-Type: text/plain\r\n".data(using: .utf8)!)
                } else {
                    body.append("Content-Type: application/octet-stream\r\n".data(using: .utf8)!)
                }
                
                var disposition = "Content-Disposition: form-data; name=\"\(rawName)\""
                if rawValue as? Data != nil {
                    disposition += "; filename=\"SolveMe-\(Date().timeIntervalSince1970)\""
                }
                disposition += "\r\n"
                body.append(disposition.data(using: .utf8)!)
                
                body.append("\r\n".data(using: .utf8)!)
                
                let dataValue: Data?
                if let value = rawValue as? String {
                    dataValue = value.data(using: encoding)
                } else {
                    dataValue = rawValue as? Data
                }
                
                if let dataValue = dataValue {
                    body.append(dataValue)
                }
            }
            
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            return body
        }()
    }
}

public enum MultipartFormDataEncodingError: Error {
    case characterSetName
    case name(String)
    case value(String, name: String)
}

private let formURLEncodedAllowedCharacters: CharacterSet = {
    typealias c = UnicodeScalar
    
    // https://url.spec.whatwg.org/#urlencoded-serializing
    var allowed = CharacterSet()
    allowed.insert(c(0x2A))
    allowed.insert(charactersIn: c(0x2D)...c(0x2E))
    allowed.insert(charactersIn: c(0x30)...c(0x39))
    allowed.insert(charactersIn: c(0x41)...c(0x5A))
    allowed.insert(c(0x5F))
    allowed.insert(charactersIn: c(0x61)...c(0x7A))
    
    // and we'll deal with ` ` later…
    allowed.insert(" ")
    
    return allowed
}()
