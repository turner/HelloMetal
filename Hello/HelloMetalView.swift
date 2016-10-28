
import MetalKit

public class HelloMetalView: MTKView {
    
    var renderer: HelloRenderer!
    var arcBall: EIArcball!

    required public init(coder: NSCoder) {
        
        super.init(coder: coder)

        self.device = MTLCreateSystemDefaultDevice()!
        self.renderer = HelloRenderer(view: self, device: self.device!)
        self.delegate = self.renderer
        
        arcBall = EIArcball.init(viewBounds: self.bounds)
        
        self.addGestureRecognizer(UIPanGestureRecognizer.init(
            target: arcBall,
            action: #selector(EIArcball.arcBallPanHandler)))
        
    }

}
