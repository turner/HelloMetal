
import MetalKit

public class Model_IOMetalView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        if let device = device {
            renderer = Model_IORenderer(view: self, device: device)
            delegate = renderer
        } else {
            fatalError("Error: Failure to create device")
        }
    }

}

