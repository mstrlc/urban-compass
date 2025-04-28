//
//  AttractionsModels.swift
//  urbancompass
//
//  Created by Matyáš Strelec on 22.04.2025.
//

import Foundation
import CoreLocation

extension String {
    /// Attempts to unescape HTML entities within the string.
    /// - Returns: A new string with HTML entities decoded, or the original string if decoding fails.
    func unescapingHTMLEntities() -> String {

        guard let data = self.data(using: .utf8) else {
            return self // Return original string if UTF8 conversion fails
        }

        // Define options for NSAttributedString initialization
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue // Specify UTF-8 encoding
        ]

        // Try to initialize NSAttributedString from the HTML data
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string // Return the plain string representation
        } else {
            return self // Return original string if NSAttributedString initialization fails
        }
    }
}

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

struct Attributes: Decodable, Identifiable, Hashable {
    var id: UUID
    
    let name: String?
    let text: String?
    let image: String?
    let url: String?
    let address: String?
    let street: String?
    let city: String?
    let phone: String?
    let email: String?
    let latitude: Double?
    let longitude: Double?
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "GlobalID"
        case street = "address_street"
        case city = "address_city"
        case phone = "contact_phone"
        case email = "contact_email"
        case name, text, image, url, address, latitude, longitude
    }
    
    init(id: UUID, name: String?, text: String?, image: String?, url: String?, address: String?, street: String?, city: String?, phone: String?, email: String?, latitude: Double?, longitude: Double?) {
        self.id = id
        self.name = name
        self.text = text
        self.image = image
        self.url = url
        self.address = address
        self.street = street
        self.city = city
        self.phone = phone
        self.email = email
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedId = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        let decodedName = try container.decodeIfPresent(String.self, forKey: .name)?.unescapingHTMLEntities()
        let decodedText = try container.decodeIfPresent(String.self, forKey: .text)?.unescapingHTMLEntities()
        let decodedImage = try container.decodeIfPresent(String.self, forKey: .image)
        let decodedUrl = try container.decodeIfPresent(String.self, forKey: .url)
        let decodedAddress = try container.decodeIfPresent(String.self, forKey: .address)?.unescapingHTMLEntities()
        let decodedStreet = try container.decodeIfPresent(String.self, forKey: .street)?.unescapingHTMLEntities()
        let decodedCity = try container.decodeIfPresent(String.self, forKey: .city)?.unescapingHTMLEntities()
        let decodedPhone = try container.decodeIfPresent(String.self, forKey: .phone)?.unescapingHTMLEntities()
        let decodedEmail = try container.decodeIfPresent(String.self, forKey: .email)?.unescapingHTMLEntities()
        let decodedLatitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        let decodedLongitude = try container.decodeIfPresent(Double.self, forKey: .longitude)

        self.init(
            id: decodedId,
            name: decodedName,
            text: decodedText,
            image: decodedImage,
            url: decodedUrl,
            address: decodedAddress,
            street: decodedStreet,
            city: decodedCity,
            phone: decodedPhone,
            email: decodedEmail,
            latitude: decodedLatitude,
            longitude: decodedLongitude
        )
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
