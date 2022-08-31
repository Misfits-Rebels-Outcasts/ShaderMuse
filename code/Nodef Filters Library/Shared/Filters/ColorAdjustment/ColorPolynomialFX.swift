//
//  Copyright © 2022 James Boo. All rights reserved.
//

import SwiftUI


class ColorPolynomialFX: FilterX {
       /*
    @Published var rx:Float = 1.0
    @Published var ry:Float = 0.0
    @Published var rz:Float = 0.0
    @Published var rw:Float = 0.0

    @Published var gx:Float = 0.0
    @Published var gy:Float = 1.0
    @Published var gz:Float = 0.0
    @Published var gw:Float = 0.0

    @Published var bx:Float = 0.0
    @Published var by:Float = 0.0
    @Published var bz:Float = 1.0
    @Published var bw:Float = 0.0

    @Published var ax:Float = 0.0
    @Published var ay:Float = 0.0
    @Published var az:Float = 0.0
    @Published var aw:Float = 1.0
        */

    @Published var rx:Float = 0.0
    @Published var ry:Float = 1.0
    @Published var rz:Float = 0.0
    @Published var rw:Float = 0.0

    @Published var gx:Float = 0.0
    @Published var gy:Float = 1.0
    @Published var gz:Float = 0.0
    @Published var gw:Float = 0.0

    @Published var bx:Float = 0.0
    @Published var by:Float = 1.0
    @Published var bz:Float = 0.0
    @Published var bw:Float = 0.0

    @Published var ax:Float = 0.0
    @Published var ay:Float = 1.0
    @Published var az:Float = 0.0
    @Published var aw:Float = 0.0

    let description = "Modifies the pixel values in an image by applying a set of cubic polynomials.The coefficients for each channel is required."

    override init()
    {
        let name = "CIColorPolynomial"
        super.init(name)
        desc=description
      
        print(CIFilter.localizedName(forFilterName: name))
        print(CIFilter.localizedDescription(forFilterName: name))
        print(CIFilter.localizedReferenceDocumentation(forFilterName: name))
                    
         
    }

    enum CodingKeys : String, CodingKey {
        case rx
        case ry
        case rz
        case rw
        
        case gx
        case gy
        case gz
        case gw

        case bx
        case by
        case bz
        case bw

        case ax
        case ay
        case az
        case aw



        

    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        desc=description
        rx = try values.decodeIfPresent(Float.self, forKey: .rx) ?? 0.0
        ry = try values.decodeIfPresent(Float.self, forKey: .ry) ?? 0.0
        rz = try values.decodeIfPresent(Float.self, forKey: .rz) ?? 0.0
        rw = try values.decodeIfPresent(Float.self, forKey: .rw) ?? 0.0

        gx = try values.decodeIfPresent(Float.self, forKey: .gx) ?? 0.0
        gy = try values.decodeIfPresent(Float.self, forKey: .gy) ?? 0.0
        gz = try values.decodeIfPresent(Float.self, forKey: .gz) ?? 0.0
        gw = try values.decodeIfPresent(Float.self, forKey: .gw) ?? 0.0

        bx = try values.decodeIfPresent(Float.self, forKey: .bx) ?? 0.0
        by = try values.decodeIfPresent(Float.self, forKey: .by) ?? 0.0
        bz = try values.decodeIfPresent(Float.self, forKey: .bz) ?? 0.0
        bw = try values.decodeIfPresent(Float.self, forKey: .bw) ?? 0.0

        ax = try values.decodeIfPresent(Float.self, forKey: .ax) ?? 0.0
        ay = try values.decodeIfPresent(Float.self, forKey: .ay) ?? 0.0
        az = try values.decodeIfPresent(Float.self, forKey: .az) ?? 0.0
        aw = try values.decodeIfPresent(Float.self, forKey: .aw) ?? 0.0

     
        
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rx, forKey: .rx)
        try container.encode(ry, forKey: .ry)
        try container.encode(rz, forKey: .rz)
        try container.encode(rw, forKey: .rw)

        try container.encode(gx, forKey: .gx)
        try container.encode(gy, forKey: .gy)
        try container.encode(gz, forKey: .gz)
        try container.encode(gw, forKey: .gw)

        try container.encode(bx, forKey: .bx)
        try container.encode(by, forKey: .by)
        try container.encode(bz, forKey: .bz)
        try container.encode(bw, forKey: .bw)

        try container.encode(ax, forKey: .ax)
        try container.encode(ay, forKey: .ay)
        try container.encode(az, forKey: .az)
        try container.encode(aw, forKey: .aw)


    }
    
    override func getCIFilter(_ ciImage: CIImage)->CIFilter
    {
        var currentCIFilter: CIFilter
        if ciFilter != nil {
            currentCIFilter = ciFilter!
        } else {
            currentCIFilter = CIFilter(name: type)!
            ciFilter=currentCIFilter
        }
        currentCIFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        let rvector=CIVector(x:CGFloat(rx),y:CGFloat(ry),z:CGFloat(rz),w:CGFloat(rw))
        currentCIFilter.setValue(rvector, forKey: "inputRedCoefficients")

        let gvector=CIVector(x:CGFloat(gx),y:CGFloat(gy),z:CGFloat(gz),w:CGFloat(gw))
        currentCIFilter.setValue(gvector, forKey: "inputGreenCoefficients")

        let bvector=CIVector(x:CGFloat(bx),y:CGFloat(by),z:CGFloat(bz),w:CGFloat(bw))
        currentCIFilter.setValue(bvector, forKey: "inputBlueCoefficients")

        let avector=CIVector(x:CGFloat(ax),y:CGFloat(ay),z:CGFloat(az),w:CGFloat(aw))
        currentCIFilter.setValue(avector, forKey: "inputAlphaCoefficients")

        return currentCIFilter
    }

}
