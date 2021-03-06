//
//  Forecastr.m
//  Forecastr
//
//  Created by Rob Phillips on 4/3/13.
//  Copyright (c) 2013 Rob Phillips. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "Forecastr.h"
#import "AFNetworking.h"
#import "ForecastrAPIClient.h"

#define NDEBUG true

// Error domain & enums
NSString *const kFCErrorDomain = @"com.forecastr.errors";
typedef enum {
    kFCCachedItemNotFound,
    kFCCacheNotEnabled
} ForecastrErrorType;

// Cache keys
NSString *const kFCCacheKey = @"CachedForecasts";
NSString *const kFCCacheArchiveKey = @"ArchivedForecast";
NSString *const kFCCacheExpiresKey = @"ExpiresAt";
NSString *const kFCCacheForecastKey = @"Forecast";
NSString *const kFCCacheJSONPKey = @"JSONP";

/**
 * A common area for changing the names of all constants used in the JSON response
 */

// Unit types
NSString *const kFCUSUnits = @"us";
NSString *const kFCSIUnits = @"si";
NSString *const kFCUKUnits = @"uk";
NSString *const kFCCAUnits = @"ca";
NSString *const kFCAutoUnits = @"auto";

// Languages
NSString *const kFCLanguageBosnian = @"bs";
NSString *const kFCLanguageGerman = @"de";
NSString *const kFCLanguageEnglish = @"en"; // Default
NSString *const kFCLanguageSpanish = @"es";
NSString *const kFCLanguageFrench = @"fr";
NSString *const kFCLanguageItalian = @"it";
NSString *const kFCLanguageDutch = @"nl";
NSString *const kFCLanguagePolish = @"pl";
NSString *const kFCLanguagePortuguese = @"pt";
NSString *const kFCLanguageTetum = @"tet";
NSString *const kFCLanguagePigLatin = @"x-pig-latin";

// Extend types
NSString *const kFCExtendHourly = @"hourly";

// Forecast names used for the data block hash keys
NSString *const kFCCurrentlyForecast = @"currently";
NSString *const kFCMinutelyForecast = @"minutely";
NSString *const kFCHourlyForecast = @"hourly";
NSString *const kFCDailyForecast = @"daily";

// Additional names used for the data block hash keys
NSString *const kFCAlerts = @"alerts";
NSString *const kFCFlags = @"flags";
NSString *const kFCLatitude = @"latitude";
NSString *const kFCLongitude = @"longitude";
NSString *const kFCOffset = @"offset";
NSString *const kFCTimezone = @"timezone";

// Names used for the data point hash keys
NSString *const kFCCloudCover = @"cloudCover";
NSString *const kFCCloudCoverError = @"cloudCoverError";
NSString *const kFCDewPoint = @"dewPoint";
NSString *const kFCHumidity = @"humidity";
NSString *const kFCHumidityError = @"humidityError";
NSString *const kFCIcon = @"icon";
NSString *const kFCMoonPhase = @"moonPhase";
NSString *const kFCOzone = @"ozone";
NSString *const kFCPrecipAccumulation = @"precipAccumulation";
NSString *const kFCPrecipIntensity = @"precipIntensity";
NSString *const kFCPrecipIntensityMax = @"precipIntensityMax";
NSString *const kFCPrecipIntensityMaxTime = @"precipIntensityMaxTime";
NSString *const kFCPrecipProbability = @"precipProbability";
NSString *const kFCPrecipType = @"precipType";
NSString *const kFCPressure = @"pressure";
NSString *const kFCPressureError = @"pressureError";
NSString *const kFCSummary = @"summary";
NSString *const kFCSunriseTime = @"sunriseTime";
NSString *const kFCSunsetTime = @"sunsetTime";
NSString *const kFCTemperature = @"temperature";
NSString *const kFCTemperatureMax = @"temperatureMax";
NSString *const kFCTemperatureMaxError = @"temperatureMaxError";
NSString *const kFCTemperatureMaxTime = @"temperatureMaxTime";
NSString *const kFCTemperatureMin = @"temperatureMin";
NSString *const kFCTemperatureMinError = @"temperatureMinError";
NSString *const kFCTemperatureMinTime = @"temperatureMinTime";
NSString *const kFCApparentTemperature = @"apparentTemperature";
NSString *const kFCTime = @"time";
NSString *const kFCVisibility = @"visibility";
NSString *const kFCVisibilityError = @"visibilityError";
NSString *const kFCWindBearing = @"windBearing";
NSString *const kFCWindSpeed = @"windSpeed";
NSString *const kFCWindSpeedError = @"windSpeedError";

// Names used for weather icons
NSString *const kFCIconClearDay = @"clear-day";
NSString *const kFCIconClearNight = @"clear-night";
NSString *const kFCIconRain = @"rain";
NSString *const kFCIconSnow = @"snow";
NSString *const kFCIconSleet = @"sleet";
NSString *const kFCIconWind = @"wind";
NSString *const kFCIconFog = @"fog";
NSString *const kFCIconCloudy = @"cloudy";
NSString *const kFCIconPartlyCloudyDay = @"partly-cloudy-day";
NSString *const kFCIconPartlyCloudyNight = @"partly-cloudy-night";
NSString *const kFCIconHail = @"hail";
NSString *const kFCIconThunderstorm = @"thunderstorm";
NSString *const kFCIconTornado = @"tornado";
NSString *const kFCIconHurricane = @"hurricane";

// A numerical value representing the distance to the nearest storm
NSString *const kFCNearestStormDistance = @"nearestStormDistance";
NSString *const kFCNearestStormBearing = @"nearestStormBearing";

@interface Forecastr ()
{
    NSUserDefaults *userDefaults;
    
    dispatch_queue_t async_queue;
}
@end

@implementation Forecastr

# pragma mark - Singleton Methods

+ (id)sharedManager
{
    static Forecastr *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (id)init {
    if (self = [super init]) {
        // Init code here
        userDefaults = [NSUserDefaults standardUserDefaults];
        
        // Setup the async queue
        async_queue = dispatch_queue_create("com.forecastr.asyncQueue", NULL);
        
        // Caching defaults
        self.cacheEnabled = YES; // Enable cache by default
        self.cacheExpirationInMinutes = 30; // Set default of 30 minutes
    }
    return self;
}

# pragma mark - Instance Methods

- (void)getForecastForLatitude:(double)lat
                     longitude:(double)lon
                          time:(NSNumber *)time
                    exclusions:(NSArray *)exclusions
                       success:(void (^)(id JSON, BOOL wasCached))success
                       failure:(void (^)(NSError *error, id response))failure
{
  [self getForecastForLatitude:lat longitude:lon time:time exclusions:exclusions extend:nil success:success failure:failure];
}

- (void)getForecastForLatitude:(double)lat
                     longitude:(double)lon
                          time:(NSNumber *)time
                    exclusions:(NSArray *)exclusions
                        extend:(NSString *)extendCommand
                       success:(void (^)(id JSON, BOOL wasCached))success
                       failure:(void (^)(NSError *error, id response))failure
{
    [self getForecastForLatitude:lat longitude:lon time:time exclusions:exclusions extend:nil language:nil success:success failure:failure];
}

// Requests the specified forecast for the given location and optional parameters
- (void)getForecastForLatitude:(double)lat
                     longitude:(double)lon
                          time:(NSNumber *)time
                    exclusions:(NSArray *)exclusions
                        extend:(NSString *)extendCommand
                      language:(NSString *)languageCode
                       success:(void (^)(id JSON, BOOL wasCached))success
                       failure:(void (^)(NSError *error, id response))failure
{
    // Check if we have an API key set
    [self checkForAPIKey];
    
    // Generate the URL string based on the passed in params
    NSString *urlString = [self urlStringforLatitude:lat longitude:lon time:time exclusions:exclusions extend:(NSString *)extendCommand language:languageCode];
    
#ifndef NDEBUG
    NSLog(@"Forecastr: Checking forecast for %@", urlString);
#endif
    
    NSString *callback = self.callback;
    
    // Check if we have a valid cache item that hasn't expired for this URL
    // If caching isn't enabled or a fresh cache item wasn't found, it will execute a server request in the failure block
    NSString *cacheKey = [self cacheKeyForURLString:urlString forLatitude:lat longitude:lon];
    [self checkForecastCacheForURLString:cacheKey success:^(id cachedForecast) {
        success(cachedForecast, YES);
    } failure:^(NSError *error) {
        // If we got here, cache isn't enabled or we didn't find a valid/unexpired forecast
        // for this location in cache so let's query the servers for one
        
        // Asynchronously kick off the GET request on the API for the generated URL (i.e. not the one used as a cache key)
        if (callback) {
            
            [ForecastrAPIClient sharedClient].responseSerializer = [AFHTTPResponseSerializer serializer];
            [[ForecastrAPIClient sharedClient] GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSString *JSONP = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
                if (self.cacheEnabled) [self cacheForecast:JSONP withURLString:cacheKey];
                [ForecastrAPIClient sharedClient].responseSerializer = [AFJSONResponseSerializer serializer];
                success(JSONP, NO);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                [ForecastrAPIClient sharedClient].responseSerializer = [AFJSONResponseSerializer serializer];
                failure(error, response);
            }];
            
        } else {
            
            [[ForecastrAPIClient sharedClient] GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id JSON) {
                if (self.cacheEnabled) [self cacheForecast:JSON withURLString:cacheKey];
                success(JSON, NO);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                failure(error, response);
            }];
            
        }
    }];
}

// Cancels all requests that are currently queued or being executed
- (void)cancelAllForecastRequests
{
    for (id task in [[ForecastrAPIClient sharedClient] tasks]) {
        if ([task respondsToSelector:@selector(cancel)]) {
            [task cancel];
        }
    }
}

// Returns a description based on the precicipation intensity
- (NSString *)descriptionForPrecipIntensity:(float)precipIntensity
{
    if (precipIntensity < 0.002) { return @"None"; }
    if (precipIntensity < 0.017) { return @"Very light"; }
    if (precipIntensity < 0.1) { return @"Light"; }
    if (precipIntensity < 0.4) { return @"Moderate"; }
    else return @"Heavy";
}

// Returns an image name based on the weather icon type
- (NSString *)imageNameForWeatherIconType:(NSString *)iconDescription
{
    if ([iconDescription isEqualToString:kFCIconClearDay]) { return @"clearDay.png"; }
    else if ([iconDescription isEqualToString:kFCIconClearNight]) { return @"clearNight.png"; }
    else if ([iconDescription isEqualToString:kFCIconRain]) { return @"rain.png"; }
    else if ([iconDescription isEqualToString:kFCIconSnow]) { return @"snow.png"; }
    else if ([iconDescription isEqualToString:kFCIconSleet]) { return @"sleet.png"; }
    else if ([iconDescription isEqualToString:kFCIconWind]) { return @"wind.png"; }
    else if ([iconDescription isEqualToString:kFCIconFog]) { return @"fog.png"; }
    else if ([iconDescription isEqualToString:kFCIconCloudy]) { return @"cloudy.png"; }
    else if ([iconDescription isEqualToString:kFCIconPartlyCloudyDay]) { return @"partlyCloudyDay.png"; }
    else if ([iconDescription isEqualToString:kFCIconPartlyCloudyNight]) { return @"partlyCloudyNight.png"; }
    else if ([iconDescription isEqualToString:kFCIconHail]) { return @"hail.png"; }
    else if ([iconDescription isEqualToString:kFCIconThunderstorm]) { return @"thunderstorm.png"; }
    else if ([iconDescription isEqualToString:kFCIconTornado]) { return @"tornado.png"; }
    else if ([iconDescription isEqualToString:kFCIconHurricane]) { return @"hurricane.png"; }
    else return @"cloudy.png"; // Default in case nothing matched
}

// Returns a string with the JSON error message, if given, or the appropriate localized description for the NSError object
- (NSString *)messageForError:(NSError *)error withResponse:(id)response
{
    if ([response isKindOfClass:[NSDictionary class]]) {
        NSString *errorMsg = [response objectForKey:@"error"];
        return (errorMsg.length) ? errorMsg : error.localizedDescription;
    } else {
        return error.localizedDescription;
    }
}

# pragma mark - Private Methods

// Check for an empty API key
- (void)checkForAPIKey
{
    if (!self.apiKey || !self.apiKey.length) {
        [NSException raise:@"Forecastr" format:@"Your Forecast.io API key must be populated before you can access the API.", nil];
    }
}

// Generates a URL string for the given options
- (NSString *)urlStringforLatitude:(double)lat longitude:(double)lon time:(NSNumber *)time exclusions:(NSArray *)exclusions extend:(NSString *)extendCommand language:(NSString *)languageCode
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%.6f,%.6f", self.apiKey, lat, lon];
    if (time) urlString = [urlString stringByAppendingFormat:@",%.0f", [time doubleValue]];
    if (exclusions) urlString = [urlString stringByAppendingFormat:@"?exclude=%@", [self stringForExclusions:exclusions]];
    if (extendCommand) urlString = [urlString stringByAppendingFormat:@"%@extend=%@", exclusions ? @"&" : @"?", extendCommand];
    if (languageCode) urlString = [urlString stringByAppendingFormat:@"%@lang=%@", (exclusions || extendCommand) ? @"&" : @"?", languageCode];
    if (self.units) urlString = [urlString stringByAppendingFormat:@"%@units=%@", (exclusions || extendCommand || languageCode) ? @"&" : @"?", self.units];
    if (self.callback) urlString = [urlString stringByAppendingFormat:@"%@callback=%@", (exclusions || self.units || extendCommand || languageCode) ? @"&" : @"?", self.callback];
    
    urlString = [urlString stringByAppendingFormat:@"&solar"];
    return urlString;
}

// Generates a string from an array of exclusions
- (NSString *)stringForExclusions:(NSArray *)exclusions
{
    __block NSString *exclusionString = @"";
    [exclusions enumerateObjectsUsingBlock:^(id exclusion, NSUInteger idx, BOOL *stop) {
        exclusionString = [exclusionString stringByAppendingFormat:idx == 0 ? @"%@" : @",%@", exclusion];
    }];
    return exclusionString;
}

# pragma mark - Cache Instance Methods

// Checks the NSUserDefaults for a cached forecast that is still fresh
- (void)checkForecastCacheForURLString:(NSString *)urlString
                               success:(void (^)(id cachedForecast))success
                               failure:(void (^)(NSError *error))failure
{
    if (self.cacheEnabled) {
        
        //  Perform this on a background thread
        dispatch_async(async_queue, ^{
            BOOL cachedItemWasFound = NO;
            @try {
                NSDictionary *cachedForecasts = [userDefaults dictionaryForKey:kFCCacheKey];
                if (cachedForecasts) {
                    // Create an NSString object from the coordinates as the dictionary key
                    NSData *archivedCacheItem = [cachedForecasts objectForKey:urlString];
                    // Check if the forecast exists and hasn't expired yet
                    if (archivedCacheItem) {
                        NSDictionary *cacheItem = [self objectForArchive:archivedCacheItem];
                        if (cacheItem) {
                            NSDate *expirationTime = (NSDate *)[cacheItem objectForKey:kFCCacheExpiresKey];
                            NSDate *rightNow = [NSDate date];
                            if ([rightNow compare:expirationTime] == NSOrderedAscending) {
#ifndef NDEBUG
                                NSLog(@"Forecastr: Found cached item for %@", urlString);
#endif
                                cachedItemWasFound = YES;
                                // Cache item is still fresh
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    success([cacheItem objectForKey:kFCCacheForecastKey]);
                                });
                                
                            }
                            // As a note, there is no need to remove any stale cache item since it will
                            // be overwritten when the forecast is cached again
                        }
                    }
                }
                if (!cachedItemWasFound) {
                    // If we don't have anything fresh in the cache
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        failure([NSError errorWithDomain:kFCErrorDomain code:kFCCachedItemNotFound userInfo:nil]);
                    });
                }
            }
            @catch (NSException *exception) {
#ifndef NDEBUG
                NSLog(@"Forecastr: Caught an exception while reading from cache (%@)", exception);
#endif
                dispatch_sync(dispatch_get_main_queue(), ^{
                    failure([NSError errorWithDomain:kFCErrorDomain code:kFCCachedItemNotFound userInfo:nil]);
                });
            }
        });
        
    } else {
        failure([NSError errorWithDomain:kFCErrorDomain code:kFCCacheNotEnabled userInfo:nil]);
    }
}

// Caches a forecast in NSUserDefaults based on the original URL string used to request it
- (void)cacheForecast:(id)forecast withURLString:(NSString *)urlString
{
#ifndef NDEBUG
    NSLog(@"Forecastr: Caching item for %@", urlString);
#endif
    
    // Save to cache on a background thread
    dispatch_async(async_queue, ^{
        NSMutableDictionary *cachedForecasts = [[userDefaults dictionaryForKey:kFCCacheKey] mutableCopy];
        if (!cachedForecasts) cachedForecasts = [[NSMutableDictionary alloc] initWithCapacity:1];
        
        // Set up the new dictionary we are going to cache
        NSDate *expirationDate = [[NSDate date] dateByAddingTimeInterval:self.cacheExpirationInMinutes * 60]; // X minutes from now
        NSMutableDictionary *newCacheItem = [[NSMutableDictionary alloc] initWithCapacity:2];
        [newCacheItem setObject:expirationDate forKey:kFCCacheExpiresKey];
        [newCacheItem setObject:forecast forKey:kFCCacheForecastKey];
        
        // Save the new cache item and sync the user defaults
        [cachedForecasts setObject:[self archivedObject:newCacheItem] forKey:urlString];
        [userDefaults setObject:cachedForecasts forKey:kFCCacheKey];
        [userDefaults synchronize];
    });
}

// Deprecated method
- (void)removeCachedForecastForLatitude:(double)lat longitude:(double)lon time:(NSNumber *)time exclusions:(NSArray *)exclusions extend:(NSString *)extendCommand
{
    [self removeCachedForecastForLatitude:lat longitude:lon time:time exclusions:exclusions extend:extendCommand language:nil];
}

// Removes a cached forecast in case you want to refresh it prematurely
- (void)removeCachedForecastForLatitude:(double)lat longitude:(double)lon time:(NSNumber *)time exclusions:(NSArray *)exclusions extend:(NSString *)extendCommand language:(NSString *)languageCode
{
    NSString *urlString = [self urlStringforLatitude:lat longitude:lon time:time exclusions:exclusions extend:extendCommand language:languageCode];
    NSString *cacheKey = [self cacheKeyForURLString:urlString forLatitude:lat longitude:lon];
    
    NSMutableDictionary *cachedForecasts = [[userDefaults dictionaryForKey:kFCCacheKey] mutableCopy];
    if (cachedForecasts) {
#ifndef NDEBUG
        NSLog(@"Forecastr: Removing cached item for %@", cacheKey);
#endif
        [cachedForecasts removeObjectForKey:cacheKey];
        [userDefaults setObject:cachedForecasts forKey:kFCCacheKey];
        [userDefaults synchronize];
    }
}

// Flushes all forecasts from the cache
- (void)flushCache
{
#ifndef NDEBUG
    NSLog(@"Forecastr: Flushing the cache...");
#endif
    [userDefaults removeObjectForKey:kFCCacheKey];
    [userDefaults synchronize];
}

# pragma mark - Cache Private Methods

// Truncates the latitude and longitude within the URL so that it's more generalized to the user's location
// Otherwise, you end up requesting forecasts from the server even though your lat/lon has only changed by a very small amount
- (NSString *)cacheKeyForURLString:(NSString *)urlString forLatitude:(double)lat longitude:(double)lon
{
    NSString *oldLatLon = [NSString stringWithFormat:@"%f,%f", lat, lon];
    NSString *generalizedLatLon = [NSString stringWithFormat:@"%.2f,%.2f", lat, lon];
    return [urlString stringByReplacingOccurrencesOfString:oldLatLon withString:generalizedLatLon];
}

// Creates an archived object suitable for storing in NSUserDefaults
- (NSData *)archivedObject:(id)object
{
    return object ? [NSKeyedArchiver archivedDataWithRootObject:object] : nil;
}

// Unarchives an object that was stored as NSData
- (id)objectForArchive:(NSData *)archivedObject
{
    return archivedObject ? [NSKeyedUnarchiver unarchiveObjectWithData:archivedObject] : nil;
}

@end
