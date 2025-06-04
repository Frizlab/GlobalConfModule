import Foundation
import Testing

/* No @testable import: we mostly test whether the architecture works; we must be as close as possible to a regular client’s use. */
import GlobalConfModule



struct UsageMainActorTests {
	
	init() {
		/* For the testNoDefaultValueCalledWhenOverrideIsSet test.
		 * **MUST** be done _before_ the test is initialized. */
		if Thread.isMainThread {
			MainActor.assumeIsolated{
				Conf.setRootValue(NotTrackedInitTrackedServiceMainActor(), for: \.initTrackedServiceMainActor)
			}
		} else {
			DispatchQueue.main.sync{
				Conf.setRootValue(NotTrackedInitTrackedServiceMainActor(), for: \.initTrackedServiceMainActor)
			}
		}
	}
	
	@Test
	@MainActor
	func testUsingMainActorService() {
		MainActor.preconditionIsolated()
		let c = MainActorContainer()
		c.mainActorService.printHello()
		c.mainActorServiceFromKeyPath.printHello()
		InjectedConf<MainActorService>.value.printHello()
		#expect(c.mainActorService === Conf[\.mainActorService])
		#expect(c.mainActorService === Conf[key: MainActorService.AutoInjectionKey.self])
		#expect(c.mainActorService === Conf.rootValue(for: MainActorService.AutoInjectionKey.self))
		#expect(c.mainActorService === InjectedConf<MainActorService>.value)
		#expect(c.mainActorServiceFromKeyPath === InjectedConf<MainActorService>.value)
		
		#expect(c.otherMainActorService !== InjectedConf<MainActorService>.value)
		
		let oldOtherActor = c.otherMainActorService
		Conf.setRootValue(c.mainActorService, for: \.mainActorService2)
		#expect(c.otherMainActorService === InjectedConf<MainActorService>.value)
		
		Conf.withValue(oldOtherActor, for: \.mainActorService2, operation: {
			#expect(c.mainActorService === Conf[\.mainActorService])
			#expect(c.otherMainActorService === oldOtherActor)
			#expect(c.otherMainActorService !== InjectedConf<MainActorService>.value)
		})
		
		Conf.withValues{
			$0[\.mainActorService2] = MainActorService()
		}operation:{
			#expect(c.otherMainActorService !== oldOtherActor)
			#expect(c.otherMainActorService !== InjectedConf<MainActorService>.value)
		}
		
		InjectedConf<MainActorService>.withValue(MainActorService()){
			#expect(c.otherMainActorService !== oldOtherActor)
			#expect(c.otherMainActorService !== InjectedConf<MainActorService>.value)
		}
		
		#expect(c.otherMainActorService === InjectedConf<MainActorService>.value)
		
		InjectedConf<MainActorService>.rootValue = oldOtherActor
		#expect(c.otherMainActorService !== c.mainActorService)
	}
	
	@MainActor
	struct MainActorContainer {
		
		@InjectedConf()
		var mainActorService: MainActorService
		@InjectedConf(\.mainActorService)
		var mainActorServiceFromKeyPath
		
		@InjectedConf(\.mainActorService2)
		var otherMainActorService: MainActorService
		
		@InjectedConf(\.initTrackedServiceMainActor)
		var initTrackedServiceMainActor: InitTrackedServiceMainActor
		
	}
	
	
	@Test
	@MainActor
	func testNoDefaultValueCalledWhenOverrideIsSet() {
		let c = MainActorContainer()
		_ = c.initTrackedServiceMainActor
		_ = Conf[\.initTrackedServiceMainActor]
		#expect(DefaultInitTrackedServiceMainActor.initCount == 0)
	}
	
}


protocol InitTrackedServiceMainActor : Sendable {}
struct DefaultInitTrackedServiceMainActor : InitTrackedServiceMainActor {
	
	static var initCount: Int {
		initLock.withLock{ _initCount }
	}
	nonisolated(unsafe) static var _initCount: Int = 0
	private static let initLock = NSLock()
	
	init() {
		Self.initLock.withLock{
			Self._initCount += 1
		}
	}
	
}
struct NotTrackedInitTrackedServiceMainActor : InitTrackedServiceMainActor {
}
extension ConfKeys {
	#declareServiceKey(visibility: .internal, "initTrackedServiceMainActor", InitTrackedServiceMainActor.self, on: MainActor.self, defaultValue: DefaultInitTrackedServiceMainActor())
}
