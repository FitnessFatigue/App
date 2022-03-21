//
//  DataStructure.swift
//  Intervals (iOS)
//
//  Created by Matthew Roche on 22/11/2021.
//

import Foundation
import RealmSwift
import SwiftUI

// Holds details of each individual activity
class Activity: Object, Decodable, Identifiable {
    @Persisted var id: Int
    @Persisted var date: Date
    @Persisted var name: String?
    @Persisted var type: String?
    @Persisted var movingTime: Int?
    @Persisted var distance: Int?
    @Persisted var elapsedTime: Int?
    @Persisted var totalElevationGain: Int?
    @Persisted var maxSpeed: Double?
    @Persisted var averageSpeed: Double?
    @Persisted var hasHeartrate: Bool?
    @Persisted var maxHeartrate: Int?
    @Persisted var averageHeartrate: Int?
    @Persisted var calories: Int?
    @Persisted var averageWatts: Int?
    @Persisted var normalisedWatts: Int?
    @Persisted var intensity: Int?
    @Persisted var estimatedFTP: Int?
    @Persisted var variability: Double?
    @Persisted var efficiency: Double?
    @Persisted var trainingLoad: Float?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: Int, date: Date, name: String? = nil, type: String? = nil, movingTime: Int? = nil, distance: Int? = nil, elapsedTime: Int? = nil, totalElevationGain: Int? = nil, maxSpeed: Double? = nil, averageSpeed: Double? = nil, hasHeartrate: Bool? = nil, maxHeartrate: Int? = nil, averageHeartrate: Int? = nil, calories: Int? = nil, averageWatts: Int? = nil, normalisedWatts: Int? = nil, intensity: Int? = nil, estimatedFTP: Int? = nil, variability: Double? = nil, efficiency: Double? = nil, trainingLoad: Float? = nil) {
        self.init()
        self.id = id
        self.date = date
        self.name = name
        self.type = type
        self.movingTime = movingTime
        self.distance = distance
        self.elapsedTime = elapsedTime
        self.totalElevationGain = totalElevationGain
        self.maxSpeed = maxSpeed
        self.averageSpeed = averageSpeed
        self.hasHeartrate = hasHeartrate
        self.maxHeartrate = maxHeartrate
        self.averageHeartrate = averageHeartrate
        self.calories = calories
        self.averageWatts = averageWatts
        self.intensity = intensity
        self.estimatedFTP = estimatedFTP
        self.variability = variability
        self.efficiency = efficiency
        self.trainingLoad = trainingLoad
        self.trainingLoad = trainingLoad
    }
    
    // Enable decoding from JSON
    required convenience init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let idString = try values.decode(String.self, forKey: .id)
        guard let id = Int(idString) else {
            throw ActivityError.InvalidId
        }
        
        let dateString = try values.decode(String.self, forKey: .start_date_local)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        guard let date = dateFormatter.date(from: dateString) else {
            throw ActivityError.InvalidDate
        }
        
        let name = try? values.decode(String.self, forKey: .name)
        let type = try? values.decode(String.self, forKey: .type)
        let movingTime = try? values.decode(Int.self, forKey: .moving_time)
        let distance = try? values.decode(Int.self, forKey: .distance)
        let elapsedTime = try? values.decode(Int.self, forKey: .elapsed_time)
        let elevationGain = try? values.decode(Int.self, forKey: .total_elevation_gain)
        let maxSpeed = try? values.decode(Double.self, forKey: .max_speed)
        let averageSpeed = try? values.decode(Double.self, forKey: .average_speed)
        let hasHeartrate = try? values.decode(Bool.self, forKey: .has_heartrate)
        let maxHeartrate = try? values.decode(Int.self, forKey: .max_heartrate)
        let averageHeartrate = try? values.decode(Int.self, forKey: .average_heartrate)
        let calories = try? values.decode(Int.self, forKey: .calories)
        let averageWatts = try? values.decode(Int.self, forKey: .icu_average_watts)
        let intensity = try? values.decode(Int.self, forKey: .icu_intensity)
        let estimatedFTP = try? values.decode(Int.self, forKey: .icu_eftp)
        let variability = try? values.decode(Double.self, forKey: .icu_variability_index)
        let efficiency = try? values.decode(Double.self, forKey: .icu_efficiency_factor)
        let trainingLoad = try? values.decode(Float.self, forKey: .icu_training_load)
        
        self.init(id: id, date: date, name: name, type: type, movingTime: movingTime, distance: distance, elapsedTime: elapsedTime, totalElevationGain: elevationGain, maxSpeed: maxSpeed, averageSpeed: averageSpeed, hasHeartrate: hasHeartrate, maxHeartrate: maxHeartrate, averageHeartrate: averageHeartrate, calories: calories, averageWatts: averageWatts, intensity: intensity, estimatedFTP: estimatedFTP, variability: variability, efficiency: efficiency, trainingLoad: trainingLoad)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case start_date_local
        case name
        case type
        case moving_time
        case distance
        case elapsed_time
        case total_elevation_gain
        case max_speed
        case average_speed
        case has_heartrate
        case max_heartrate
        case average_heartrate
        case calories
        case icu_average_watts
        case icu_intensity
        case icu_eftp
        case icu_variability_index
        case icu_efficiency_factor
        case icu_training_load
    }
    
    // Returns training load correctly formatted
    var formattedTrainingLoad: String {
        guard let trainingLoad = trainingLoad else {
            return "-"
        }
        return String(trainingLoad)
    }
    
    // Handles errors
    public enum ActivityError: Error, LocalizedError {
        case InvalidId
        case InvalidDate
        
        // User readable format, user doesn't need great detail
        public var errorDescription: String? {
            return NSLocalizedString("Unable to create activity", comment: "")
        }
    }
    
}


// Holds graphable details for each day
class DailyValues: Object {
    // To ensure no duplicates we create an ID for each day
    // This must be a string for Realm to accept it as a primary key, dates and doubles are unacceptable
    @Persisted private var id: String = ""
    @Persisted var date: Date = Date()
    @Persisted var totalTrainingLoad: Float = 0.0
    @Persisted var fitness: Float = 0.0
    @Persisted var fatigue: Float = 0.0
    
    convenience init(date: Date, totalTrainingLoad: Float, fitness: Float, fatigue: Float) {
        self.init()
        
        // Create our ID
        let dateToStore = Calendar.current.startOfDay(for: date)
        self.id = String(dateToStore.timeIntervalSince1970)
        
        self.date = dateToStore
        self.totalTrainingLoad = totalTrainingLoad
        self.fitness = fitness
        self.fatigue = fatigue
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // Returns the form for the given day
    var form: Float {
        return fitness - fatigue
    }
    
    // Returns the correct colour for the form on a given day.
    var formColor: Color {
        if form > 5 {
            return Color.blue
        } else if form < -30 {
            return Color.red
        } else if form < -10 {
            return Color.green
        } else {
            return Color.gray
        }
    }
}

// Holds details of errors that we create. This is necessary to enabble equatable and identifiable errors
class AppError: Error, Equatable, Identifiable {
    
    var id: UUID
    var error: Error
    
    // Create an ID during init
    init(_ error: Error) {
        self.id = UUID()
        self.error = error
    }
    
    // Compare the IDs for equality.
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.id == rhs.id
    }
    
    var localizedDescription: String {
        return error.localizedDescription
    }
}


// Holds the user's profile data
class UserProfile: Codable {
    
    var id: String = ""
    var firstName: String?
    var lastName: String?
    var email: String?
    var sex: String?
    var dateOfBirth: Date?
    var authToken: String = ""
    
    required convenience init(id: String, firstName: String? = nil, lastName: String? = nil, email: String? = nil, sex: String? = nil, dateOfBirth: Date? = nil, authToken: String) {
        self.init()
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.sex = sex
        self.dateOfBirth = dateOfBirth
        self.authToken = authToken
    }
    
    // Enable decoding from JSON
    required convenience init(from decoder: Decoder) throws {
        
        print("Decoding")
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try values.decode(String.self, forKey: .id)
        let firstName = try? values.decode(String.self, forKey: .firstname)
        let lastName = try? values.decode(String.self, forKey: .lastname)
        let email = try? values.decode(String.self, forKey: .email)
        let sex = try? values.decode(String.self, forKey: .sex)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateOfBirthString = try? values.decode(String.self, forKey: .icu_date_of_birth)
        var dateOfBirth: Date? = nil
        if dateOfBirthString != nil {
            dateOfBirth = formatter.date(from: dateOfBirthString!)
        }
        
        print(id, firstName, lastName, email, sex, dateOfBirth)
        
        let authToken = try values.decode(String.self, forKey: .icu_api_key)
        
        self.init(id: id, firstName: firstName, lastName: lastName, email: email, sex: sex, dateOfBirth: dateOfBirth, authToken: authToken)
        
    }
    
    // Enable encoding to JSON for storage in keychain
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(authToken, forKey: .icu_api_key)
        if firstName != nil {
            try container.encode(firstName, forKey: .firstname)
        }
        if lastName != nil {
            try container.encode(lastName, forKey: .lastname)
        }
        if email != nil {
            try container.encode(email, forKey: .email)
        }
        if sex != nil {
            try container.encode(sex, forKey: .sex)
        }
        if dateOfBirth != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateOfBirthString = formatter.string(from: dateOfBirth!)
            try container.encode(dateOfBirthString, forKey: .icu_date_of_birth)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstname
        case lastname
        case email
        case sex
        case icu_date_of_birth
        case icu_api_key
    }
    
}

// A wrapper for the UserProfile object to enable access to child within JSON response
struct RawServerLoginResponse: Decodable {
    var athlete: UserProfile
}

// An observable object containing a dictionary of dates and training loads
public class TrainingLoadValues: ObservableObject {
    @Published var values: [Date: Float] = [:]
    
    init(values: [Date: Float] = [:]) {
        self.values = values
    }
}
