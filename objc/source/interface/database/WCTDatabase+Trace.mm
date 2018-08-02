/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <WCDB/Assertion.hpp>
#import <WCDB/Interface.h>
#import <WCDB/WCTCore+Private.h>
#import <WCDB/WCTError+Private.h>

@implementation WCTDatabase (Trace)

+ (void)globalTraceError:(WCTErrorTraceBlock)block
{
    WCDB::Notifier::Callback callback = nullptr;
    if (block) {
        callback = [block](const WCDB::Error &error) {
            WCTError *nsError = [[WCTError alloc] initWithError:error];
            block(nsError);
        };
    }
    WCDB::Core::notifier()->setNotification(callback);
}

+ (void)resetGlobalTraceError
{
    WCDB::Core::notifier()->setNotification(WCDB::CoreNotifier::logger);
}

+ (void)globalTracePerformance:(WCTPerformanceTraceBlock)trace
{
    WCDB::Handle::PerformanceNotification callback = nullptr;
    if (trace) {
        callback = [trace](const WCDB::HandleNotification::Footprints &footprints, const int64_t &cost) {
            NSMutableArray<WCTPerformanceFootprint *> *array = [[NSMutableArray<WCTPerformanceFootprint *> alloc] init];
            for (const auto &footprint : footprints) {
                NSString *sql = [NSString stringWithCppString:footprint.sql];
                [array addObject:[[WCTPerformanceFootprint alloc] initWithSQL:sql andFrequency:footprint.frequency]];
            }
            trace(array, (NSUInteger) cost);
        };
    }
    WCDB::Core::globalPerformanceTraceConfig()->setNotification(callback);
}

+ (void)globalTraceSQL:(WCTSQLTraceBlock)trace
{
    WCDB::Handle::SQLNotification callback = nullptr;
    if (trace) {
        callback = [trace](const std::string &sql) {
            trace([NSString stringWithCppString:sql]);
        };
    }
    WCDB::Core::globalSQLTraceConfig()->setNotification(callback);
}

- (void)tracePerformance:(WCTPerformanceTraceBlock)trace
{
    WCDB::Handle::PerformanceNotification callback = nullptr;
    if (trace) {
        callback = [trace](const WCDB::HandleNotification::Footprints &footprints, const int64_t &cost) {
            NSMutableArray<WCTPerformanceFootprint *> *array = [[NSMutableArray<WCTPerformanceFootprint *> alloc] init];
            for (const auto &footprint : footprints) {
                NSString *sql = [NSString stringWithCppString:footprint.sql];
                [array addObject:[[WCTPerformanceFootprint alloc] initWithSQL:sql andFrequency:footprint.frequency]];
            }
            trace(array, (NSUInteger) cost);
        };
    }
    _database->setNotification(callback);
}

- (void)traceSQL:(WCTSQLTraceBlock)trace
{
    WCDB::Handle::SQLNotification callback = nullptr;
    if (trace) {
        callback = [trace](const std::string &sql) {
            trace([NSString stringWithCppString:sql]);
        };
    }
    _database->setNotification(callback);
}

@end
