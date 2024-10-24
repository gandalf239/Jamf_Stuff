#!/bin/zsh -v
loggedInUser=$( /usr/bin/stat -f %Su "/dev/console" )
echo $loggedInUser
# Define the Swift code within a heredoc
swift_script=$(cat <<EOF
import Foundation
import SystemExtensions

// Define a class that will act as the delegate for the OSSystemExtensionRequest
class SystemExtensionHandler: NSObject, OSSystemExtensionRequestDelegate {
    
    // Create an array to hold activation requests
    var activationRequests = [OSSystemExtensionRequest]()
    
    // Method to activate extensions
    func activateExtensions() {
        // Create the first activation request
        let request1 = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: "com.microsoft.OneDrive.FinderSync", queue: DispatchQueue.main)
        activationRequests.append(request1)
        
        // Optionally, create more activation requests and add them to the array
        let request2 = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: "com.microsoft.OneDrive.FileProvider", queue: DispatchQueue.main)
        activationRequests.append(request2)

		 // Optionally, create more activation requests and add them to the array
        let request3 = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: "com.microsoft.onenote.mac.shareextension", queue: DispatchQueue.main)
        activationRequests.append(request3)

		 // Optionally, create more activation requests and add them to the array
        let request4 = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: "com.netmotionwireless.MobilityOSX", queue: DispatchQueue.main)
        activationRequests.append(request4)

		 // Optionally, create more activation requests and add them to the array
        let request5 = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: "com.netmotionwireless.MobilityOSX.Extension", queue: DispatchQueue.main)
        activationRequests.append(request5)

		// Optionally, create more activation requests and add them to the array
        let request6 = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: "com.microsoft.OneDrive-mac.FinderSync", queue: DispatchQueue.main)
        activationRequests.append(request6)
        
        // Set the delegate for each request in the array
        for request in activationRequests {
            request.delegate = self
        }
    }
    
    // Delegate method called when the extension request is loaded
    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        switch result {
        case .completed:
            print("Extension activation completed successfully.")
        case .willCompleteAfterReboot:
            print("Extension activation will complete after reboot.")
        @unknown default:
            print("Unknown result from extension activation request.")
        }
    }
    
    // Delegate method called when the extension request fails
    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        print("Extension activation failed with error: \(error.localizedDescription)")
    }
    
    // Delegate method to handle user approval
    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        print("Extension activation needs user approval.")
    }
    
    // Delegate method called when the request is canceled
    func request(_ request: OSSystemExtensionRequest, didCancelWithError error: Error) {
        print("Extension activation canceled with error: \(error.localizedDescription)")
    }
    
    // Required delegate method for replacing extension
    func request(_ request: OSSystemExtensionRequest, actionForReplacingExtension existing: OSSystemExtensionProperties, withExtension ext: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        return .replace
    }
}

// Create an instance of the handler and call the activateExtensions method
let handler = SystemExtensionHandler()
handler.activateExtensions()

EOF
)
