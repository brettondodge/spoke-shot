// Draws the Spoke Shot app icons as PNGs.
// Usage: swift make-icons.swift <output-folder>
import Foundation
import CoreGraphics
import ImageIO

func color(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: a)
}

// orbit = how far the spoke beads sit from the centre, as a share of the icon size
func render(size: Int, orbit: CGFloat, to path: String) {
    let s = CGFloat(size)
    let space = CGColorSpace(name: CGColorSpace.sRGB)!
    guard let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                              space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        fatalError("could not make a drawing context")
    }
    ctx.translateBy(x: 0, y: s)
    ctx.scaleBy(x: 1, y: -1) // y runs downward, like the game's canvas

    let sky = CGGradient(colorsSpace: space, colors: [color(0xF1F8FC), color(0xCFE8F3)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sky, start: .zero, end: CGPoint(x: 0, y: s), options: [])

    let cx = s / 2, cy = s / 2
    let O = s * orbit, R = O * 0.42, br = O * 0.115
    let angles: [CGFloat] = [-90, -38, 14, 62, 128, 176, 226] // degrees; the gap at the bottom is where the next spoke lands

    ctx.setLineCap(.round)
    ctx.setStrokeColor(color(0x1F2D4D))
    ctx.setLineWidth(max(1.5, O * 0.045))
    for a in angles {
        let t = a * .pi / 180
        ctx.move(to: CGPoint(x: cx + cos(t) * R * 0.8, y: cy + sin(t) * R * 0.8))
        ctx.addLine(to: CGPoint(x: cx + cos(t) * O, y: cy + sin(t) * O))
    }
    ctx.strokePath()

    ctx.setFillColor(color(0x1F2D4D))
    for a in angles {
        let t = a * .pi / 180
        ctx.fillEllipse(in: CGRect(x: cx + cos(t) * O - br, y: cy + sin(t) * O - br, width: br * 2, height: br * 2))
    }

    // hub with its progress ring
    ctx.setFillColor(color(0xE8453C))
    ctx.fillEllipse(in: CGRect(x: cx - R, y: cy - R, width: R * 2, height: R * 2))
    ctx.setLineWidth(R * 0.15)
    ctx.setStrokeColor(color(0xFFF4D2, 0.3))
    ctx.addArc(center: CGPoint(x: cx, y: cy), radius: R * 0.7, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.strokePath()
    ctx.setStrokeColor(color(0xFFF4D2))
    ctx.addArc(center: CGPoint(x: cx, y: cy), radius: R * 0.7, startAngle: -.pi / 2, endAngle: .pi, clockwise: false)
    ctx.strokePath()

    // the next spoke, flying up toward the gap
    let fy = cy + O + br * 1.9
    if fy + br * 2.4 < s * 0.97 {
        ctx.setStrokeColor(color(0x1F2D4D, 0.3))
        ctx.setLineWidth(max(1.5, O * 0.045))
        ctx.move(to: CGPoint(x: cx, y: fy + br * 1.15))
        ctx.addLine(to: CGPoint(x: cx, y: fy + br * 2.4))
        ctx.strokePath()
        ctx.setFillColor(color(0x1F2D4D))
        ctx.fillEllipse(in: CGRect(x: cx - br, y: fy - br, width: br * 2, height: br * 2))
    }

    guard let image = ctx.makeImage(),
          let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, "public.png" as CFString, 1, nil) else {
        fatalError("could not prepare \(path)")
    }
    CGImageDestinationAddImage(dest, image, nil)
    if !CGImageDestinationFinalize(dest) { fatalError("could not write \(path)") }
    print("wrote \(path)")
}

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
render(size: 512, orbit: 0.30, to: "\(out)/icon-512.png")
render(size: 192, orbit: 0.30, to: "\(out)/icon-192.png")
render(size: 180, orbit: 0.30, to: "\(out)/apple-touch-icon.png")
render(size: 512, orbit: 0.22, to: "\(out)/maskable-512.png") // extra margin so Android can crop it to a circle
render(size: 64, orbit: 0.36, to: "\(out)/favicon-64.png")
