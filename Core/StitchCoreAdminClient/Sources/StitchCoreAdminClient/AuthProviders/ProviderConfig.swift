import Foundation
import StitchCoreSDK

/// Base keys for a provider configuration
private enum ConfigKeys: String, CodingKey {
    case type, config, metadataFields = "metadata_fields"
}

/// Keys for the `custom-token` provider configuration
private enum CustomTokenCodingKeys: String, CodingKey {
    case signingKey
}

/// Keys for the `local-userpass` provider configuration
private enum UserpassCodingKeys: String, CodingKey {
    case emailConfirmationURL = "emailConfirmationUrl"
    case resetPasswordURL = "resetPasswordUrl"
    case confirmEmailSubject
    case resetPasswordSubject
}

/// Convenience enum for creating a new provider config. Given that there
/// are only a finite number of providers, this conforms users
/// to only pick one of the available providers
public enum ProviderConfigs: Encodable {
    // Representation of a metadata field that can be configured for an authentication provider
    public struct MetadataField: Codable {
        public init(required: Bool, name: String) {
            self.required = required
            self.name = name
        }

        public let required: Bool
        public let name: String
    }

    case anon()
    /// - parameter emailConfirmationURL: url to redirect user to for email confirmation
    /// - parameter resetPasswordURL: url to redirect user to for password reset
    /// - parameter confirmEmailSubject: subject of the email to confirm a new user
    /// - parameter resetPasswordSubject: subject of the email to reset a password
    case userpass(emailConfirmationURL: String,
                  resetPasswordURL: String,
                  confirmEmailSubject: String,
                  resetPasswordSubject: String)
    /// - parameter signingKey: key used to sign a JWT for `custom-token`
    case custom(signingKey: String,
                metadataFields: [MetadataField])

    private var type: StitchProviderType {
        switch self {
        case .anon: return .anonymous
        case .userpass: return .userPassword
        case .custom: return .custom
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ConfigKeys.self)
        try container.encode(self.type.name, forKey: .type)
        switch self {
        case .anon: break
        case .userpass(let emailConfirmationURL,
                       let resetPasswordURL,
                       let confirmEmailSubject,
                       let resetPasswordSubject):
            var configContainer = container.nestedContainer(keyedBy: UserpassCodingKeys.self,
                                                            forKey: .config)
            try configContainer.encode(emailConfirmationURL, forKey: .emailConfirmationURL)
            try configContainer.encode(resetPasswordURL, forKey: .resetPasswordURL)
            try configContainer.encode(confirmEmailSubject, forKey: .confirmEmailSubject)
            try configContainer.encode(resetPasswordSubject, forKey: .resetPasswordSubject)
        case .custom(let signingKey,
                     let metadataFields):
            try container.encode(metadataFields, forKey: .metadataFields)
            var configContainer = container.nestedContainer(keyedBy: CustomTokenCodingKeys.self,
                                                            forKey: .config)
            try configContainer.encode(signingKey, forKey: .signingKey)
        }
    }
}
