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
    @Persisted var id: String
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
    @Persisted var normalizedWatts: Int?
    @Persisted var normalisedWatts: Int?
    @Persisted var intensity: Double?
    @Persisted var estimatedFTP: Int?
    @Persisted var variability: Double?
    @Persisted var efficiency: Double?
    @Persisted var trainingLoad: Float?
    @Persisted var fitness: Float?
    @Persisted var fatigue: Float?
    @Persisted var form: Float?
    @Persisted var workOverFTP: Float?
    @Persisted var FTP: Float?
    @Persisted var rideEFTP: Float?
    @Persisted var work: Float?
    @Persisted var pace: Float?
    @Persisted var gap: Float?
    @Persisted var cadence: Float?
    @Persisted var stride: Float?
    @Persisted var source: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: String, date: Date, name: String? = nil, type: String? = nil, movingTime: Int? = nil, distance: Int? = nil, elapsedTime: Int? = nil, totalElevationGain: Int? = nil, maxSpeed: Double? = nil, averageSpeed: Double? = nil, hasHeartrate: Bool? = nil, maxHeartrate: Int? = nil, averageHeartrate: Int? = nil, calories: Int? = nil, averageWatts: Int? = nil, normalizedWatts: Int? = nil, intensity: Double? = nil, estimatedFTP: Int? = nil, variability: Double? = nil, efficiency: Double? = nil, trainingLoad: Float? = nil, fitness: Float? = nil, fatigue: Float? = nil, form: Float? = nil, workOverFTP: Float? = nil, FTP: Float? = nil, rideFTP: Float? = nil, kCal: Float? = nil, work: Float? = nil, pace: Float? = nil, gap: Float? = nil, cadence: Float? = nil, stride: Float? = nil, source: String? = nil) {
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
        self.normalizedWatts = normalizedWatts
        self.intensity = intensity
        self.estimatedFTP = estimatedFTP
        self.variability = variability
        self.efficiency = efficiency
        self.trainingLoad = trainingLoad
        self.fitness = fitness
        self.fatigue = fatigue
        self.form = form
        self.workOverFTP = workOverFTP
        self.FTP = FTP
        self.rideEFTP = rideEFTP
        self.work = work
        self.pace = pace
        self.gap = gap
        self.cadence = cadence
        self.stride = stride
        self.source = source
    }
    
    // Enable decoding from JSON
    required convenience init(from decoder: Decoder) throws {
        
        guard let values = try? decoder.container(keyedBy: CodingKeys.self) else {
            throw ActivityError.InvalidValues
        }
        
        guard let id = try? values.decode(String.self, forKey: .id) else {
            throw ActivityError.InvalidId
        }
        
        let dateString = try values.decode(String.self, forKey: .start_date_local)
        // This takes the date string (which can be in a variety of formats) and parses it for a date
        guard let date = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
            .firstMatch(in: dateString, range: NSMakeRange(0, dateString.count))?.date else {
            throw ActivityError.InvalidDate
        }
        // Old date parsing using fixed format
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
//        guard let date = dateFormatter.date(from: dateString) else {
//            throw ActivityError.InvalidDate
//        }
        
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
        let normalizedWatts = try? values.decode(Int.self, forKey: .icu_weighted_avg_watts)
        let intensity = try? values.decode(Double.self, forKey: .icu_intensity)
        let estimatedFTP = try? values.decode(Int.self, forKey: .icu_eftp)
        let variability = try? values.decode(Double.self, forKey: .icu_variability_index)
        let efficiency = try? values.decode(Double.self, forKey: .icu_efficiency_factor)
        let trainingLoad = try? values.decode(Float.self, forKey: .icu_training_load)
        let fitness = try? values.decode(Float.self, forKey: .icu_ctl)
        let fatigue = try? values.decode(Float.self, forKey: .icu_atl)
        var form: Float? = nil
        if fitness != nil && fatigue != nil {
            form = fitness! - fatigue!
        }
        let FTP = try? values.decode(Float.self, forKey: .icu_ftp)
        let rideEFTP = try? values.decode(Float.self, forKey: .icu_pm_ftp)
        let work = try? values.decode(Float.self, forKey: .icu_joules)
        let workOverFTP = try? values.decode(Float.self, forKey: .icu_joules_above_ftp)
        let pace = try? values.decode(Float.self, forKey: .pace)
        let gap = try? values.decode(Float.self, forKey: .gap)
        let cadence = try? values.decode(Float.self, forKey: .average_cadence)
        let stride = try? values.decode(Float.self, forKey: .average_stride)
        let source = try? values.decode(String.self, forKey: .source)
        
        self.init(id: id, date: date, name: name, type: type, movingTime: movingTime, distance: distance, elapsedTime: elapsedTime, totalElevationGain: elevationGain, maxSpeed: maxSpeed, averageSpeed: averageSpeed, hasHeartrate: hasHeartrate, maxHeartrate: maxHeartrate, averageHeartrate: averageHeartrate, calories: calories, averageWatts: averageWatts, normalizedWatts: normalizedWatts, intensity: intensity, estimatedFTP: estimatedFTP, variability: variability, efficiency: efficiency, trainingLoad: trainingLoad, fitness: fitness, fatigue: fatigue, form: form, workOverFTP: workOverFTP, FTP: FTP, rideFTP: rideEFTP, work: work, pace: pace, gap: gap, cadence: cadence, stride: stride, source: source)
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
        case icu_weighted_avg_watts
        case icu_intensity
        case icu_eftp
        case icu_variability_index
        case icu_efficiency_factor
        case icu_training_load
        case icu_atl
        case icu_ctl
        case icu_ftp
        case icu_pm_ftp // ride eFTP
        case icu_joules
        case icu_joules_above_ftp
        case pace
        case gap
        case average_cadence
        case average_stride
        case source
    }
    
    func convertMetersPerSecToMinPerKm(value: Float) -> String? {
        let metersPerSecond = Measurement(value: Double(value), unit: UnitSpeed.metersPerSecond)
        let kmPerHour = metersPerSecond.converted(to: UnitSpeed.kilometersPerHour).value
        let kmPerSecond = kmPerHour / 60 / 60
        let secondsPerKm = TimeInterval(1 / kmPerSecond)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: secondsPerKm)
    }
    
    // Returns the distance correctly formatted
    var formattedDistance: String {
        guard let distance = distance else {
            return "-"
        }
        var distanceMeters = Measurement<UnitLength>(value: Double(distance), unit: UnitLength.meters)
        if distance > 999 {
            distanceMeters.convert(to: UnitLength.kilometers)
            return distanceMeters.description
        } else {
            return distanceMeters.description
        }
    }
    
    // Returns training load correctly formatted
    var formattedTrainingLoad: String {
        guard let trainingLoad = trainingLoad else {
            return "-"
        }
        return String(trainingLoad)
    }
    
}

// Handles errors
public enum ActivityError: Error, LocalizedError {
    case InvalidValues
    case InvalidId
    case InvalidDate
    
    public var errorDescription: String? {
        switch self {
        case .InvalidValues:
            return "Values"
        case .InvalidId:
            return "Id"
        case .InvalidDate:
            return "Date"
        }
    }
}

// Holds graphable details for each day
class DailyValues: Object, Decodable {
    // To ensure no duplicates we create an ID for each day
    // This must be a string for Realm to accept it as a primary key, dates and doubles are unacceptable
    @Persisted private var id: String = ""
    @Persisted var date: Date = Date()
    @Persisted var fitness: Float = 0.0
    @Persisted var fatigue: Float = 0.0
    @Persisted var rampRate: Float = 0.0
    @Persisted var ctlLoad: Float = 0.0
    @Persisted var atlLoad: Float = 0.0
    
    convenience init(date: Date, fitness: Float, fatigue: Float, rampRate: Float, ctlLoad: Float, atlLoad: Float) {
        self.init()
        
        // Create our ID
        let dateToStore = Calendar.current.startOfDay(for: date)
        self.id = String(dateToStore.timeIntervalSince1970)
        
        self.date = dateToStore
        self.fitness = fitness
        self.fatigue = fatigue
        self.rampRate = rampRate
        self.ctlLoad = ctlLoad
        self.atlLoad = atlLoad
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // Enable decoding from JSON
    required convenience init(from decoder: Decoder) throws {

        guard let values = try? decoder.container(keyedBy: CodingKeys.self) else {
            throw WellnessError.InvalidValues
        }

        //The id is stored as a date
        guard let id = try? values.decode(String.self, forKey: .id) else {
            throw WellnessError.InvalidId
        }
        guard let date = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
            .firstMatch(in: id, range: NSMakeRange(0, id.count))?.date else {
            throw WellnessError.InvalidDate
        }

        guard let fitness = try? values.decode(Float.self, forKey: .atl) else {
            throw WellnessError.InvalidFitness
        }
        guard let fatigue = try? values.decode(Float.self, forKey: .ctl) else {
            throw WellnessError.InvalidFatigue
        }
        guard let rampRate = try? values.decode(Float.self, forKey: .rampRate) else {
            throw WellnessError.InvalidRampRate
        }
        guard let ctlLoad = try? values.decode(Float.self, forKey: .ctlLoad) else {
            throw WellnessError.InvalidCTLLoad
        }
        guard let atlLoad = try? values.decode(Float.self, forKey: .atlLoad) else {
            throw WellnessError.InvalidATLLoad
        }

        self.init(date: date, fitness: fitness, fatigue: fatigue, rampRate: rampRate, ctlLoad: ctlLoad, atlLoad: atlLoad)
    }
    
    // Handles errors
    public enum WellnessError: Error, LocalizedError {
        case InvalidValues
        case InvalidId
        case InvalidDate
        case InvalidFitness
        case InvalidFatigue
        case InvalidRampRate
        case InvalidCTLLoad
        case InvalidATLLoad
        
        public var errorDescription: String? {
            switch self {
            case .InvalidValues:
                return "Values"
            case .InvalidId:
                return "Id"
            case .InvalidDate:
                return "Date"
            case .InvalidFitness:
                return "Fitness"
            case .InvalidFatigue:
                return "Fatigue"
            case .InvalidRampRate:
                return "Ramp Rate"
            case .InvalidCTLLoad:
                return "CTL Load"
            case .InvalidATLLoad:
                return "ATL Load"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case ctl
        case atl
        case rampRate
        case ctlLoad
        case atlLoad
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
    var name: String?
    var email: String?
    var sex: String?
    var dateOfBirth: Date?
    var authToken: String = ""
    
    required convenience init(id: String, name: String? = nil, email: String? = nil, sex: String? = nil, dateOfBirth: Date? = nil, authToken: String) {
        self.init()
        self.id = id
        self.name = name
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
        let name = try? values.decode(String.self, forKey: .name)
        let email = try? values.decode(String.self, forKey: .email)
        let sex = try? values.decode(String.self, forKey: .sex)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateOfBirthString = try? values.decode(String.self, forKey: .icu_date_of_birth)
        var dateOfBirth: Date? = nil
        if dateOfBirthString != nil {
            dateOfBirth = formatter.date(from: dateOfBirthString!)
        }
        
        let authToken = try values.decode(String.self, forKey: .icu_api_key)
        
        self.init(id: id, name: name, email: email, sex: sex, dateOfBirth: dateOfBirth, authToken: authToken)
        
    }
    
    // Enable encoding to JSON for storage in keychain
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(authToken, forKey: .icu_api_key)
        if name != nil {
            try container.encode(name, forKey: .name)
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
        case name
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
