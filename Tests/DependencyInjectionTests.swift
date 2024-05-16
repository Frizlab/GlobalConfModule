import Foundation
import XCTest

/* No @testable import: we mostly test whether the architecture works; we must be as close as possible to a regular client’s use. */
import DependencyInjection



final class DependencyInjectionTests : XCTestSuite {
	
	func testUsingNoActorService() {
//		Injected<NoActorService>.value(NoActorService.AutoInjectionKey.self, on: DummyInjectionActor.shared).printHello()
	}
	
//	@MainActor
//	func testUsingMainActorService() {
//		MainActor.preconditionIsolated()
//		Injected<MainActorService>.value(MainActorService.AutoInjectionKey.self, on: MainActor.shared).printHello()
//	}
	
}
