import Foundation

import SwiftDiagnostics



public struct SimpleDiagnosticMessage : DiagnosticMessage {
	
	public var message: String
	public var diagnosticID: MessageID
	public var severity: DiagnosticSeverity
	
	init(message: String, diagnosticID: MessageID, severity: DiagnosticSeverity) {
		self.message = message
		self.diagnosticID = diagnosticID
		self.severity = severity
	}
	
}
