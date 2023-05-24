import Cocoa
import CoreVideo
import simd

/**
Convenience function for initializing an object and modifying its properties.

```
let label = with(NSTextField()) {
	$0.stringValue = "Foo"
	$0.textColor = .systemBlue
	view.addSubview($0)
}
```
*/
@discardableResult
func with<T>(_ item: T, update: (inout T) throws -> Void) rethrows -> T {
	var this = item
	try update(&this)
	return this
}


extension NSBezierPath {
	/**
	Create a path for a superellipse that fits inside the given rect.
	*/
	static func superellipse(in rect: CGRect, cornerRadius: Double) -> Self {
		let minSide = min(rect.width, rect.height)
		let radius = min(cornerRadius, minSide / 2)

		let topLeft = CGPoint(x: rect.minX, y: rect.minY)
		let topRight = CGPoint(x: rect.maxX, y: rect.minY)
		let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
		let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)

		// Top side (clockwise)
		let point1 = CGPoint(x: rect.minX + radius, y: rect.minY)
		let point2 = CGPoint(x: rect.maxX - radius, y: rect.minY)

		// Right side (clockwise)
		let point3 = CGPoint(x: rect.maxX, y: rect.minY + radius)
		let point4 = CGPoint(x: rect.maxX, y: rect.maxY - radius)

		// Bottom side (clockwise)
		let point5 = CGPoint(x: rect.maxX - radius, y: rect.maxY)
		let point6 = CGPoint(x: rect.minX + radius, y: rect.maxY)

		// Left side (clockwise)
		let point7 = CGPoint(x: rect.minX, y: rect.maxY - radius)
		let point8 = CGPoint(x: rect.minX, y: rect.minY + radius)

		let path = self.init()
		path.move(to: point1)
		path.addLine(to: point2)
		path.addCurve(to: point3, controlPoint1: topRight, controlPoint2: topRight)
		path.addLine(to: point4)
		path.addCurve(to: point5, controlPoint1: bottomRight, controlPoint2: bottomRight)
		path.addLine(to: point6)
		path.addCurve(to: point7, controlPoint1: bottomLeft, controlPoint2: bottomLeft)
		path.addLine(to: point8)
		path.addCurve(to: point1, controlPoint1: topLeft, controlPoint2: topLeft)

		return path
	}

	/**
	Create a path for a squircle that fits inside the given `rect`.

	- Precondition: The given `rect` must be square.
	*/
	static func squircle(rect: CGRect) -> Self {
		assert(rect.width == rect.height)
		return superellipse(in: rect, cornerRadius: rect.width / 2)
	}
}


final class ProgressSquircleShapeLayer: CAShapeLayer {
	convenience init(rect: CGRect) {
		self.init()
		fillColor = nil
		lineCap = .round
		position = .zero
		strokeEnd = 0

		let cgPath = NSBezierPath
			.squircle(rect: rect)
			.rotating(byRadians: .pi, centerPoint: rect.center)
			.reversed
			.cgPath

		path = cgPath
		bounds = cgPath.boundingBox
	}

	var progress: Double {
		get { strokeEnd }
		set {
			// Multiplying by `1.02` ensures that the start and end points meet at the end. Needed because of the round line cap.
			strokeEnd = newValue * 1.02
		}
	}
}


extension NSBezierPath {
	/**
	For making a circle progress indicator.
	*/
	static func progressCircle(radius: Double, center: CGPoint) -> Self {
		let startAngle = 90.0
		let path = self.init()
		path.appendArc(
			withCenter: center,
			radius: radius,
			startAngle: startAngle,
			endAngle: startAngle - 360,
			clockwise: true
		)
		return path
	}
}


final class ProgressCircleShapeLayer: CAShapeLayer {
	convenience init(radius: Double, center: CGPoint) {
		self.init()
		fillColor = nil
		lineCap = .round
		position = center
		strokeEnd = 0

		let cgPath = NSBezierPath.progressCircle(radius: radius, center: center).cgPath
		path = cgPath
		bounds = cgPath.boundingBox
	}

	var progress: Double {
		get { strokeEnd }
		set {
			// Multiplying by `1.02` ensures that the start and end points meet at the end. Needed because of the round line cap.
			strokeEnd = newValue * 1.02
		}
	}
}


extension NSColor {
	func withAlpha(_ alpha: Double) -> NSColor {
		withAlphaComponent(alpha)
	}
}


extension NSFont {
	static let helveticaNeueBold = NSFont(name: "HelveticaNeue-Bold", size: 0)
}


extension CGRect {
	var center: CGPoint {
		get { CGPoint(x: midX, y: midY) }
		set {
			origin = CGPoint(
				x: newValue.x - (size.width / 2),
				y: newValue.y - (size.height / 2)
			)
		}
	}
}


extension NSBezierPath {
	/**
	UIKit polyfill.
	*/
	var cgPath: CGPath {
		let path = CGMutablePath()
		var points = [CGPoint](repeating: .zero, count: 3)

		for index in 0..<elementCount {
			let type = element(at: index, associatedPoints: &points)
			switch type {
			case .moveTo:
				path.move(to: points[0])
			case .lineTo:
				path.addLine(to: points[0])
			case .curveTo:
				path.addCurve(to: points[2], control1: points[0], control2: points[1])
			case .closePath:
				path.closeSubpath()
			@unknown default:
				assertionFailure("NSBezierPath received a new enum case. Please handle it.")
			}
		}

		return path
	}

	/**
	UIKit polyfill.
	*/
	convenience init(roundedRect rect: CGRect, cornerRadius: CGFloat) { // swiftlint:disable:this no_cgfloat
		self.init(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
	}

	/**
	UIKit polyfill.
	*/
	func addLine(to point: CGPoint) {
		line(to: point)
	}

	/**
	UIKit polyfill.
	*/
	func addCurve(to endPoint: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
		curve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
	}
}


extension NSBezierPath {
	func copyPath() -> Self {
		copy() as! Self
	}

	func rotationTransform(byRadians radians: Double, centerPoint point: CGPoint) -> AffineTransform {
		var transform = AffineTransform()
		transform.translate(x: point.x, y: point.y)
		transform.rotate(byRadians: radians)
		transform.translate(x: -point.x, y: -point.y)
		return transform
	}

	func rotating(byRadians radians: Double, centerPoint point: CGPoint) -> Self {
		let path = copyPath()

		guard radians != 0 else {
			return path
		}

		let transform = rotationTransform(byRadians: radians, centerPoint: point)
		path.transform(using: transform)
		return path
	}
}


/**
Fixes the vertical alignment issue of the `CATextLayer` class.
*/
final class VerticallyCenteredTextLayer: CATextLayer {
	convenience init(frame rect: CGRect, center: CGPoint) {
		self.init()
		frame = rect
		frame.center = center
		contentsScale = NSScreen.main?.backingScaleFactor ?? 2
	}

	// From https://stackoverflow.com/a/44055040/6863743
	override func draw(in context: CGContext) {
		let height = bounds.size.height
		let deltaY = ((height - fontSize) / 2 - fontSize / 10) * -1

		context.saveGState()
		context.translateBy(x: 0, y: deltaY)
		super.draw(in: context)
		context.restoreGState()
	}
}

enum Easing {
	static func lerp(_ start: Double, _ end: Double, _ t: Double) -> Double {
		return Double(simd_mix(Float(start), Float(end), Float(t)))
	}

	static private func easeIn(_ t: Double) -> Double {
		return Double(simd_smoothstep(0.0, 1.0, Float(t)))
	}

	static private func easeOut(_ t: Double) -> Double {
		return 1 - easeIn(1 - t)
	}

	static func easeInOut(_ t: Double) -> Double {
		return lerp(easeIn(t), easeOut(t), t)
	}
}

typealias DisplayLinkObserverCallback = (DisplayLinkObserver, Double) -> Void;

class DisplayLinkObserver {
	private var displayLink: CVDisplayLink?
	var callback: DisplayLinkObserverCallback
	
	init(_ callback: @escaping DisplayLinkObserverCallback) {
		self.callback = callback
		let result = CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
		assert(result == kCVReturnSuccess, "Failed to create CVDisplayLink")
	}
	
	func start() {
		if let displayLink {
			let result = CVDisplayLinkSetOutputCallback(
				displayLink,
				displayLinkOutputCallback,
				UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
			)
			assert(result == kCVReturnSuccess, "Failed to set CVDisplayLink output callback")
			if (CVDisplayLinkStart(displayLink) != kCVReturnSuccess) {
				print("Warning: CVDisplayLink already running")
			}
		}
	}
	
	func stop() {
		if let displayLink {
			if (CVDisplayLinkStop(displayLink) != kCVReturnSuccess) {
				print("Warning: CVDisplayLink already stopped")
			}
		}
	}
}

private func displayLinkOutputCallback(
	displayLink: CVDisplayLink,
	inNow: UnsafePointer<CVTimeStamp>,
	inOutputTime: UnsafePointer<CVTimeStamp>,
	flagsIn: CVOptionFlags,
	flagsOut: UnsafeMutablePointer<CVOptionFlags>,
	displayLinkContext: UnsafeMutableRawPointer?
) -> CVReturn {
	let observer = unsafeBitCast(displayLinkContext, to: DisplayLinkObserver.self)
	var refreshPeriod = CVDisplayLinkGetActualOutputVideoRefreshPeriod(displayLink)
	if (refreshPeriod == 0) {
		print("Warning: CVDisplayLinkGetActualOutputVideoRefreshPeriod failed. Assuming 60 Hz...")
		refreshPeriod = 1.0 / 60.0
	}
	observer.callback(observer, refreshPeriod)
	return kCVReturnSuccess
}
