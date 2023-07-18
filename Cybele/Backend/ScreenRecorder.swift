//
//  ScreenRecorder.swift
//  Cybele
//
//  Created by Serena on 17/07/2023.
//  

import Foundation
import AVFoundation

struct ScreenRecorder {
    private let captureSession = AVCaptureSession()
    private let output: AVCaptureMovieFileOutput
    private let url: URL
    private let delegate: RecordingDelegate

    
    init(displayID: CGDirectDisplayID = CGMainDisplayID(), cropRect: CGRect? = nil) async throws {
        let date = Date()
        
        self.output = AVCaptureMovieFileOutput()
        
        // the `com.apple.screencapture` domain has the user set path for where they want to store screenshots or videos
        let locationPath = (UserDefaults(suiteName: "com.apple.screencapture")?.string(forKey: "location") ?? NSHomeDirectory()) as NSString
        
        self.url = URL(fileURLWithPath: locationPath.expandingTildeInPath)
            .appendingPathComponent(
                "Screen Recording at \(DateFormatter.mediaFirstPartFormatter.string(from: date)) at \(DateFormatter.mediaSecondPartFormatter.string(from: date))"
            )
            .appendingPathExtension("mov")
        
        self.delegate = RecordingDelegate()

        // Create AVCaptureScreenInput for displayID
        guard let videoInput = AVCaptureScreenInput(displayID: displayID) else {
            throw RecordingError("Can't find \(displayID) as active display")
        }

        if let cropRect = cropRect {
            // AVFoundation uses bottom-left of screen as origin
            videoInput.cropRect = cropRect
        }


        // Add AVCaptureScreenInput as input AVCaptureSession
        guard captureSession.canAddInput(videoInput) else {
            throw RecordingError("Can't add input device to session")
        }
        captureSession.addInput(videoInput)


        // Add AVCaptureMovieFileOutput as output to AVCaptureSession
        guard captureSession.canAddOutput(output) else {
            throw RecordingError("Can't add output to session")
        }
        captureSession.addOutput(output)

        // Blocking call to start running the AVCaptureSession
        captureSession.startRunning()
    }

    func start() async throws {
        output.startRecording(to: url, recordingDelegate: delegate) // Note: potentially throws NSException
    }

    func stop() async throws {
        try await withCheckedThrowingContinuation { continuation in
            delegate.finishedContinuation = continuation
            output.stopRecording()
        }
        
        delegate.finishedContinuation = nil // Don't leak continuation

        // Blocking call to stop running the AVCaptureSession
        captureSession.stopRunning()
    }

    private class RecordingDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {
        var finishedContinuation: CheckedContinuation<Void, Error>?

        func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
            if let error {
                finishedContinuation?.resume(throwing: error)
            } else {
                finishedContinuation?.resume()
            }
        }
    }
}


struct RecordingError: Error, CustomDebugStringConvertible {
    var debugDescription: String
    init(_ debugDescription: String) { self.debugDescription = debugDescription }
}
