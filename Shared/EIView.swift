
import MetalKit

public class EIView: MTKView {
    
    var renderer: MTKViewDelegate!
    var arcBall: EIArcball!

    required public init(coder: NSCoder) {

        super.init(coder: coder)

        device = MTLCreateSystemDefaultDevice()!

        arcBall = EIArcball.init(viewBounds: bounds)

        addGestureRecognizer(UIPanGestureRecognizer.init(
            target: arcBall,
            action: #selector(EIArcball.arcBallPanHandler)))

    }
}
