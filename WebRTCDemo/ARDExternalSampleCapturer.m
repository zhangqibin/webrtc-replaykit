/*
 *  Copyright 2018 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ARDExternalSampleCapturer.h"

#import "ARDUtilities.h"
#import <WebRTC/WebRTC.h>

const CGFloat kMaximumSupportedResolution = 480;

@implementation ARDExternalSampleCapturer {
    int64_t lastMemoryReportTimeStamp;
}

- (instancetype)initWithDelegate:(__weak id<RTCVideoCapturerDelegate>)delegate {
  return [super initWithDelegate:delegate];
}

#pragma mark - ARDExternalSampleDelegate

- (void)didCaptureSampleBuffer:(CMSampleBufferRef)sampleBuffer {
  if (CMSampleBufferGetNumSamples(sampleBuffer) != 1 || !CMSampleBufferIsValid(sampleBuffer) ||
      !CMSampleBufferDataIsReady(sampleBuffer)) {
    return;
  }

  CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  if (pixelBuffer == nil) {
    return;
  }

  RTCCVPixelBuffer * rtcPixelBuffer = nil;
  CGFloat originalWidth = (CGFloat)CVPixelBufferGetWidth(pixelBuffer);
  CGFloat originalHeight = (CGFloat)CVPixelBufferGetHeight(pixelBuffer);
  // Downscale the buffer due to the big memory footprint (> 50MB) for bigger then 720p resolutions
  if (originalWidth > kMaximumSupportedResolution) {
      size_t width = originalWidth * kMaximumSupportedResolution / originalHeight;
      size_t height = kMaximumSupportedResolution;
      if (originalWidth > originalHeight) {
          width = kMaximumSupportedResolution;
          height = originalHeight * kMaximumSupportedResolution / originalWidth;
      }
    CVPixelBufferRef croppedAndScaled = resizePixelBuffer(pixelBuffer, width, height);
    rtcPixelBuffer = [[RTCCVPixelBuffer alloc] initWithPixelBuffer: croppedAndScaled];
    CVPixelBufferRelease(croppedAndScaled);
  } else {
    rtcPixelBuffer = [[RTCCVPixelBuffer alloc] initWithPixelBuffer: pixelBuffer];
  }
  int64_t timeStampSec = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
  RTCVideoFrame *videoFrame = [[RTCVideoFrame alloc] initWithBuffer:rtcPixelBuffer
                                                           rotation:RTCVideoRotation_0
                                                        timeStampNs:timeStampSec * NSEC_PER_SEC];
  [self.delegate capturer:self didCaptureVideoFrame:videoFrame];
    
  if (timeStampSec - lastMemoryReportTimeStamp > 1) {
    RTCLog(@"MEM:%lu", ARDGetGetMemoryFootprint());
    lastMemoryReportTimeStamp = timeStampSec;
  }
}

@end
