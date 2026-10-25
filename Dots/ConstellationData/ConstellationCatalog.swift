import Foundation

/// A small, curated local catalog of real constellations.
///
/// Attribution & accuracy note: anchor positions are manually curated, normalized
/// approximations of each constellation's primary asterism stars, laid out to match
/// their well-known relative shape as depicted on standard sky atlases (e.g. IAU
/// constellation outlines / common planetarium star-chart renderings). They are not
/// sourced from a live astronomical catalog (no network access at build time), and are
/// not claimed to be arc-second-precise — only shape-accurate enough that each template
/// is recognizable and distinct. Per the product guardrails, the catalog ships with only
/// these five verified-shape templates rather than inventing additional ones.
enum ConstellationCatalog {
    static let templates: [ConstellationTemplate] = [orion, cassiopeia, lyra, cygnus, ursaMajor]

    static func template(withID id: String) -> ConstellationTemplate? {
        templates.first { $0.id == id }
    }

    static let orion = ConstellationTemplate(
        id: "orion",
        westernName: "Orion",
        koreanName: "오리온자리",
        anchors: [
            ConstellationStarAnchor(id: "betelgeuse", starName: "Betelgeuse", x: 0.30, y: 0.15, prominence: 1),
            ConstellationStarAnchor(id: "rigel", starName: "Rigel", x: 0.33, y: 0.88, prominence: 2),
            ConstellationStarAnchor(id: "bellatrix", starName: "Bellatrix", x: 0.68, y: 0.18, prominence: 3),
            ConstellationStarAnchor(id: "saiph", starName: "Saiph", x: 0.62, y: 0.85, prominence: 4),
            ConstellationStarAnchor(id: "alnilam", starName: "Alnilam", x: 0.50, y: 0.50, prominence: 5),
            ConstellationStarAnchor(id: "mintaka", starName: "Mintaka", x: 0.42, y: 0.48, prominence: 6),
            ConstellationStarAnchor(id: "alnitak", starName: "Alnitak", x: 0.58, y: 0.52, prominence: 7)
        ],
        lines: [
            ConstellationLine(fromAnchorID: "betelgeuse", toAnchorID: "bellatrix"),
            ConstellationLine(fromAnchorID: "betelgeuse", toAnchorID: "alnilam"),
            ConstellationLine(fromAnchorID: "bellatrix", toAnchorID: "mintaka"),
            ConstellationLine(fromAnchorID: "mintaka", toAnchorID: "alnilam"),
            ConstellationLine(fromAnchorID: "alnilam", toAnchorID: "alnitak"),
            ConstellationLine(fromAnchorID: "mintaka", toAnchorID: "rigel"),
            ConstellationLine(fromAnchorID: "alnitak", toAnchorID: "saiph"),
            ConstellationLine(fromAnchorID: "rigel", toAnchorID: "saiph")
        ],
        attribution: "Orion / 오리온자리 — manually curated shape-accurate approximation of the belt-and-shoulders asterism."
    )

    static let cassiopeia = ConstellationTemplate(
        id: "cassiopeia",
        westernName: "Cassiopeia",
        koreanName: "카시오페이아자리",
        anchors: [
            ConstellationStarAnchor(id: "caph", starName: "Caph", x: 0.10, y: 0.55, prominence: 1),
            ConstellationStarAnchor(id: "shedar", starName: "Shedar", x: 0.30, y: 0.25, prominence: 2),
            ConstellationStarAnchor(id: "gammaCas", starName: "Tsih (γ Cas)", x: 0.50, y: 0.50, prominence: 3),
            ConstellationStarAnchor(id: "ruchbah", starName: "Ruchbah", x: 0.70, y: 0.20, prominence: 4),
            ConstellationStarAnchor(id: "segin", starName: "Segin", x: 0.90, y: 0.45, prominence: 5)
        ],
        lines: [
            ConstellationLine(fromAnchorID: "caph", toAnchorID: "shedar"),
            ConstellationLine(fromAnchorID: "shedar", toAnchorID: "gammaCas"),
            ConstellationLine(fromAnchorID: "gammaCas", toAnchorID: "ruchbah"),
            ConstellationLine(fromAnchorID: "ruchbah", toAnchorID: "segin")
        ],
        attribution: "Cassiopeia / 카시오페이아자리 — manually curated approximation of the W-shaped five-star asterism."
    )

    static let lyra = ConstellationTemplate(
        id: "lyra",
        westernName: "Lyra",
        koreanName: "거문고자리",
        anchors: [
            ConstellationStarAnchor(id: "vega", starName: "Vega", x: 0.50, y: 0.10, prominence: 1),
            ConstellationStarAnchor(id: "sheliak", starName: "Sheliak", x: 0.40, y: 0.75, prominence: 2),
            ConstellationStarAnchor(id: "sulafat", starName: "Sulafat", x: 0.68, y: 0.80, prominence: 3),
            ConstellationStarAnchor(id: "zetaLyr", starName: "ζ Lyrae", x: 0.45, y: 0.35, prominence: 4),
            ConstellationStarAnchor(id: "deltaLyr", starName: "δ Lyrae", x: 0.70, y: 0.40, prominence: 5)
        ],
        lines: [
            ConstellationLine(fromAnchorID: "vega", toAnchorID: "zetaLyr"),
            ConstellationLine(fromAnchorID: "zetaLyr", toAnchorID: "deltaLyr"),
            ConstellationLine(fromAnchorID: "zetaLyr", toAnchorID: "sheliak"),
            ConstellationLine(fromAnchorID: "deltaLyr", toAnchorID: "sulafat"),
            ConstellationLine(fromAnchorID: "sheliak", toAnchorID: "sulafat")
        ],
        attribution: "Lyra / 거문고자리 — manually curated approximation of the Vega-anchored parallelogram asterism."
    )

    static let cygnus = ConstellationTemplate(
        id: "cygnus",
        westernName: "Cygnus",
        koreanName: "백조자리",
        anchors: [
            ConstellationStarAnchor(id: "deneb", starName: "Deneb", x: 0.50, y: 0.08, prominence: 1),
            ConstellationStarAnchor(id: "albireo", starName: "Albireo", x: 0.50, y: 0.90, prominence: 2),
            ConstellationStarAnchor(id: "sadr", starName: "Sadr", x: 0.50, y: 0.45, prominence: 3),
            ConstellationStarAnchor(id: "gienah", starName: "Gienah", x: 0.20, y: 0.40, prominence: 4),
            ConstellationStarAnchor(id: "deltaCyg", starName: "δ Cygni", x: 0.80, y: 0.42, prominence: 5)
        ],
        lines: [
            ConstellationLine(fromAnchorID: "deneb", toAnchorID: "sadr"),
            ConstellationLine(fromAnchorID: "sadr", toAnchorID: "albireo"),
            ConstellationLine(fromAnchorID: "sadr", toAnchorID: "gienah"),
            ConstellationLine(fromAnchorID: "sadr", toAnchorID: "deltaCyg")
        ],
        attribution: "Cygnus / 백조자리 — manually curated approximation of the Northern Cross asterism."
    )

    static let ursaMajor = ConstellationTemplate(
        id: "ursaMajor",
        westernName: "Ursa Major",
        koreanName: "큰곰자리",
        anchors: [
            ConstellationStarAnchor(id: "dubhe", starName: "Dubhe", x: 0.75, y: 0.15, prominence: 1),
            ConstellationStarAnchor(id: "alioth", starName: "Alioth", x: 0.35, y: 0.22, prominence: 2),
            ConstellationStarAnchor(id: "alkaid", starName: "Alkaid", x: 0.08, y: 0.12, prominence: 3),
            ConstellationStarAnchor(id: "merak", starName: "Merak", x: 0.72, y: 0.30, prominence: 4),
            ConstellationStarAnchor(id: "mizar", starName: "Mizar", x: 0.20, y: 0.18, prominence: 5),
            ConstellationStarAnchor(id: "phecda", starName: "Phecda", x: 0.55, y: 0.38, prominence: 6),
            ConstellationStarAnchor(id: "megrez", starName: "Megrez", x: 0.48, y: 0.25, prominence: 7)
        ],
        lines: [
            ConstellationLine(fromAnchorID: "dubhe", toAnchorID: "merak"),
            ConstellationLine(fromAnchorID: "merak", toAnchorID: "phecda"),
            ConstellationLine(fromAnchorID: "phecda", toAnchorID: "megrez"),
            ConstellationLine(fromAnchorID: "megrez", toAnchorID: "dubhe"),
            ConstellationLine(fromAnchorID: "megrez", toAnchorID: "alioth"),
            ConstellationLine(fromAnchorID: "alioth", toAnchorID: "mizar"),
            ConstellationLine(fromAnchorID: "mizar", toAnchorID: "alkaid")
        ],
        attribution: "Ursa Major / 큰곰자리 — manually curated approximation of the Big Dipper asterism (bowl + handle)."
    )
}
