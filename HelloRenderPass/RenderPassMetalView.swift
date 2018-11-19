
import MetalKit

public class RenderPassMetalView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        
        if let device = device {
            renderer = RenderPassRenderer(view: self, device: device)
            delegate = renderer
        } else {
            fatalError("Error: Failure to create device")
        }

    }

}

