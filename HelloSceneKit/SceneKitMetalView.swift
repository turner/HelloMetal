
import MetalKit

public class SceneKitMetalView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        if let device = device {
            renderer = SceneKitRenderer(view: self, device: device)
            delegate = renderer
        } else {
            fatalError("Error: Failure to create device")
        }

    }

}

