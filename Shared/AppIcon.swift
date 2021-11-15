import SwiftUI

struct AppIcon: View {
	@Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
	@State private var isRotating = false
	@State private var isFlipping = false

	var body: some View {
		if accessibilityReduceMotion {
			Image("AppIconForView")
				.resizable()
				.aspectRatio(contentMode: .fit)
		} else {
			animatedIcon
		}
	}

	private var animatedIcon: some View {
		ZStack {
			Image("AppIconForViewBackground")
				.resizable()
				.aspectRatio(contentMode: .fit)
			Image("AppIconForViewCog")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.rotationEffect(.degrees(isRotating ? 360 : 0))
				.animation(.linear(duration: 5).repeatForever(autoreverses: false), value: isRotating)
			Image("AppIconForViewPlay")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.scaleEffect(isRotating ? 1.05 : 1)
				.animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isRotating)
		}
			.rotation3DEffect(.degrees(isRotating ? 10 : -2), axis: (x: 1, y: 0, z: 0))
			.animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isRotating)
			.rotation3DEffect(.degrees(isFlipping ? 720 : 0), axis: (x: 1, y: 1, z: isFlipping ? 1 : 0), perspective: 1)
			.animation(.interactiveSpring(response: 0.7, dampingFraction: 4, blendDuration: 1), value: isFlipping)
			.onTapGesture {
				isFlipping.toggle()
			}
			.task {
				isRotating.toggle()
			}
	}
}
