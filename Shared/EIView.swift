
import MetalKit

public class EIView: MTKView {
    
    var arcBall:EIArcball!

    required public init(coder: NSCoder) {

        super.init(coder:coder)
        
        //        
        sampleCount = 4
//        sampleCount = 1
        
        //
        depthStencilPixelFormat = .depth32Float
        
        // we will call MTKView.draw() explicitly
        isPaused = true
        enableSetNeedsDisplay = true

        arcBall = EIArcball(view:self)
        addGestureRecognizer(UIPanGestureRecognizer.init(target: arcBall, action: #selector(EIArcball.arcBallPanHandler)))

        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Can not create Metal device")
        }
        
        device = defaultDevice

    }
}
