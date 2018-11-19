
import MetalKit

public class CameraPlaneMetalView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        
        if let device = device {
            renderer = CameraPlaneRenderer(view: self, device: device)
            delegate = renderer
        } else {
            fatalError("Error: Failure to create device")
        }

    }

}

