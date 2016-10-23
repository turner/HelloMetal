
import MetalKit

public class HelloModel_IOMetalView: MTKView {
    
    var renderer: HelloModel_IORenderer!
    var arcBall: EIArcball!

    required public init(coder: NSCoder) {
        
        super.init(coder: coder)

        self.device = MTLCreateSystemDefaultDevice()!
        self.renderer = HelloModel_IORenderer(view: self, device: self.device!)
        self.delegate = self.renderer
        
        arcBall = EIArcball.init(viewBounds: self.bounds)
        
        self.addGestureRecognizer(UIPanGestureRecognizer.init(
            target: arcBall,
            action: #selector(EIArcball.arcBallPanHandler)))
        
    }

}
