
import MetalKit

public class OpenEXRView: EIView {

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        
        if let device = device {
            renderer = OpenEXRRenderer(view: self, device: device)
            delegate = renderer
        } else {
            fatalError("Error: Failure to create device")
        }

    }

}
