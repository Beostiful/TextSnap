import Vision
import CoreGraphics

enum OCR {
    /// Recognize text in the image using Vision. Uses accurate recognition and
    /// auto-detects language (macOS 13+), so any script Vision supports works.
    static func recognize(image: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            let request = VNRecognizeTextRequest { req, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = (req.results as? [VNRecognizedTextObservation]) ?? []
                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: lines.joined(separator: "\n"))
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            if #available(macOS 13.0, *) {
                request.automaticallyDetectsLanguage = true
            } else if let supported = try? VNRecognizeTextRequest.supportedRecognitionLanguages(
                for: .accurate, revision: VNRecognizeTextRequestRevision3) {
                request.recognitionLanguages = supported
            }

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
