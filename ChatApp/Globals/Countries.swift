//
//  Countries.swift
//  SwiftChats
//
//  Created by Alexsander  on 4/10/16.
//  Copyright © 2016 Alexsander Khitev. All rights reserved.
//

import Foundation

public class Countries {
    
    // MARK: - var and let
    private static let selectedCountryName = "selectedCountryName"
    private static let selectedCountryPhoneExtension = "selectedCountryPhoneExtension"
    private static let selectedCountryisMain = "selectedCountryisMain"
    private static let selectedCountryCode = "selectedCountryCode"
    private static let countryIsSelected = "countryIsSelected"
    public static let isSelected = NSUserDefaults.standardUserDefaults().boolForKey("countryIsSelected")
    
    // MARK: - functions
    
    public static func getAllCountries() -> [Country] {
        var countries = [Country]()
        NSLocale.ISOCountryCodes().forEach { (isoCode) in
            guard let countryName = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: isoCode) else { return }
            if let countryInfo = countryInfoDictionary[isoCode] {
                let phoneExtension = countryInfo["phoneExtension"] as! String
                let isMain = countryInfo["isMain"] as! Bool
                countries.append(Country(name: countryName, phoneExtension: phoneExtension, countryCode: isoCode, isMain: isMain))
            } else {
                countries.append(Country(name: countryName, phoneExtension: nil, countryCode: isoCode, isMain: nil))
            }
        }
        return countries
    }
    
    public static func getCountriesByAlphabet() -> [(String, [Country])] {
        let countries = getAllCountries()
        var countryDictionary = [String : [Country]]()
        var countryFirstLetterArray = [String]()
        
        countries.forEach { (country) in
            let letterIndex = country.name.startIndex.advancedBy(0)
            countryFirstLetterArray.append(String(country.name[letterIndex]))
            if countryFirstLetterArray.count == 249 {
                countryFirstLetterArray = Array(Set(countryFirstLetterArray))
                
                countryFirstLetterArray.sortInPlace({ (firstString, secondString) -> Bool in
                    firstString < secondString
                })
            }
        }
        
        //
        countryFirstLetterArray.forEach { (letter) in
            countries.forEach({ (country) in
                let letterIndex = country.name.startIndex.advancedBy(0)
                let firsNameLetter = String(country.name[letterIndex])
                if firsNameLetter == letter {
                    if var countries = countryDictionary[letter] {
                        countries.append(country)
                        countryDictionary[letter] = countries
                    } else {
                        countryDictionary[letter] = [country]
                    }
                }
            })
        }
        
        // sorting
        let returnedCountries = countryDictionary.sort({$0.0 < $1.0})
        
        return returnedCountries
    }
    
    public static func getCountriesWithPhone() -> [Country] {
        var countries = getCountriesWithPhoneCode()
        countries.sortInPlace({$0.name < $1.name})
        return countries
    }
    
    public static func getCountriesByPhoneCode() -> [Country] {
        var countries = getCountriesWithPhoneCode()
        countries.sortInPlace({$0.phoneExtension! < $1.phoneExtension})
        return countries
    }
    
    private static func getCountriesWithPhoneCode() -> [Country] {
        let countries = getAllCountries()
        var returnedCountries = [Country]()
        countries.forEach { (country) in
            if country.phoneExtension != nil {
                returnedCountries.append(country)
            }
        }
        return returnedCountries
    }
    
    
    public static func getDeviceSelectedCountry() -> Country? {
        var index = 0
        var countryCode = ""
        
        NSLocale.currentLocale().localeIdentifier.characters.forEach { (character) in
            index += 1
            if index > 3 {
                countryCode.append(character)
            }
        }
        
        guard let currentCountryName = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: countryCode) else { return nil }
        
        var currentCountry: Country!
        getAllCountries().forEach { (country) in
            if country.name == currentCountryName {
                currentCountry = country
            }
        }
        return currentCountry
    }
    
    // MARK: - save and get country
    
    public static func saveSelectedCountry(country: Country) {
        NSUserDefaults.standardUserDefaults().setObject(country.name, forKey: selectedCountryName)
        if country.phoneExtension != nil {
            NSUserDefaults.standardUserDefaults().setObject(country.phoneExtension!, forKey: "selectedCountryPhoneExtension")
        }
        if country.isMain != nil {
            NSUserDefaults.standardUserDefaults().setBool(country.isMain!, forKey: selectedCountryisMain)
        }
        NSUserDefaults.standardUserDefaults().setObject(country.countryCode, forKey: selectedCountryCode)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: countryIsSelected)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public static func getSelectedCountry() -> Country?  {
        let isSelected = NSUserDefaults.standardUserDefaults().boolForKey(countryIsSelected)
        if isSelected {
            let countryName = NSUserDefaults.standardUserDefaults().objectForKey(selectedCountryName) as! String
            let countryCode = NSUserDefaults.standardUserDefaults().objectForKey(selectedCountryCode) as! String
            
            guard let phoneExtension = NSUserDefaults.standardUserDefaults().objectForKey(selectedCountryPhoneExtension) as? String else {
                let country = Country(name: countryName, phoneExtension: nil, countryCode: countryCode, isMain: nil)
                return country
            }
            guard let isMain = NSUserDefaults.standardUserDefaults().objectForKey(selectedCountryisMain) as? Bool else {
                let country = Country(name: countryName, phoneExtension: nil, countryCode: countryCode, isMain: nil)
                return country
            }
            let country = Country(name: countryName, phoneExtension: phoneExtension, countryCode: countryCode, isMain: isMain)
            return country
        } else {
            return nil
        }
    }
    
    public static func getCountryByPhoneCode(countryCode: String) -> Country? {
        var currentCountry: Country!
        getCountriesWithPhoneCode().forEach { (country) in
            if country.phoneExtension == countryCode && country.isMain == true {
                currentCountry = country
            }
        }
        return currentCountry
    }
}

extension Countries {
    
    public static var countryInfoDictionary = ["AF" : ["phoneExtension" : "93", "isMain" : true], "AL" : ["phoneExtension" : "355", "isMain" : true], "DZ" : ["phoneExtension" : "213", "isMain" : true], "AS" : ["phoneExtension" : "1", "isMain" : false], "AD" : ["phoneExtension" : "376", "isMain" : true], "AO" :["phoneExtension" : "244", "isMain" : true], "AI" : ["phoneExtension" : "1", "isMain" : false], "AQ" : ["phoneExtension" : "672", "isMain" : true], "AG" : ["phoneExtension" : "1", "isMain" : false], "AR" : ["phoneExtension" : "54", "isMain" : true], "AM" : ["phoneExtension" : "374", "isMain" : true], "AW" : ["phoneExtension" : "297", "isMain" : true], "AU" : ["phoneExtension" : "61", "isMain" : true], "AT" : ["phoneExtension" : "43", "isMain" : true], "AZ": ["phoneExtension" : "994", "isMain" : true], "BS" : ["phoneExtension" : "1", "isMain" : false], "BH" : ["phoneExtension" : "973", "isMain": true], "BD" : ["phoneExtension" : "880", "isMain": true], "BB" : ["phoneExtension" : "1", "isMain": false], "BY" : ["phoneExtension" : "375", "isMain" : true], "BE" : ["phoneExtension": "32", "isMain": true], "BZ" : ["phoneExtension": "501", "isMain": true], "BJ" : ["phoneExtension" : "229", "isMain" : true], "BM" : ["phoneExtension" : "1", "isMain": false], "BT" : ["phoneExtension": "975", "isMain": true], "BO" : ["phoneExtension" : "591", "isMain": true], "BA" : ["phoneExtension" : "387", "isMain" : true], "BW" : ["phoneExtension" : "267", "isMain": true], "BR" : ["phoneExtension": "55", "isMain": true], "IO" :  ["phoneExtension": "246", "isMain": true], "VG" : ["phoneExtension": "1", "isMain": false], "BN" : ["phoneExtension": "673", "isMain": true], "BG" : ["phoneExtension": "359", "isMain": true], "BF" :["phoneExtension": "226", "isMain": true], "BI" : ["phoneExtension": "257", "isMain": true], "KH" : ["phoneExtension": "855", "isMain": true], "CM" : ["phoneExtension": "237", "isMain": true], "CA" : ["phoneExtension": "1", "isMain": false], "CV" : ["phoneExtension" : "238", "isMain" : true], "KY" : ["phoneExtension" : "1", "isMain": false], "CF" : ["phoneExtension": "236", "isMain": true], "TD" : ["phoneExtension": "235", "isMain": true], "CL" : ["phoneExtension": "56", "isMain": true], "CN" : ["phoneExtension" : "86", "isMain": true], "CX" : ["phoneExtension" : "61", "isMain" : false], "CC" : ["phoneExtension" : "61", "isMain": false], "CO" : ["phoneExtension" : "57", "isMain": true], "KM" : ["phoneExtension": "269", "isMain": true], "CK" : ["phoneExtension": "682", "isMain": true], "CR" : ["phoneExtension" : "506", "isMain": true], "HR" : ["phoneExtension": "385", "isMain" : true], "CU" : ["phoneExtension": "53", "isMain": true], "CW" : ["phoneExtension": "599", "isMain": true], "CY" : ["phoneExtension" : "357", "isMain": true], "CZ" : ["phoneExtension": "420", "isMain": true], "CD" :["phoneExtension": "243", "isMain": true], "DK" : ["phoneExtension": "45", "isMain": true], "DJ" : ["phoneExtension" : "253", "isMain": true], "DM" : ["phoneExtension": "1", "isMain": false], "DO" : ["phoneExtension" : "1", "isMain": false], "TL" : ["phoneExtension": "670", "isMain": true], "EC" : ["phoneExtension" : "593", "isMain": true], "EG" : ["phoneExtension": "20", "isMain": true], "SV" : ["phoneExtension" : "503", "isMain" : true], "GQ" : ["phoneExtension" : "240", "isMain": true], "ER" : ["phoneExtension" : "291", "isMain": true], "EE" : ["phoneExtension" : "372", "isMain": true], "ET" : ["phoneExtension" : "251", "isMain": true], "FK" : ["phoneExtension" : "500", "isMain": true], "FO" : ["phoneExtension": "298", "isMain": true], "FJ" : ["phoneExtension": "679", "isMain": true], "FI" : ["phoneExtension" : "358", "isMain": true], "FR" : ["phoneExtension" : "33", "isMain" : true], "PF" : ["phoneExtension" : "689", "isMain": true], "GA" : ["phoneExtension" : "241", "isMain": true], "GM" : ["phoneExtension" : "220", "isMain" : true], "GE" : ["phoneExtension": "995", "isMain": true], "DE" : ["phoneExtension" : "49", "isMain": true], "GH" : ["phoneExtension" : "233", "isMain": true], "GI" :["phoneExtension" : "350", "isMain": true], "GR" : ["phoneExtension": "30", "isMain": true], "GL" : ["phoneExtension": "299", "isMain": true], "GD" : ["phoneExtension": "1", "isMain": false], "GU" : ["phoneExtension": "1", "isMain": false], "GT" : ["phoneExtension": "502", "isMain": true], "GG" : ["phoneExtension": "44", "isMain": false], "GN" : ["phoneExtension": "224", "isMain": true], "GW" : ["phoneExtension" : "245", "isMain": true], "GY" : ["phoneExtension": "592", "isMain": true], "HT" : ["phoneExtension": "509", "isMain": true], "HN" : ["phoneExtension": "504", "isMain": true], "HK" : ["phoneExtension": "652", "isMain": true], "HU" : ["phoneExtension": "36", "isMain": true], "IS" :["phoneExtension": "354", "isMain": true], "IN" : ["phoneExtension": "91", "isMain": true], "ID" :["phoneExtension": "62", "isMain": true], "IR" : ["phoneExtension": "98", "isMain": true], "IQ" : ["phoneExtension" : "964", "isMain" : true], "IE" : ["phoneExtension": "353", "isMain": true], "IM" : ["phoneExtension": "44", "isMain": false], "IL" : ["phoneExtension": "972", "isMain": true], "IT" : ["phoneExtension": "39", "isMain": true], "CI" : ["phoneExtension": "225", "isMain": true], "JM" : ["phoneExtension": "1", "isMain": false], "JP" : ["phoneExtension": "81", "isMain": true], "JE" : ["phoneExtension": "44", "isMain": false], "JO" : ["phoneExtension" : "962", "isMain": true], "KZ" : ["phoneExtension" : "7", "isMain": false], "KE" : ["phoneExtension" : "254", "isMain": true], "KI" : ["phoneExtension" : "686", "isMain": true], "XK" : ["phoneExtension": "383", "isMain": true], "KW" : ["phoneExtension": "965", "isMain": true], "KG" : ["phoneExtension": "996", "isMain": true], "LA" : ["phoneExtension": "856", "isMain": true], "LV" : ["phoneExtension": "371", "isMain": true], "LB" : ["phoneExtension": "961", "isMain": true], "LS" : ["phoneExtension": "266", "isMain": true], "LR" : ["phoneExtension": "231", "isMain": true], "LY" : ["phoneExtension": "218", "isMain": true], "LI" : ["phoneExtension": "423", "isMain": true], "LT" : ["phoneExtension": "370", "isMain": true], "LU" : ["phoneExtension": "352", "isMain": true], "MO" : ["phoneExtension": "853", "isMain": true], "MK" : ["phoneExtension": "389", "isMain": true], "MG" : ["phoneExtension": "261", "isMain": true], "MW" : ["phoneExtension": "265", "isMain": true], "MY" : ["phoneExtension": "60", "isMain": true], "MV" : ["phoneExtension": "960", "isMain": true], "ML" : ["phoneExtension": "223", "isMain": true], "MT" : ["phoneExtension": "356", "isMain": true], "MH" : ["phoneExtension": "692", "isMain": true], "MR" : ["phoneExtension": "222", "isMain": true], "MU" : ["phoneExtension": "230", "isMain": true], "YT" : ["phoneExtension": "262", "isMain": true], "MX" : ["phoneExtension": "52", "isMain": true], "FM" : ["phoneExtension": "691", "isMain": true], "MD" : ["phoneExtension": "373", "isMain": true], "MC" : ["phoneExtension": "377", "isMain": true], "MN" : ["phoneExtension": "976", "isMain": true], "ME" : ["phoneExtension": "382", "isMain": true], "MS" : ["phoneExtension": "1", "isMain": false], "MA" : ["phoneExtension": "212", "isMain": true], "MZ" : ["phoneExtension": "258", "isMain": true], "MM" : ["phoneExtension": "95", "isMain": true], "NA":  ["phoneExtension": "264", "isMain": true], "NR" : ["phoneExtension": "674", "isMain": true], "NP" : ["phoneExtension": "977", "isMain": true], "NL" : ["phoneExtension": "31", "isMain": true], "AN" : ["phoneExtension": "599", "isMain": true], "NC" : ["phoneExtension": "687", "isMain": true], "NZ" : ["phoneExtension": "64", "isMain": true], "NI" : ["phoneExtension": "505", "isMain": true], "NE" : ["phoneExtension": "227", "isMain": true], "NG" : ["phoneExtension": "234", "isMain": true], "NU" : ["phoneExtension": "683", "isMain": true], "KP" : ["phoneExtension": "850", "isMain": true], "MP" : ["phoneExtension": "1", "isMain": false], "NO" : ["phoneExtension": "47", "isMain": true], "OM" : ["phoneExtension": "968", "isMain": true], "PK" : ["phoneExtension": "92", "isMain": true], "PW" : ["phoneExtension": "680", "isMain": true], "PS" : ["phoneExtension": "970", "isMain": true], "PA" : ["phoneExtension": "507", "isMain": true], "PG" : ["phoneExtension": "675", "isMain": true], "PY" : ["phoneExtension": "595", "isMain": true], "PE" : ["phoneExtension": "51", "isMain": true], "PH" : ["phoneExtension": "63", "isMain": true], "PN" :["phoneExtension": "64", "isMain": false], "PL" : ["phoneExtension": "48", "isMain": true], "PT" : ["phoneExtension": "351", "isMain": true], "PR" : ["phoneExtension": "1", "isMain": false], "QA" : ["phoneExtension": "974", "isMain": true], "CG" : ["phoneExtension": "242", "isMain": true], "RE" : ["phoneExtension": "262", "isMain": false], "RO" : ["phoneExtension": "40", "isMain": true], "RU" : ["phoneExtension": "7", "isMain": true], "RW" : ["phoneExtension": "250", "isMain": true], "BL" : ["phoneExtension": "590", "isMain": true], "SH": ["phoneExtension": "290", "isMain": true], "KN" : ["phoneExtension": "1", "isMain": false], "LC" : ["phoneExtension": "1", "isMain": false], "MF" : ["phoneExtension": "590", "isMain": false], "PM" : ["phoneExtension": "508", "isMain": true], "VC": ["phoneExtension": "1", "isMain": false], "WS" : ["phoneExtension": "685", "isMain": true], "SM" : ["phoneExtension": "378", "isMain": true], "ST" : ["phoneExtension": "239", "isMain": true], "SA" : ["phoneExtension": "966", "isMain": true], "SN" : ["phoneExtension": "221", "isMain": true], "RS" : ["phoneExtension": "381", "isMain": true], "SC" : ["phoneExtension": "248", "isMain": true], "SL" : ["phoneExtension": "232", "isMain": true], "SG" : ["phoneExtension": "65", "isMain": true], "SX" : ["phoneExtension": "1", "isMain": false], "SK" : ["phoneExtension": "421", "isMain": true], "SI" : ["phoneExtension": "386", "isMain": true], "SB" : ["phoneExtension": "677", "isMain": true], "SO" : ["phoneExtension": "252", "isMain": true], "ZA" : ["phoneExtension": "27", "isMain": true], "KR" : ["phoneExtension": "82", "isMain": true], "SS" : ["phoneExtension": "211", "isMain": true], "ES" : ["phoneExtension": "34", "isMain": true], "LK" : ["phoneExtension": "94", "isMain": true], "SD" : ["phoneExtension": "249", "isMain": true], "SR" : ["phoneExtension": "597", "isMain": true], "SJ" : ["phoneExtension": "47", "isMain": true], "SZ" : ["phoneExtension": "268", "isMain": true], "SE" : ["phoneExtension": "46", "isMain": true], "CH" : ["phoneExtension": "41", "isMain": true], "SY" : ["phoneExtension": "963", "isMain": true], "TW" : ["phoneExtension": "886", "isMain": true], "TJ" : ["phoneExtension": "992", "isMain": true], "TZ" : ["phoneExtension": "255", "isMain": true], "TH" : ["phoneExtension": "66", "isMain": true], "TG": ["phoneExtension": "228", "isMain": true], "TK" : ["phoneExtension": "690", "isMain": true], "TO" : ["phoneExtension": "676", "isMain": true], "TT" :["phoneExtension": "1", "isMain": false], "TN" : ["phoneExtension": "216", "isMain": true], "TR" : ["phoneExtension": "90", "isMain": true], "TM" : ["phoneExtension": "993", "isMain": true], "TC" : ["phoneExtension": "1", "isMain": false], "TV" : ["phoneExtension": "688", "isMain": true], "VI" : ["phoneExtension": "1", "isMain": false], "UG" : ["phoneExtension": "256", "isMain": true], "UA" : ["phoneExtension": "380", "isMain": true], "AE": ["phoneExtension": "971", "isMain": true], "GB" : ["phoneExtension": "44", "isMain": true], "US" : ["phoneExtension": "1", "isMain": true], "UY" : ["phoneExtension": "598", "isMain": true], "UZ" : ["phoneExtension": "998", "isMain": true], "VU" : ["phoneExtension": "678", "isMain": true], "VA" : ["phoneExtension": "379", "isMain": true], "VE" : ["phoneExtension": "58", "isMain": true], "VN" : ["phoneExtension": "84", "isMain": true], "WF" : ["phoneExtension": "681", "isMain": true], "EH" : ["phoneExtension": "212", "isMain": true], "YE" : ["phoneExtension": "967", "isMain": true], "ZM" : ["phoneExtension": "260", "isMain": true], "ZW" : ["phoneExtension": "263", "isMain": true]]
}

public class Country {
    
    public var name: String
    public var phoneExtension: String?
    public var countryCode: String
    public var isMain: Bool?
    
    public init(name: String, phoneExtension: String?, countryCode: String, isMain: Bool?) {
        self.name = name
        self.phoneExtension = phoneExtension
        self.countryCode = countryCode
        self.isMain = isMain
    }
}