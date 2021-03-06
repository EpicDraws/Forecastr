//
//  Forecastr+CLLocation.h
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

#import <CoreLocation/CoreLocation.h>
#import "Forecastr.h"

@interface Forecastr (CLLocation)

/**
 * Requests the forecast for the given CLLocation and optional time and/or exclusions
 *
 * @return The JSON response
 *
 * @param location A CLLocation object generated by CLLocationManager
 * @param time (Optional) The desired time of the forecast in UNIX GMT format
 * @param exclusions (Optional) An array which specifies which data blocks you would like left off the response
 * @param extend (Optional) Extra commands that are sent to the server
 * @param language (Optional) Specify which language you want the weather descriptions in
 * @param success A block object to be executed when the operation finishes successfully.
 * @param failure A block object to be executed when the operation finishes unsuccessfully.
 *
 * @discussion For many locations, it can be 60 years in the past to 10 years in the future.
 */

- (void)getForecastForLocation:(CLLocation *)location
                          time:(NSNumber *)time
                    exclusions:(NSArray *)exclusions
                        extend:(NSString *)extendCommand
                      language:(NSString *)language
                       success:(void (^)(id JSON, BOOL wasCached))success
                       failure:(void (^)(NSError *error, id response))failure;

/**
 * Requests the forecast for the given CLLocation and optional time and/or exclusions
 *
 * @return The JSON response
 *
 * @param location A CLLocation object generated by CLLocationManager
 * @param time (Optional) The desired time of the forecast in UNIX GMT format
 * @param exclusions (Optional) An array which specifies which data blocks you would like left off the response
 * @param extend (Optional) Extra commands that are sent to the server
 * @param success A block object to be executed when the operation finishes successfully.
 * @param failure A block object to be executed when the operation finishes unsuccessfully.
 *
 * @discussion For many locations, it can be 60 years in the past to 10 years in the future.
 */

- (void)getForecastForLocation:(CLLocation *)location
                          time:(NSNumber *)time
                    exclusions:(NSArray *)exclusions
                        extend:(NSString *)extendCommand
                       success:(void (^)(id JSON, BOOL wasCached))success
                       failure:(void (^)(NSError *error, id response))failure;

/**
 * Requests the forecast for the given CLLocation and optional time and/or exclusions
 *
 * @return The JSON response
 *
 * @param location A CLLocation object generated by CLLocationManager
 * @param time (Optional) The desired time of the forecast in UNIX GMT format
 * @param exclusions (Optional) An array which specifies which data blocks you would like left off the response
 * @param success A block object to be executed when the operation finishes successfully.
 * @param failure A block object to be executed when the operation finishes unsuccessfully.
 *
 * @discussion For many locations, it can be 60 years in the past to 10 years in the future.
 */

- (void)getForecastForLocation:(CLLocation *)location
                          time:(NSNumber *)time
                    exclusions:(NSArray *)exclusions
                       success:(void (^)(id JSON, BOOL wasCached))success
                       failure:(void (^)(NSError *error, id response))failure;


/**
 * Removes a cached forecast in case you want to refresh it prematurely
 * Make sure you pass in the exact same params that you used in the original request
 *
 * @param location A CLLocation object generated by CLLocationManager
 * @param time (Optional) The desired time of the forecast in UNIX GMT format
 * @param exclusions (Optional) An array which specifies which data blocks you would like left off the response
 * @param language (Optional) Specify which language you want the weather descriptions in
 */

- (void)removeCachedForecastForLocation:(CLLocation *)location time:(NSNumber *)time exclusions:(NSArray *)exclusions extend:(NSString *)extendCommand language:(NSString *)languageCode;

- (void)removeCachedForecastForLocation:(CLLocation *)location time:(NSNumber *)time exclusions:(NSArray *)exclusions extend:(NSString *)extendCommand DEPRECATED_ATTRIBUTE;

@end
