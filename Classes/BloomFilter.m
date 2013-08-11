//
//  BloomFilter.m
//  Pods
//
//  Created by Mathieu D'Amours on 5/16/13.
//
//

#import "BloomFilter.h"

bloom_filter_hash_func BloomFilterStringHash                    = string_hash;
bloom_filter_hash_func BloomFilterCaseInsensitiveStringHash     = string_nocase_hash;
bloom_filter_hash_func BloomFilterJenkinsHash                   = jenkins_hash;
bloom_filter_hash_func BloomFilterCaseInsensitiveJenkinsHash    = jenkins_nocase_hash;

bloom_filter_value filter_value_from_objc_object(id object, NSStringEncoding encoding) {
    if ([object isKindOfClass:[NSString class]]) {
        if ([(NSString *)object canBeConvertedToEncoding:encoding])
            return (void *)[(NSString *)object cStringUsingEncoding:encoding];
        else
            return "\0";
    
    } else if ([object isKindOfClass:[NSData class]])
        return (void *)[object bytes];
        
    else
        return "\0";
}

@implementation BloomFilter {
    bloom_filter_s * _bloomFilter;
    BloomFilterOptions _options;
}

+ (instancetype) filterByIntersectingFilters:(NSArray *)filters {
    __block bloom_filter_s * __bloomFilter;
    BloomFilterOptions options;
    if ([filters count] > 1) {
        __bloomFilter = ((BloomFilter *)filters[0])->_bloomFilter;
        options = ((BloomFilter *)filters[0])->_options;
        [filters enumerateObjectsUsingBlock:^(BloomFilter *filter, NSUInteger idx, BOOL *stop) {
            if (idx == 0) return;
            __bloomFilter = bloom_filter_intersection(__bloomFilter, filter->_bloomFilter);
        }];
        return [[[super alloc] initWithOptions:options andFilter:__bloomFilter] autorelease];
        
    } else
        return nil;
}
+ (instancetype) filterFromUnionOfFilters:(NSArray *)filters {
    __block bloom_filter_s * __bloomFilter;
    BloomFilterOptions options;
    if ([filters count] > 1) {
        __bloomFilter = ((BloomFilter *)filters[0])->_bloomFilter;
        options = ((BloomFilter *)filters[0])->_options;
        [filters enumerateObjectsUsingBlock:^(BloomFilter *filter, NSUInteger idx, BOOL *stop) {
            if (idx == 0) return;
            __bloomFilter = bloom_filter_union(__bloomFilter, filter->_bloomFilter);
        }];
        return [[[super alloc] initWithOptions:options andFilter:__bloomFilter] autorelease];
        
    } else
        return nil;
}

+ (instancetype)filterWithProbability:(float)probability
                     forNumberOfItems:(size_t)numberOfItems
                             encoding:(NSStringEncoding)encoding
                      andHashFunction:(bloom_filter_hash_func)func {
    
    size_t table_size = ceil((numberOfItems * log(probability)) / log(1.0 / (pow(2.0, log(2.0)))));
    size_t num_funcs = round(log(2.0) * table_size / numberOfItems);
    
    return [self filterWithTableSize:table_size
                    numberOfFunction:num_funcs
                            encoding:encoding
                     andHashFunction:func];
}

+ (instancetype)filterWithTableSize:(size_t)tableSize
                   numberOfFunction:(size_t)numFunction
                           encoding:(NSStringEncoding)encoding
                    andHashFunction:(bloom_filter_hash_func)func {
    
    return [[(BloomFilter *)[self alloc] initWithOptions:(BloomFilterOptions){
        .num_functions = numFunction,
        .table_size = tableSize,
        .encoding = encoding,
        .hashfun = func
    }] autorelease];
}

- (instancetype) init {
    return [self initWithOptions:(BloomFilterOptions){
        .num_functions = 5,
        .table_size = 10000,
        .encoding = NSUTF8StringEncoding,
        .hashfun = BloomFilterJenkinsHash
    }];
}
- (instancetype) initWithOptions:(BloomFilterOptions)options andFilter:(bloom_filter_s *)filter {
    self = [super init];
    if (self) {
        _options = options;
        _bloomFilter = filter;
    }
    return self;
}
- (instancetype) initWithOptions:(BloomFilterOptions)options {
    self = [super init];
    if (self) {
        _options = options;
        if (!options.hashfun)
            options.hashfun = BloomFilterJenkinsHash;
        
        _bloomFilter = bloom_filter_new(options.table_size, options.hashfun, options.num_functions);
    }
    return self;
}

- (void) addObject:(id)object {
    bloom_filter_insert(_bloomFilter, filter_value_from_objc_object(object, _options.encoding));
}
- (BOOL) containsObject:(id)object {
    return (BOOL) bloom_filter_query(_bloomFilter, filter_value_from_objc_object(object, _options.encoding));
}

- (instancetype) filterByIntersectingWithFilter:(BloomFilter *)filter2 {
    return [[[BloomFilter alloc] initWithOptions:_options
                                      andFilter:bloom_filter_intersection(self->_bloomFilter, filter2->_bloomFilter)] autorelease];
}
- (instancetype) filterFromUnionWithFilter:(BloomFilter *)filter2 {
    return [[[BloomFilter alloc] initWithOptions:_options
                                      andFilter:bloom_filter_union(self->_bloomFilter, filter2->_bloomFilter)] autorelease];
}

- (void) dealloc {
    bloom_filter_free(_bloomFilter);
    [super dealloc];
}

@end
