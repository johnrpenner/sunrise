// SunRise 2.5 by johnRolandPenner     [Sept.30.2024]
// SunRise 1.0 by johnPenner*mac*com   [Sept.5.2001]
// 
// Created by John Penner on 2021-11-26.
// Copyright © 2024 John Penner. All rights reserved.
//
// Source:
//   Almanac for Computers, 1990
//   published by Nautical Almanac Office
//   United States Naval Observatory
//   Washington, DC 20392
// 
// Inputs: 
//    day, month, year:      date of sunrise/sunset
//    latitude, longitude:   location for sunrise/sunset
//    zenith:                Sun's zenith for sunrise/sunset
//      offical      = 90 degrees 50' (90.8333)
//      civil        = 96 degrees
//      nautical     = 102 degrees
//      astronomical = 108 degrees
//      
//    NOTE: longitude is positive for East and negative for West
// 
// Toronto: Lat = 43-39' N, Long = 79-20', Time -5 hours
// Toronto: Latitude +43.6532, Longitude -79.3832
// Cupertino: Latitude +37.32306, Longitude -122.03111
// 
// Usage: sunrise 12 18 2021 43.6532 -79.3832 -5 1
// Compile: swiftc -o sunrise main.swift


import Foundation
import CoreLocation


	//--| Location Manager |--------------------------------------------------- 
	
	let locationManager = CLLocationManager()
	locationManager.requestWhenInUseAuthorization()

	var currentLocation: CLLocation! 

	if CLLocationManager.authorizationStatus() == .authorizedAlways
		{
			currentLocation = locationManager.location
			print("Current Latitude:  \(currentLocation.coordinate.latitude)")
			print("Current Longitude: \(currentLocation.coordinate.longitude)")
		}
		//else {print("Location Manager needs to Authorize sunrise in Privacy Preferences")}
		
		
	//--| METHODS |-----------------------------------------------------------
	
	func getWords(inString:String) -> [String]
	{
		return inString.components(separatedBy:" ")		//swift3
	}
	
	
	func midString(theString:String, charIndex:Int, range:Int) -> String
	{
		// swift3
		if (theString.count >= charIndex + range) { 
			let start = theString.index(theString.startIndex, offsetBy: charIndex)
			let end = theString.index(theString.startIndex, offsetBy: charIndex+range)
			let span = start..<end
			return String(theString[span])
			}
		return ""
	}


	//-------| SUNRISE FUNCTIONS |--------------------------------------------------------//

	func getMonth() -> Int
	{
		let date = Date()
		let calendar = Calendar.current
		let components = calendar.dateComponents([.month], from:date)
		let month = components.month
		let intMonth : Int? = month
		return intMonth ?? 11
	}
	
	func getDay() -> Int
	{
		let date = Date()
		let calendar = Calendar.current
		let components = calendar.dateComponents([.day], from:date)
		let day = components.day
		let intDay : Int? = day
		return intDay ?? 26
	}	

	func getYear() -> Int
	{
		let date = Date()
		let calendar = Calendar.current
		let components = calendar.dateComponents([.year], from:date)
		let year = components.year
		let intYear : Int? = year
		return intYear ?? 2021
	}
	
	
	// Trigonometry functions return Degrees instead of Radians
	func sinD(n:Float) -> Float { return sin(n * 0.0174532925199433) }
	func cosD(n:Float) -> Float { return cos(n * 0.0174532925199433) }
	func tanD(n:Float) -> Float { return tan(n * 0.0174532925199433) }
	func asinD(n:Float) -> Float { return asin(n) * 57.2957795130823 }
	func acosD(n:Float) -> Float { return acos(n) * 57.2957795130823 }
	func atanD(n:Float) -> Float { return atan(n) * 57.2957795130823 }
	
	
	func calcSunrise(latitude:Float, longitude:Float, month:Int, day:Int, year:Int, sunrise: Bool, twilight: Bool) -> Float
	{
		// Almanac for Computers (1990)
		// Nautical Almanac Office 
		// United States Naval Observatory
		// Washington, DC 20392
	
		// Zenith: Sun's zenith for sunrise/sunset
		//   offical      = 90 degrees 50' (90.833333)
		//   civil        = 96 degrees
		//   nautical     = 102 degrees
		//   astronomical = 108 degrees
		
		//let verbose : Bool = false
		var utcHOUR : Float = -999.0		//return -999.0 is NIL
		
		var zenith : Float
		if (twilight) {zenith = 96} else {zenith = 90.833333}
		
		// Step 1. Calculate the day of the year
		let N1 = floor(275.0 * Double(month) / 9.0)
		let N2 = floor((Double(month) + 9.0) / 12.0)
		let N3 = 1.0 + floor((Double(year)-4.0*floor(Double(year)/4.0)+2.0)/3.0)
		let N = N1 - (N2*N3) + Double(day) - 30.0
		if verbose { print("Day of Year (\(month) \(day) \(year)): \(N)") }
		
		// Step 2. Convert Longitude to hour value and calc an approximate time
		var time : Float
		let lngHour : Float = longitude / 15.0
		let tRising = Float(N) + ((6.0 - lngHour) / 24.0 )
		let tSetting = Float(N) + ((18.0 - lngHour) / 24.0 )
		if (sunrise) {time = tRising } else {time = tSetting }
		if verbose { print("LongitudinalHour: \(time)") }
		
		// Step 3. Calculate the Sun's Mean Anomaly
		let MA : Float = (0.9856 * time) - 3.289
		if verbose { print("Suns Mean Anomaly: \(MA)") }
		
		// Step 4. Calculate the Sun's True Longitude
		var Lsun : Float = MA + (1.916 * sinD(n:MA)) + (0.020 * sinD(n:2 * MA)) + 282.634
		while (Lsun >= 360) {Lsun = Lsun - 360.0}
		while (Lsun < 0) {Lsun = Lsun + 360.0}
		if verbose { print("Suns True Longitude: \(Lsun)") }
		
		// Step 5a. Calculate the Sun's Right Ascension
		// note: we /PiRads in atanD to get Radians > Degrees
		var RA : Float = atanD(n:0.91764 * tanD(n:Lsun))
		while (RA >= 360) {RA -= 360.0}
		while (RA <  0)   {RA += 360.0}
		if verbose { print("Suns Right Ascension: \(RA)") }
		
		// Step 5b. Right Ascension value needs to be in the same Quadrant as L(ongitude)
		let LongQuadrant : Float = floor(Lsun / 90.0) * 90.0
		let RAquadrant : Float = floor(RA / 90.0) * 90.0
		RA = RA + (LongQuadrant - RAquadrant)
		if verbose { print("Right Ascension in same quadrant as Longitude: \(RA)") }
		
		// Step 5c. Right Ascension value needs to be converted into hours
		RA = RA / 15.0
		if verbose { print("Right Ascension in Hours: \(RA)") }
		
		// Step 6. Calculate the Sun's Declination
		let sinDec : Float = 0.39782 * sinD(n:Lsun)
		let cosDec : Float = cosD(n:asinD(n:sinDec))
		if verbose { print("Suns Declination SIN:\(sinDec) COS:\(cosDec)") }
		
		// Step 7a. Calculate the Sun's local hour angle
		let cosH : Float = (cosD(n:zenith) - (sinDec * sinD(n:latitude))) / (cosDec * cosD(n:latitude))
		if (sunrise) { if (cosH > 1) {print("Sun never rises"); return 999.0} }		//Sun never rises NIL
		else { if (cosH < -1) {print("Sun never sets"); return -999.0} }			//Sun never sets  NIL
		
		// Step 7b. Finish calculating H and convert into Hours
		var H : Float
		if (sunrise) { H = 360.0 - acosD(n:cosH) }
		else { H = acosD(n:cosH) }
		H = H / 15.0
		if verbose { print("Calculate H in hours: \(H)") }
		
		// Step 8. Calculate local mean time of rising/setting
		let Tloc : Float = H + RA - (0.06571 * time) - 6.622
		if verbose { print("Local mean time of rising: \(Tloc)") }
		
		// Step 9. Adjust back to UTC
		var UTC : Float = Tloc - lngHour
		while (UTC >= 24) {UTC = UTC-24.0}
		while (UTC < 0) {UTC = UTC+24.0}
		
		utcHOUR = UTC		
		return utcHOUR		//Float (or NIL = -999.0) WTF why not NIL!?!!
	
	}
	
	
	func timeFloat2STR(utcHOURS:Float) -> String
	{
		// Convert the Decimal Hours into HOURS:MINUTES
		var utcHR = utcHOURS - utcHOURS.truncatingRemainder(dividingBy:1)
		if (isDST) {utcHR = utcHR + 1.0}		// DST Daylight Savings Time
		let utcRemainder : Float = utcHOURS.truncatingRemainder(dividingBy: 1)
		let utcMIN : Int = Int(utcRemainder * 60)
		let utcMINpadded : String = String(format: "%02d", utcMIN)		//pad the MINUTES (:MM)
		let utcTimeSTR : String = "\(Int(utcHR)):\(utcMINpadded)"
		return utcTimeSTR
	}
	
	
	//--| Moonphase Functions |-----------------------------------------------------------------
    
	func moonPhase(month: Int, day:Int, year:Int) -> Float
	{
		// Moonphase is based on C code in Moontool by John Walker (1987)
		// Ported to Python by Kevin Turner under a full moon (2001)
		// Ported to Swift by John Roland Penner under a full moon (2021)
		// Original Algorithm from: Practical Astronomy with your Calculator by Peter Duffett-Smith (1981)
		// JDN = Julian Day Number. Angles are in Degrees
		
		/* 
		PHASE -- Calculate phase of moon as a fraction: 
		The argument is the time for which the phase is requested, 
		expressed as a Julian date and fraction. Returns the terminator phase angle 
		as a percentage of a full circle (i.e. 0 to 1), and stores into pointer 
		arguments: the Illuminated fraction of the Moon's disc, 
		the Moon's age in days and fraction, the distance of the Moon 
		from the centre of the Earth, and the angular diameter subtended 
		by the Moon as seen by an observer at the centre of the Earth. 
		*/
		
		
		// Calculate Julian Day																				// pDate = Julian Date for which to calculate Phase
		let A = Float(year) / 100.0
		let B = A / 4
		let C = 2-A+B
		let E = 365.25 * (Float(year)+4716)
		let Fj = 30.6001 * (Float(month)+1)
		let JD = Float(C)+Float(day)+E+Fj-1524.5
		let pDate = JD + 2																					// off by 2!? WTF!? 
		
		
		//-- Astronomical constants --// 
		let epoch : Float = 2444238.5																		// 1980 January 0.0 in Julian JDN (Moontool by John Walker)
		
		// Constants defining the Sun's apparent orbit
		let ecliptic_longitude_epoch : Float = 278.833540												// Ecliptic longitude of the Sun at epoch 1980.0
		let ecliptic_longitude_perigee : Float = 282.596403											// Ecliptic longitude of the Sun at perigee
		let eccentricity : Float = 0.016718																// Eccentricity of Earth's orbit
		let sun_smaxis : Float = 1.49585e8																	// Semi-major axis of Earth's orbit, in kilometers
		let sun_angular_size_smaxis : Float = 0.533128													// Sun's angular size, in degrees, at semi-major axis distance
		
		// Elements of the Moon's orbit, epoch 1980.0
		let moon_mean_longitude_epoch : Float = 64.975464												// Moon's mean longitude at the epoch
		let moon_mean_perigee_epoch : Float = 349.383063												// Mean longitude of the perigee at the epoch
		let node_mean_longitude_epoch : Float = 151.950429											// Mean longitude of the node at the epoch
		let moon_inclination : Float = 5.145396																// Inclination of the Moon's orbit
		let moon_eccentricity : Float = 0.054900															// Eccentricity of the Moon's orbit
		let moon_angular_size : Float = 0.5181															// Moon's angular size at distance a from Earth
		let moon_smaxis : Float = 384401.0																	// Semi-major axis of the Moon's orbit, in kilometers
		let moon_parallax : Float = 0.9507																	// Parallax at a distance a from Earth
		let synodic_month : Float = 29.53058770576														// Synodic month (new Moon to new Moon), in days
		let lunations_base : Float = 2423436.0															// E.W. Brown's Base Date of Numbered Lunations (Jan.16.1923)
		
		// Properties of the Earth
		let earth_radius : Float = 6378.16																	// Radius of Earth in kilometres
		
		
		//-- Calculation of the Sun's position --//
		let eDay = pDate - epoch																			// Date within the Epoch
		let N = fixangle(angle: (360/365.2422) * eDay)													// Mean anomaly of the Sun
		let M = fixangle(angle: N + ecliptic_longitude_epoch - ecliptic_longitude_perigee)		// Convert from perigee coordinates to epoch 1980
		
		var Ec = kepler(epoch: M, eccentricity: eccentricity)											// Solve equation of Kepler
		Ec = sqrt((1 + eccentricity) / (1 - eccentricity)) * tan(Ec/2.0)
		Ec = 2 * todeg(radians: atan(Ec))																	// True anomaly
		let Lambdasun = fixangle(angle:Ec + ecliptic_longitude_perigee)							// Sun's geometric ecliptic longitude
		
		// Orbital distance factor
		let F = ((1 + eccentricity * cos(torad(degrees:Ec))) / (1 - eccentricity * eccentricity))
		let sun_dist = sun_smaxis / F																			// Distance to Sun in km
		let sun_angular_diameter = F * sun_angular_size_smaxis
		
		//-- Calculation of the Moon's position --//
		let moon_longitude = fixangle(angle: 13.1763966 * eDay + moon_mean_longitude_epoch)			// Moon's mean longitude
		let MM = fixangle(angle: moon_longitude - 0.1114041 * eDay - moon_mean_perigee_epoch)		// Moon's mean anomaly
		let MN = fixangle(angle: node_mean_longitude_epoch - 0.0529539 * eDay)							// Moon's ascending node mean longitude
		let Ev = 1.2739 * sin(torad(degrees: 2*(moon_longitude - Lambdasun) - MM))				// Evection
		let annual_eq = 0.1858 * sin(torad(degrees: M))													// Annual equation
		let A3 = 0.37 * sin(torad(degrees: M))															// Correction term
		let MmP = MM + Ev - annual_eq - A3																// Corrected anomaly
		
		// Correction for the equation of the centre
		let mEc = 6.2886 * sin(torad(degrees: MmP))
		let A4 = 0.214 * sin(torad(degrees: 2 * MmP))													// Another correction term
		let lP = moon_longitude + Ev + mEc - annual_eq + A4											// Corrected longitude
		let variation = 0.6583 * sin(torad(degrees: 2*(lP - Lambdasun)))								// Variation
		let lPP = lP + variation																				// True longitude
		
		// These Can Be Omitted for Moon Phase; only needed for Geometry
		let NP = MN - 0.16 * sin(torad(degrees: M))														// Corrected longitude of the node
		let y = sin(torad(degrees: lPP - NP)) * cos(torad(degrees: moon_inclination))				// Y inclination coordinate
		let x = cos(torad(degrees: lPP - NP))																// X inclination coordinate
		var Lambdamoon = todeg(radians: atan2(y, x))														// Ecliptic longitude
		Lambdamoon = Lambdamoon + NP
		let BetaM = todeg(radians: asin(sin(torad(degrees: lPP - NP)) * sin(torad(degrees: moon_inclination))))	// Ecliptic latitude
		// end omit
		
		//-- Calculation of the Phase of the Moon --// 
		let moon_age = lPP - Lambdasun																		// Age of the Moon in degrees
		let moon_phase = (1 - cos(torad(degrees: moon_age))) / 2.0										// Phase of the Moon
		
		// Calculate distance of Moon from the centre of the Earth
		let moon_dist = (moon_smaxis * (1 - moon_eccentricity * moon_eccentricity)) / (1 + moon_eccentricity * cos(torad(degrees: MmP + mEc)))
		
		// Calculate Moon's angular diameter
		let moon_diam_frac = moon_dist / moon_smaxis
		let moon_angular_diameter = moon_angular_size / moon_diam_frac
		
		// Calculate Moon's parallax (uncessary as we defined it in Constants)
		//let moon_parallax = moon_parallax / moon_diam_frac
		
		let mPhase = fixangle(angle: moon_age) / 360.0
		let mIlluminated = moon_phase
		let mAge = synodic_month * fixangle(angle: moon_age) / 360.0									// Moon Phase in Days
		let mDistance = moon_dist
		let mAngular_diameter = moon_angular_diameter
		let mSun_distance = sun_dist
		let mSun_angular_diameter = sun_angular_diameter
		
		//print("Astronomical Moon Phase • pDate \(pDate) eDay \(eDay) mPhase \(mPhase) mIlluminated \(mIlluminated) mAge \(mAge) mDistance \(mDistance) moonAngDiam \(mAngular_diameter) mSunDist \(mSun_distance) mSunAngDiam \(mSun_angular_diameter) ")
				
		// calculate days since the last new moon
		//let daysSinceNew = JD - 2451549.5   // how we did it with Synodic Calculation
		let daysSinceNew = mAge						// we do it here with Astronimical Days
		
		// calculate how many new moons there have been (in Number of Moon Cycles)
		let newMoons : Float = daysSinceNew / synodic_month
		
		// Multpily Fractional Part by Moonphase(29.53days) to Find Days Into Cycle
		let newMoonFrac : Float = newMoons.truncatingRemainder(dividingBy:1)
		let moonDays : Float = newMoonFrac * synodic_month
		//print("Moon Days \(moonDays)")
		
		return moonDays
	}
	
	
	// Handy Maths Functions for MoonPhase()
	func fixangle(angle: Float) -> Float { return angle - 360.0 * floor(angle/360.0) }
	func torad(degrees: Float) -> Float { return degrees * Float.pi / 180.0 }
	func todeg(radians: Float) -> Float { return radians * 180.0 / Float.pi }
	func dsin(degrees: Float) -> Float { return sin( degrees * Float.pi / 180.0 ) }
	func dcos(degrees: Float) -> Float { return cos( degrees * Float.pi / 180.0 ) }
	
	
	// Solve the Equation of Kepler
	func kepler(epoch: Float, eccentricity: Float) -> Float
	{
		var kEccentricity : Float
		var delta : Float
		
		let epsilon : Float = 1e-6
		let epoch = torad(degrees:epoch)
		kEccentricity = epoch
		
		while true {
			delta = kEccentricity - eccentricity * sin(kEccentricity) - epoch
			kEccentricity = kEccentricity - delta / (1.0 - eccentricity * cos(kEccentricity))
			if abs(delta) <= epsilon {break}
			}
			
		return kEccentricity
	}
	
	
	//-- Synodic Moon Phase (Less Accurate Method) -----// 
	
    func moonDayse(month:Int, day:Int, year:Int) -> Float
    {
		// calculate Julian Day
		let A = Float(year) / 100.0
		let B = A / 4
		let C = 2-A+B
		let E = 365.25 * (Float(year)+4716)
		let F = 30.6001 * (Float(month)+1)
		var JD = Float(C)+Float(day)+E+F-1524.5
		JD = JD + 2		// off by 2  (Synodic Only!?)
		
		let synodic_month : Float = 29.53058770576
		
		// calculate days since the last new moon
		let daysSinceNew = JD - 2451549.5
		
		// calculate how many new moons there have been (in Number of Moon Cycles)
		let newMoons : Float = daysSinceNew / synodic_month
		
		// Multpily Fractional Part by Moonphase(29.53days) to Find Days Into Cycle
		let newMoonFrac : Float = newMoons.truncatingRemainder(dividingBy:1)
		let moonDays : Float = newMoonFrac * synodic_month
		
        return moonDays
    }

    
    func moonDay2emoji(day:Float) -> String
    {
        let offset : Int = Int(day)
        let phaseSTR : String = "🌑🌒🌒🌒🌒🌒🌒🌒🌒🌓🌔🌔🌔🌔🌔🌕🌖🌖🌖🌖🌖🌖🌗🌘🌘🌘🌘🌘🌘🌑🌑"
        let moonEmoji : String = midString(theString:phaseSTR, charIndex:offset, range:1)
        return moonEmoji
    }


	func loadPrefs() -> String
	{
		var firstLine : String = ""
		
		//let path = "/Users/john/.sunrc"
		let path : String = NSHomeDirectoryForUser( NSUserName() )! + "/.sunrc"
		//print(path)
		
		do {
			let contents = try String(contentsOfFile: path, encoding: .utf8)
			let myStrings = contents.components(separatedBy: .newlines)
			firstLine = myStrings[0]
			//print(firstLine)
			}
			
		catch let error as NSError {
			print("Error: Could not read .sunrc")
			//return "43.6532 -79.3832 -5 1 Toronto"
			}
		
		return firstLine
	}
	
	
	func printHelp()
	{
		print("SUNRISE: Calculates Sunrise Sunset + Moonphase  ©2024 johnrolandpenner")
		print("Usage: ")
		print("sunrise [mm dd yyyy] [latitude longitude timezone verbose astro]")
		print("e.g. sunrise 12 18 2021 43.6532 -79.3832 -5 1")
		print("e.g. sunrise 12 18 2021")
		print("sunrise --help  Displays this Help")
		print("sunrise without arguments will use today's date, and look for ")
		print("a .sunrc file in $HOME to supply: Latitude Longitude Timezone Verbose City")
		print("echo \"43.6532 -79.3832 -5 1 Toronto 0\" > .sunrc")
		print("sunrise with a verbose of 4 prints a monthly chart. Example: ")
		print("sunrise 9 30 2024 43.6532 -79.3832 -5 4 0")
		print("setting astro to 1 changes moonPhase() to astronomical calculation")
		print("sunrise with only [mm dd yyyy] uses location from .sunrc")
		return
	}
	
	
func printOutput(Month: Int, Day: Int, Year: Int, Latitude: Float, Longitude: Float, Zone: Float, Verbose: Int)
	{
		let synodic_month : Float = 29.53058770576
		var moonDays : Float = 0
		
		// 0 = EMOJI Compact
		if Verbose == 0 {
			
			// Sunrise Sunset
			var utcSunriseHOURS : Float = calcSunrise(latitude:Latitude, longitude:Longitude, month:Month, day:Day, year:Year, sunrise: true, twilight: false)
			
			// Sunrise UTC to Local Timezone
			while (utcSunriseHOURS + timezonee) < 1.0 {utcSunriseHOURS += 24}
			while (utcSunriseHOURS + timezonee) >= 24 {utcSunriseHOURS -= 24}

			let localSunriseSTR = timeFloat2STR(utcHOURS:utcSunriseHOURS+timezonee)
			
			var utcSunsetHOURS : Float = calcSunrise(latitude:Latitude, longitude:Longitude, month:Month, day:Day, year:Year, sunrise: false, twilight: false)
			
			// Sunset UTC to Local Timezone
			while (utcSunsetHOURS + timezonee) < 1.0 {utcSunsetHOURS += 24}
			while (utcSunsetHOURS + timezonee) >= 24 {utcSunsetHOURS -= 24}
			
			let localSunsetSTR = timeFloat2STR(utcHOURS:utcSunsetHOURS+timezonee)
			
			// Moonphase print ("Moonphase: 🌑🌒🌓🌔🌕🌖🌗🌘🌑 ") 
			// New[0], Waning Crescent [1-, Last Quarter, Waning Gibbous
			// Full Waxing Gibbous, First Quarter, Waxing Crescent, New[29.5]
			
			if (astroCalcu == false) {
				moonDays = moonDayse(month:Month, day:Day, year:Year)
				} else {
				moonDays = moonPhase(month:Month, day:Day, year:Year)
				}
			let moonDaysPadded : String = String(format: "%.2f", moonDays)
			let Moonphase : String = moonDay2emoji(day:moonDays)
			let moonDaysInt : Int = Int(moonDays)
			var moonString : String = ""; if moonDaysInt == 15 {moonString = "Fullmoon"}
			let moonDaysPercent : Float = Float(Float(moonDaysInt) / synodic_month) * 100
			let moonDaysPercentStr : String = String(format: "%0.0f", moonDaysPercent)
			
			// Single Line Emoji Compact
			print ("🌅 \(localSunriseSTR)  🌃 \(localSunsetSTR)  \(Moonphase) \(moonDaysPercentStr)% \(moonString)")
			}
		
		// 1 = Single Line Text
		if Verbose == 1 {
			
			// Sunrise Sunset
			var utcSunriseHOURS : Float = calcSunrise(latitude:Latitude, longitude:Longitude, month:Month, day:Day, year:Year, sunrise: true, twilight: false)
			
			// Sunrise UTC to Local Timezone
			while (utcSunriseHOURS + timezonee) < 1.0 {utcSunriseHOURS += 24}
			while (utcSunriseHOURS + timezonee) >= 24 {utcSunriseHOURS -= 24}
			
			let localSunriseSTR = timeFloat2STR(utcHOURS:utcSunriseHOURS+timezonee)
			
			var utcSunsetHOURS : Float = calcSunrise(latitude:Latitude, longitude:Longitude, month:Month, day:Day, year:Year, sunrise: false, twilight: false)
			
			// Sunset UTC to Local Timezone
			while (utcSunsetHOURS + timezonee) < 1.0 {utcSunsetHOURS += 24}
			while (utcSunsetHOURS + timezonee) >= 24 {utcSunsetHOURS -= 24}
			

			let localSunsetSTR = timeFloat2STR(utcHOURS:utcSunsetHOURS+timezonee)
			
			// Moonphase print ("Moonphase: 🌑🌒🌓🌔🌕🌖🌗🌘🌑 ") 
			// New[0], Waning Crescent [1-, Last Quarter, Waning Gibbous
			// Full Waxing Gibbous, First Quarter, Waxing Crescent, New[29.5]
			//let moonDays : Float = moonDays(month:Month, day:Day, year:Year)
			if (astroCalcu == false) {
				moonDays = moonDayse(month:Month, day:Day, year:Year)
				} else {
				moonDays = moonPhase(month:Month, day:Day, year:Year)
				}
			let moonDaysPadded : String = String(format: "%.2f", moonDays)
			let Moonphase : String = moonDay2emoji(day:moonDays)
			let moonDaysInt : Int = Int(moonDays)
			var moonString : String = ""; if moonDaysInt == 15 {moonString = "Fullmoon"}
			let moonDaysPercent : Float = Float(Float(moonDaysInt) / synodic_month) * 100
			let moonDaysPercentStr : String = String(format: "%0.2f", moonDaysPercent)
			
			// Single Line Text Compact
			print ("Sunrise: \(localSunriseSTR)  Sunset: \(localSunsetSTR)  Moonphase: \(moonDaysPercentStr)% \(Moonphase) \(moonString)")
			}
		
		// 2 = Three Line
		if Verbose == 2 {
			var utcSunriseHOURS : Float = calcSunrise(latitude:Latitude, longitude:Longitude, month:Month, day:Day, year:Year, sunrise: true, twilight: false)
			
			// Sunrise UTC to Local Timezone
			while (utcSunriseHOURS + timezonee) < 1.0 {utcSunriseHOURS += 24}
			while (utcSunriseHOURS + timezonee) >= 24 {utcSunriseHOURS -= 24}

			let localSunriseSTR = timeFloat2STR(utcHOURS:utcSunriseHOURS+timezonee)
			
			var utcSunsetHOURS : Float = calcSunrise(latitude:Latitude, longitude:Longitude, month:Month, day:Day, year:Year, sunrise: false, twilight: false)
						
			// Sunset UTC to Local Timezone
			while (utcSunsetHOURS + timezonee) < 1.0 {utcSunsetHOURS += 24}
			while (utcSunsetHOURS + timezonee) >= 24 {utcSunsetHOURS -= 24}
			
			let localSunsetSTR = timeFloat2STR(utcHOURS:utcSunsetHOURS+timezonee)
			
			// Sunrise Sunset
			print ("Sunrise: \(localSunriseSTR)")
			print ("Sunset: \(localSunsetSTR)")
			if (isDST) {print("DST = \(isDST) for TimeZone \(timezonee)") }
			
			// Moonphase print ("Moonphase: 🌑🌒🌓🌔🌕🌖🌗🌘🌑 ") 
			// New[0], Waning Crescent [1-, Last Quarter, Waning Gibbous
			// Full Waxing Gibbous, First Quarter, Waxing Crescent, New[29.5]
			if (astroCalcu == false) {
				moonDays = moonDayse(month:Month, day:Day, year:Year)
				} else {
				moonDays = moonPhase(month:Month, day:Day, year:Year)
				}
			let moonDaysPadded : String = String(format: "%.2f", moonDays)
			let Moonphase : String = moonDay2emoji(day:moonDays)
			let moonDaysInt : Int = Int(moonDays)
			var moonString : String = ""; if moonDaysInt == 15 {moonString = "Fullmoon"}
			let moonDaysPercent : Float = Float(Float(moonDaysInt) / synodic_month) * 100
			let moonDaysPercentStr : String = String(format: "%0.2f", moonDaysPercent)
			print ("Moonphase: \(moonDaysPercentStr)% \(Moonphase) \(moonString)")
			}
		
		// 3 = Full Verbose
		if Verbose == 3 {
			
			verbose = true		// turn it on for debug
			
			print("Sunrise \(Month) \(Day) \(Year) \(Latitude) \(Longitude) \(Zone) ")
			var utcSunriseHOURS : Float = calcSunrise(latitude:Latitude, longitude:Longitude, month:Month, day:Day, year:Year, sunrise: true, twilight: false)
			
			// Sunrise UTC to Local Timezone
			while (utcSunriseHOURS + timezonee) < 1.0 {utcSunriseHOURS += 24}
			while (utcSunriseHOURS + timezonee) >= 24 {utcSunriseHOURS -= 24}
			
			let localSunriseSTR = timeFloat2STR(utcHOURS:utcSunriseHOURS+timezonee)
			
			print("Sunset \(Month) \(Day) \(Year) \(Latitude) \(Longitude) \(Zone) ")
			var utcSunsetHOURS : Float = calcSunrise(latitude:Latitude, longitude:Longitude, month:Month, day:Day, year:Year, sunrise: false, twilight: false)
			
			// Sunset UTC to Local Timezone
			while (utcSunsetHOURS + timezonee) < 1.0 {utcSunsetHOURS += 24}
			while (utcSunsetHOURS + timezonee) >= 24 {utcSunsetHOURS -= 24}
			
			let localSunsetSTR = timeFloat2STR(utcHOURS:utcSunsetHOURS+timezonee)
			
			// Sunrise Sunset
			print ("Sunrise: \(localSunriseSTR)")
			print ("Sunset: \(localSunsetSTR)")
			if (isDST) {print("DST = \(isDST) for TimeZone \(timezonee)") }
			
			// Moonphase print ("Moonphase: 🌑🌒🌓🌔🌕🌖🌗🌘🌑 ") 
			// New[0], Waning Crescent [1-, Last Quarter, Waning Gibbous
			// Full Waxing Gibbous, First Quarter, Waxing Crescent, New[29.5]
			if (astroCalcu == false) {
				moonDays = moonDayse(month:Month, day:Day, year:Year)
				} else {
				moonDays = moonPhase(month:Month, day:Day, year:Year)
				}
			let moonDaysPadded : String = String(format: "%.2f", moonDays)
			let Moonphase : String = moonDay2emoji(day:moonDays)
			let moonDaysInt : Int = Int(moonDays)
			var moonString : String = ""; if moonDaysInt == 15 {moonString = "Fullmoon"}
			let moonDaysPercent : Float = Float(Float(moonDaysInt) / synodic_month) * 100
			let moonDaysPercentStr : String = String(format: "%0.2f", moonDaysPercent)
			print ("Moonphase: \(moonDaysPercentStr)% \(Moonphase) \(moonString)")
			
			verbose = false		// turn it off to resume normal operation
			
			}
			
		// 4 = Multi Line Listing
		if Verbose == 4 {
			var utcSunriseHOURS : Float = calcSunrise(latitude:Latitude, longitude:Longitude, month:Month, day:Day, year:Year, sunrise: true, twilight: false)
			
			// Sunrise UTC to Local Timezone
			while (utcSunriseHOURS + timezonee) < 1.0 {utcSunriseHOURS += 24}
			while (utcSunriseHOURS + timezonee) >= 24 {utcSunriseHOURS -= 24}

			let localSunriseSTR = timeFloat2STR(utcHOURS:utcSunriseHOURS+timezonee)
			
			var utcSunsetHOURS : Float = calcSunrise(latitude:Latitude, longitude:Longitude, month:Month, day:Day, year:Year, sunrise: false, twilight: false)
						
			// Sunset UTC to Local Timezone
			while (utcSunsetHOURS + timezonee) < 1.0 {utcSunsetHOURS += 24}
			while (utcSunsetHOURS + timezonee) >= 24 {utcSunsetHOURS -= 24}
			
			let localSunsetSTR = timeFloat2STR(utcHOURS:utcSunsetHOURS+timezonee)
			
			var DSTstr : String = ""; if (isDST) {DSTstr = "DST"}
			
			// Moonphase print ("Moonphase: 🌑🌒🌓🌔🌕🌖🌗🌘🌑 ")
			if (astroCalcu == false) {
				moonDays = moonDayse(month:Month, day:Day, year:Year)
				} else {
				moonDays = moonPhase(month:Month, day:Day, year:Year)
				}
			let moonDaysPadded : String = String(format: "%.2f", moonDays)
			let Moonphase : String = moonDay2emoji(day:moonDays)
			let moonDaysInt : Int = Int(moonDays)
			var moonString : String = ""; if moonDaysInt == 15 {moonString = "Fullmoon"}
			let moonDaysPercent : Float = Float(Float(moonDaysInt) / synodic_month) * 100
			let moonDaysPercentStr : String = String(format: "%0.2f", moonDaysPercent)
			
			let MonthPadded : String = String(format: "%02d", Month)
			let daysPadded : String = String(format: "%02d", Day)
			
			print ("\(MonthPadded)/\(daysPadded)/\(Year) \(DSTstr)  🌎 Lat:\(Latitude) Long:\(Longitude)  🌅 \(localSunriseSTR)  🌃 \(localSunsetSTR) Moonphase \(moonDaysPercentStr)% \(Moonphase) \(moonString)")
			}
		
		return
	}
	
	
	//--| MAIN |---------------------------------------------------------------
	
	// Manage ARGS
	let argCount = CommandLine.argc
	var timezonee : Float = -5		// UTC+0 = GMT Greenwich Meridian Time Default
	let sunrise = true		   			// calculate sunrise[true] or sunset[false]
	let twilight = false    			// calculate twilight[true] or sunrise-sunset[false]
	var verbose : Bool = false		// default less verbose
	var astroCalcu : Bool = false	// default use Synodic Moonphase (true = Astronomical)
	var isDST : Bool						// we set this globally defining it here in MAIN
	
	// Sunrise = calcSunrise(Latitude, Longitude, Date, True, False)
	// Sunset  = calcSunrise(Latitude, Longitude, Date, False, False)
	// MorningTwilight = calcSunrise(Latitude, Longitude, Date, True, True)
	// EveningTwilight = calcSunrise(Latitude, Longitude, Date, False, True)
	
	if (argCount != 1 && argCount != 4 && argCount != 9) 
	{
		printHelp()
		}
	
	if (argCount == 1) {
				
		let month : Int = getMonth()
		let day : Int = getDay()
		let year : Int = getYear()
		
		let locationStr = loadPrefs()
		let locationWords : [String] = getWords(inString:locationStr)
		let latitude : Float = (locationWords[0] as NSString).floatValue
		let longitude : Float = (locationWords[1] as NSString).floatValue
		timezonee = (locationWords[2] as NSString).floatValue
		let verbose : Int = Int((locationWords[3] as NSString).intValue)
		
		// DST Daylight Savings Time Detection (uses DATE, and CURRENT TIMEZONE)
		let userCalendar = Calendar.current	// TimeZone Calculated by the Calendar Class
		let tzone = TimeZone.current			// TimeZone set to System TimeZone
		//let timezoneeSecs : Int = Int(timezonee) * 3600
		//let tzone = TimeZone(secondsFromGMT: timezoneeSecs)!
		let motherDemo = DateComponents(timeZone: tzone, year: year, month: month, day: day )
		let motherDemoDate = userCalendar.date(from: motherDemo)!
		isDST = tzone.isDaylightSavingTime(for: motherDemoDate)
		
		printOutput(Month: month, Day: day, Year: year, Latitude: latitude, Longitude: longitude, Zone: timezonee, Verbose: verbose)
		}
		
	if (argCount == 4) {
				
		let argument1 = CommandLine.arguments[1]	//MONTH [1..12]
		let argument2 = CommandLine.arguments[2]	//DAY   [1..31]
		let argument3 = CommandLine.arguments[3]	//YYYY  [YYYY]
		
		let month = Int(argument1)!
		let day = Int(argument2)!
		let year = Int(argument3)!
		
		let locationStr = loadPrefs()
		let locationWords : [String] = getWords(inString:locationStr)
		let latitude : Float = (locationWords[0] as NSString).floatValue
		let longitude : Float = (locationWords[1] as NSString).floatValue
		timezonee = (locationWords[2] as NSString).floatValue
		let verbose : Int = Int((locationWords[3] as NSString).intValue)
		
		// DST Daylight Savings Time Detection (uses DATE, and CURRENT TIMEZONE)
		let userCalendar = Calendar.current	// TimeZone Calculated by the Calendar Class
		let tzone = TimeZone.current			// TimeZone set to System TimeZone
		//let timezoneeSecs : Int = Int(timezonee) * 3600
		//let tzone = TimeZone(secondsFromGMT: timezoneeSecs)!
		let motherDemo = DateComponents(timeZone: tzone, year: year, month: month, day: day )
		let motherDemoDate = userCalendar.date(from: motherDemo)!
		isDST = tzone.isDaylightSavingTime(for: motherDemoDate) 
		
		printOutput(Month: month, Day: day, Year: year, Latitude: latitude, Longitude: longitude, Zone: timezonee, Verbose: verbose)
		
		}

	if (argCount == 9) {
		
		let argument1 = CommandLine.arguments[1]	//MONTH [1..12]
		let argument2 = CommandLine.arguments[2]	//DAY   [1..31]
		let argument3 = CommandLine.arguments[3]	//YYYY  [YYYY]
		let argument4 = CommandLine.arguments[4]	//LATITUDE
		let argument5 = CommandLine.arguments[5]	//LONGITUDE
        let argument6 = CommandLine.arguments[6] //TIMEZONE
		let argument7 = CommandLine.arguments[7]	//VERBOSE
		let argument8 = CommandLine.arguments[8]	//ASTROCALC
		
		let month = Int(argument1)!
		let day = Int(argument2)!
		let year = Int(argument3)!
		
		let latitude = Float(argument4)!
		let longitude = Float(argument5)!
        let timezonee = Float(argument6)!
		let verbose : Int = Int(NSString(string:argument7).intValue)
		let astroCalc : Int = Int(NSString(string:argument8).intValue)
		
		if astroCalc == 1 { astroCalcu = true }
		
		// DST Daylight Savings Time Detection (uses DATE, and CURRENT TIMEZONE)
		let userCalendar = Calendar.current	// TimeZone Calculated by the Calendar Class
		let tzone = TimeZone.current			// TimeZone set to System TimeZone
		//let timezoneeSecs : Int = Int(timezonee) * 3600
		//let tzone = TimeZone(secondsFromGMT: timezoneeSecs)!
		let motherDemo = DateComponents(timeZone: tzone, year: year, month: month, day: day )
		let motherDemoDate = userCalendar.date(from: motherDemo)!
		isDST = tzone.isDaylightSavingTime(for: motherDemoDate)
		
		//LOOP DAYS to test we are getting right results for all days
		if verbose == 4 {
			for days in 1...28 {
				printOutput(Month: month, Day: days, Year: year, Latitude: latitude, Longitude: longitude, Zone: timezonee, Verbose: verbose)
				}
			}
			
		if verbose < 4 {
			printOutput(Month: month, Day: day, Year: year, Latitude: latitude, Longitude: longitude, Zone: timezonee, Verbose: verbose)
			}
		
		}
