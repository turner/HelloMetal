
import MetalKit

public class EIView: MTKView {
    
    var arcBall:EIArcball!
    var defaultLibrary:MTLLibrary!
    
    required public init(coder: NSCoder) {
        
        super.init(coder:coder)

        guard let dd = MTLCreateSystemDefaultDevice() else {
            fatalError("Can not create Metal device")
        }
        
        device = dd

        guard let dl = device!.makeDefaultLibrary() else {
            fatalError("Error: Can not create default library")
        }

        defaultLibrary = dl

        //
        sampleCount = 4
//        sampleCount = 1
        
        //
        depthStencilPixelFormat = .depth32Float
        clearDepth = 1.0
        
        // TODO: Figure out how to use half
//        colorPixelFormat = /* I want to use half */
        clearColor = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        // we will call MTKView.draw() explicitly
        isPaused = true
        enableSetNeedsDisplay = true

        arcBall = EIArcball(view:self)
        addGestureRecognizer(UIPanGestureRecognizer.init(target: arcBall, action: #selector(EIArcball.arcBallPanHandler)))
        
    }
}
