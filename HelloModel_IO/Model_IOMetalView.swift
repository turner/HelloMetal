
import MetalKit

public class Model_IOMetalView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        renderer = Model_IORenderer(view: self, device: device!)
        delegate = renderer
    }

}

