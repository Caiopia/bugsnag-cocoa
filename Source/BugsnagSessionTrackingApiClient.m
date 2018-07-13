//
// Created by Jamie Lynch on 30/11/2017.
// Copyright (c) 2017 Bugsnag. All rights reserved.
//

#import "BugsnagSessionTrackingApiClient.h"
#import "BugsnagConfiguration.h"
#import "BugsnagSessionTrackingPayload.h"
#import "BugsnagSessionFileStore.h"
#import "BugsnagLogger.h"
#import "BugsnagSession.h"
#import "BSG_RFC3339DateTool.h"


@implementation BugsnagSessionTrackingApiClient

- (NSOperation *)deliveryOperation {
    return [NSOperation new];
}

- (void)deliverSessionsInStore:(BugsnagSessionFileStore *)store {
    [self.sendQueue addOperationWithBlock:^{
        if (!self.config.apiKey)
            return;

        NSArray *fileIds = [store fileIds];

        if (fileIds.count <= 0) {
            return;
        }

        NSMutableArray *sessions = [NSMutableArray new];

        for (NSDictionary *dict in [store allFiles]) {
            [sessions addObject:[[BugsnagSession alloc] initWithDictionary:dict]];
        }
        BugsnagSessionTrackingPayload *payload = [[BugsnagSessionTrackingPayload alloc] initWithSessions:sessions];
        NSUInteger sessionCount = payload.sessions.count;
        if (sessionCount > 0) {
            NSDictionary *HTTPHeaders = @{
                                          @"Bugsnag-Payload-Version": @"1.0",
                                          @"Bugsnag-API-Key": self.config.apiKey,
                                          @"Bugsnag-Sent-At": [BSG_RFC3339DateTool stringFromDate:[NSDate new]]
                                          };
            [self sendData:payload
               withPayload:[payload toJson]
                     toURL:self.config.sessionURL
                   headers:HTTPHeaders
              onCompletion:^(id data, BOOL success, NSError *error) {
                  if (success && error == nil) {
                      bsg_log_info(@"Sent %lu sessions to Bugsnag", (unsigned long)sessionCount);

                      for (NSString *fileId in fileIds) {
                          [store deleteFileWithId:fileId];
                      }
                  } else {
                      bsg_log_warn(@"Failed to send sessions to Bugsnag: %@", error);
                  }
              }];
        }
    }];
}

@end
