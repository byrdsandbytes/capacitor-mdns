import Capacitor
import Foundation

/**
 * Capacitor bridge for the iOS mDNS plugin.
 *
 * Responsibilities:
 * - Exposes the native MDNS manager to JavaScript.
 * - Validates and normalizes params (ensures trailing dot in type, sensible defaults).
 * - Never rejects on runtime errors; always resolves with { error, errorMessage }.
 *
 * Methods:
 * - startBroadcast({ type?, name?, port, txt? })
 * - stopBroadcast()
 * - discover({ type?, name?, timeout? })
 */
@objc(mDNSPlugin)
public class mDNSPlugin: CAPPlugin, CAPBridgedPlugin {

    public let identifier = "mDNSPlugin"
    public let jsName = "mDNS"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "getPluginPlatform", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "startBroadcast", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "stopBroadcast", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "discover", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "startDiscovery", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "stopDiscovery", returnType: CAPPluginReturnPromise)
    ]

    private let mdns = MDNS()

    // MARK: - Helpers

    private func jnull(_ v: String?) -> Any {
        return v ?? NSNull()
    }

    private func normalizeType(_ raw: String?) -> String {
        var t = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if t.isEmpty { t = "_http._tcp." }
        if t.last != "." { t += "." }
        return t
    }

    // MARK: - API

    /// getPluginPlatform()
    @objc public func getPluginPlatform(_ call: CAPPluginCall) {
        call.resolve([
            "platform": "ios"
        ])
    }

    /// startBroadcast({ type?, name?, port, txt? })
    @objc public func startBroadcast(_ call: CAPPluginCall) {
        let type = normalizeType(call.getString("type"))
        let name = (call.getString("name")?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 } ?? "DevIOArtsMDNS"
        let port = call.getInt("port") ?? 0
        let txt  = call.getObject("txt") as? [String: String]

        guard (1...65535).contains(port) else {
            call.resolve([
                "publishing": false,
                "name": "",
                "error": true,
                "errorMessage": "Missing/invalid port"
            ])
            return
        }

        mdns.broadcast(type: type, name: name, port: port, txt: txt) { result in
            switch result {
            case .success(let finalName):
                call.resolve([
                    "publishing": true,
                    "name": finalName,
                    "error": false,
                    "errorMessage": NSNull()
                ])
            case .failure(let err):
                call.resolve([
                    "publishing": false,
                    "name": "",
                    "error": true,
                    "errorMessage": self.jnull(err.localizedDescription)
                ])
            }
        }
    }

    /// stopBroadcast()
    @objc public func stopBroadcast(_ call: CAPPluginCall) {
        do {
            try mdns.stopBroadcast()
            call.resolve([
                "publishing": false,
                "error": false,
                "errorMessage": NSNull()
            ])
        } catch {
            call.resolve([
                "publishing": false,
                "error": true,
                "errorMessage": jnull(error.localizedDescription)
            ])
        }
    }

    /// discover({ type?, name?, timeout? })
    @objc public func discover(_ call: CAPPluginCall) {
        let type = normalizeType(call.getString("type"))
        let targetName = (call.getString("name")?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 }
        let timeout = call.getInt("timeout") ?? 3000
        let useNW = call.getBool("useNW") ?? true

        mdns.discover(type: type, name: targetName, timeoutMs: timeout, useNW: useNW) { result in
            switch result {
            case .success(let services):
                call.resolve([
                    "error": false,
                    "errorMessage": NSNull(),
                    "servicesFound": services.count,
                    "services": services
                ])
            case .failure(let err):
                call.resolve([
                    "error": true,
                    "errorMessage": self.jnull(err.localizedDescription),
                    "servicesFound": 0,
                    "services": []
                ])
            }
        }
    }
    
    /// startDiscovery({ type?, name? })
    @objc public func startDiscovery(_ call: CAPPluginCall) {
        let type = normalizeType(call.getString("type"))
        let targetName = (call.getString("name")?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 }
        let useNW = call.getBool("useNW") ?? true

        mdns.startDiscovery(
            type: type,
            name: targetName,
            useNW: useNW,
            onFound: { [weak self] svc in
                self?.notifyListeners("mDNS:ServiceFound", data: svc)
            },
            onLost: { [weak self] svc in
                self?.notifyListeners("mDNS:ServiceLost", data: svc)
            },
            completion: { [weak self] error in
                guard self != nil else { return }
                if let error = error {
                    call.reject(error.localizedDescription)
                } else {
                    call.resolve()
                }
            }
        )
    }

    /// stopDiscovery()
    @objc public func stopDiscovery(_ call: CAPPluginCall) {
        mdns.stopDiscovery()
        call.resolve()
    }
}
