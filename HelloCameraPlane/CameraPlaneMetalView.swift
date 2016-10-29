
import MetalKit

public class CameraPlaneMetalView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        renderer = CameraPlaneRenderer(view: self, device: device!)
        delegate = renderer
    }

}

