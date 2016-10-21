
import MetalKit

public class HelloQuadMetalView: MTKView {
    
    var renderer: HelloQuadRenderer!
    var arcBall: EISArcball!

    required public init(coder: NSCoder) {
        
        super.init(coder: coder)

        self.device = MTLCreateSystemDefaultDevice()!
        self.renderer = HelloQuadRenderer(view: self, device: self.device!)
        self.delegate = self.renderer
        
        arcBall = EISArcball.init(viewBounds: self.bounds)
        
        self.addGestureRecognizer(UIPanGestureRecognizer.init(
            target: arcBall,
            action: #selector(EISArcball.arcBallPanHandler)))
        
    }

}
