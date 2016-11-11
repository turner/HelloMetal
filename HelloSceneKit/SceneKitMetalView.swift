
import MetalKit

public class SceneKitMetalView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        renderer = SceneKitRenderer(view: self, device: device!)
        delegate = renderer
    }

}

