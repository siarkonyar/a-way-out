//
//  NFCManager.swift
//  A Way Out
//

import Combine
import CoreNFC
import Foundation

final class NFCManager: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var lastError: String?

    private var session: NFCTagReaderSession?
    private var onTagRead: ((String) -> Void)?

    private var successMessage = "Tag read!"

    func startRegistration(onRead: @escaping (String) -> Void) {
        start(
            alertMessage: "Hold your NFC tag near the top of your iPhone.",
            successMessage: "Tag registered!",
            onRead: onRead
        )
    }

    func startReading(alertMessage: String = "Hold your NFC tag near the top of your iPhone.", successMessage: String = "Tag read!", onRead: @escaping (String) -> Void) {
        start(alertMessage: alertMessage, successMessage: successMessage, onRead: onRead)
    }

    private func start(alertMessage: String, successMessage: String, onRead: @escaping (String) -> Void) {
        guard NFCTagReaderSession.readingAvailable else {
            lastError = "NFC is not available on this device."
            return
        }
        onTagRead = onRead
        self.successMessage = successMessage
        lastError = nil
        session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693], delegate: self, queue: nil)
        session?.alertMessage = alertMessage
        session?.begin()
        DispatchQueue.main.async { self.isScanning = true }
    }
}

extension NFCManager: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isScanning = false
            if let readerError = error as? NFCReaderError,
               readerError.code == .readerSessionInvalidationErrorUserCanceled {
                return
            }
            self.lastError = error.localizedDescription
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else { return }

        session.connect(to: tag) { error in
            if error != nil {
                session.invalidate(errorMessage: "Connection failed. Please try again.")
                return
            }

            let uid: String?
            switch tag {
            case .miFare(let t):   uid = t.identifier.hexString
            case .iso7816(let t):  uid = t.identifier.hexString
            case .iso15693(let t): uid = t.identifier.hexString
            case .feliCa(let t):   uid = t.currentIDm.hexString
            @unknown default:      uid = nil
            }

            guard let uid else {
                session.invalidate(errorMessage: "Unsupported tag type.")
                return
            }

            session.alertMessage = self.successMessage
            session.invalidate()

            DispatchQueue.main.async {
                self.isScanning = false
                self.onTagRead?(uid)
                self.onTagRead = nil
            }
        }
    }
}

private extension Data {
    var hexString: String {
        map { String(format: "%02X", $0) }.joined(separator: ":")
    }
}
