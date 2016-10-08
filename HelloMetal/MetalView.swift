
import MetalKit

public class MetalView: MTKView {
    
    var renderer: Renderer!
    var arcBall: EISArcball!

    required public init(coder: NSCoder) {
        
        super.init(coder: coder)

        self.device = MTLCreateSystemDefaultDevice()!
        self.renderer = Renderer(device: self.device!)
        self.delegate = self.renderer
        
        arcBall = EISArcball.init(viewBounds: self.bounds)
        
        self.addGestureRecognizer(UIPanGestureRecognizer.init(
            target: arcBall,
            action: #selector(EISArcball.arcBallPanHandler)))
        
    }

//    override public func draw(_ dirtyRect: CGRect) {
//
//        super.draw(dirtyRect)
//
//        renderer.update(view:self, drawableSize: drawableSize)
//
//        renderer.draw(view:self)
//
//    }

}
