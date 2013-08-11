//
//  bloom_filter_s.h
//  Pods
//
//  Created by Mathieu D'Amours on 5/16/13.
//
//

#import <Foundation/Foundation.h>
#import "bloom-filter.h"
#import "hash-string.h"

#pragma once

bloom_filter_hash_func BloomFilterStringHash;                    
bloom_filter_hash_func BloomFilterCaseInsensitiveStringHash;
bloom_filter_hash_func BloomFilterJenkinsHash;   
bloom_filter_hash_func BloomFilterCaseInsensitiveJenkinsHash;

typedef struct {
    size_t table_size;
    size_t num_functions;
    NSStringEncoding encoding;
    bloom_filter_hash_func hashfun;
} BloomFilterOptions;

@interface BloomFilter : NSObject

+ (instancetype) filterByIntersectingFilters:(NSArray *)filters;
+ (instancetype) filterFromUnionOfFilters:(NSArray *)filters;

+ (instancetype) filterWithProbability:(float)probability
                      forNumberOfItems:(size_t)numberOfItems
                              encoding:(NSStringEncoding)encoding
                       andHashFunction:(bloom_filter_hash_func)func;

+ (instancetype) filterWithTableSize:(size_t)tableSize
                    numberOfFunction:(size_t)numFunction
                            encoding:(NSStringEncoding)encoding
                     andHashFunction:(bloom_filter_hash_func)func;

- (instancetype) initWithOptions:(BloomFilterOptions)options;

- (void) addObject:(id)object;
- (BOOL) containsObject:(id)object;

- (void) loadFilter:(NSData *)content;
- (NSData *) dumpFilter;

- (instancetype) filterFromUnionWithFilter:(BloomFilter *)filter2;
- (instancetype) filterByIntersectingWithFilter:(BloomFilter *)filter2;

@end
