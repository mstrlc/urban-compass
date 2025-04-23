//
//  AttractionsModels.swift
//  urbancompass
//
//  Created by Matyáš Strelec on 19.04.2025.
//

import Foundation

struct ApiResponse: Decodable {
    let attractions: [Attraction]
    
    enum CodingKeys: String, CodingKey {
        case attractions = "features"
    }
}

struct Attraction: Decodable {
    let attributes: Attributes
    
    enum CodingKeys: String, CodingKey {
        case attributes
    }
}

struct Attributes: Decodable, Identifiable {
    var id: String { UUID().uuidString }

    let name: String?
    let text: String?
    let image: String?
    let url: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case name, text, image, url, address, latitude, longitude
    }
}

extension URLSession {
    func fetchAttractions(at url: URL, completion: @escaping (Result<[Attributes], Error>) -> Void) {
        self.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                let noDataError = NSError(domain: "DataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server."])
                DispatchQueue.main.async { completion(.failure(noDataError)) }
                return
            }

            do {
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                let attributesArray = apiResponse.attractions.map { $0.attributes }

                DispatchQueue.main.async {
                    completion(.success(attributesArray))
                }
            } catch let decoderError {
                DispatchQueue.main.async {
                    completion(.failure(decoderError))
                }
            }
        }.resume()
    }
}
