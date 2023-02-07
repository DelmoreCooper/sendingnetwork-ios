// Objective-C API for talking to github.com/matrix-org/dendrite/build/gobind-libp2p Go package.
//   gobind -lang=objc github.com/matrix-org/dendrite/build/gobind-libp2p
//
// File is generated by gobind. Do not edit.

#ifndef __Radixmobile_H__
#define __Radixmobile_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


@class RadixmobileBindLogger;
@class RadixmobileRadixMonolith;

@interface RadixmobileBindLogger : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
- (BOOL)write:(NSData* _Nullable)p0 n:(long* _Nullable)n error:(NSError* _Nullable* _Nullable)error;
@end

@interface RadixmobileRadixMonolith : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull storageDirectory;
@property (nonatomic) NSString* _Nonnull cacheDirectory;
@property (nonatomic) NSString* _Nonnull homeServer;
@property (nonatomic) NSString* _Nonnull idServer;
@property (nonatomic) BOOL testNet;
@property (nonatomic) NSString* _Nonnull minOffSrvProtocol;
@property (nonatomic) NSString* _Nonnull cacheStoreEndpoint;
- (NSString* _Nonnull)baseURL;
- (NSString* _Nonnull)connections;
- (NSString* _Nonnull)hostAddrs;
- (long)listenPort;
- (long)peerCount;
- (BOOL)running;
- (void)setInterfacesString:(NSString* _Nullable)interfacesString;
- (void)setListenPort:(long)port;
- (void)setMulticastEnabled:(BOOL)enabled;
- (void)setStaticPeer:(NSString* _Nullable)uri;
/**
 * nolint:gocyclo
 */
- (void)start;
- (void)stop;
@end

@interface Radixmobile : NSObject
+ (NSString* _Nonnull) gitCommit;
+ (void) setGitCommit:(NSString* _Nonnull)v;

@end

#endif
