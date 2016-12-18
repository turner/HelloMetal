
import MetalKit

public class EIView: MTKView {
    
    var renderer:MTKViewDelegate!
    var arcBall:EIArcball!

    required public init(coder: NSCoder) {

        super.init(coder:coder)
        
        // Use 4x MSAA multisampling
        sampleCount = 4
        
        // we will call MTKView.draw() explicitly
        isPaused = true
        enableSetNeedsDisplay = true

        device = MTLCreateSystemDefaultDevice()!

        arcBall = EIArcball(view:self)

        addGestureRecognizer(UIPanGestureRecognizer.init(
            target: arcBall,
            action: #selector(EIArcball.arcBallPanHandler)))

    }
}
