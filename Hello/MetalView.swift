
import MetalKit

public class MetalView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)

        if let device = device {
            renderer = Renderer(view: self, device: device)
            delegate = renderer
        } else {
            fatalError("Error: Failure to create device")
        }
    }

}
