import MeemawQuizzCore
import SwiftUI

extension PlayerControllerView {
    // MARK: - 7B. 🎨 Draw Something & 📞 Esquissé ! Controller Sections

    var drawSomethingControllerSection: some View {
        VStack(spacing: 10) {
            if let drawRound = snap.activeDrawRound {
                let isDrawer = (drawRound.drawerPlayerID == session.localPlayerID)

                if snap.stage == .drawWordChoice {
                    if isDrawer {
                        PopArtCard(cornerRadius: 18, borderWidth: 2, backgroundColor: PopArt.white) {
                            VStack(spacing: 10) {
                                Text("🎨 C'EST À TOI DE DESSINER !")
                                    .font(.system(size: 17, weight: .black, design: .rounded))
                                    .foregroundStyle(PopArt.ink)

                                Text("Choisis ton mot selon la difficulté :")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(PopArt.ink.opacity(0.72))

                                ForEach(drawRound.wordOptions) { opt in
                                    Button {
                                        session.selectDrawWord(opt.word)
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(String(repeating: "⭐", count: opt.stars) + "  " + opt.word)
                                                    .font(.system(size: 17, weight: .black, design: .rounded))
                                                    .foregroundStyle(PopArt.ink)
                                                Text("Indice : \(opt.categoryHint)")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundStyle(PopArt.ink.opacity(0.7))
                                            }
                                            Spacer()
                                            Text("+\(opt.points) PTS")
                                                .font(.system(size: 13, weight: .black, design: .monospaced))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(PopArt.yellow, in: Capsule())
                                                .foregroundStyle(PopArt.ink)
                                        }
                                        .padding(12)
                                        .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(
                                        PopArtActionButtonStyle(
                                            backgroundColor: PopArt.cream,
                                            foregroundColor: PopArt.ink,
                                            cornerRadius: 14
                                        )
                                    )
                                }
                            }
                            .padding(14)
                        }
                    } else {
                        PopArtCard(cornerRadius: 18, borderWidth: 2, backgroundColor: PopArt.white) {
                            VStack(spacing: 8) {
                                Text("\(drawRound.drawerEmoji) \(drawRound.drawerPlayerName) choisit son mot...")
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundStyle(PopArt.ink)
                                    .multilineTextAlignment(.center)
                                Text("Prépare-toi à composer le mot avec les tuiles !")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(PopArt.ink.opacity(0.75))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(18)
                        }
                    }
                } else if snap.stage == .drawLiveGuessing {
                    if isDrawer {
                        VStack(spacing: 10) {
                            // 1. Stitch Sun Yellow Secret Word Banner with 1-tap 🔄 CHANGER button
                            StitchSecretPromptBanner(
                                label: "MOT SECRET À FAIRE DEVINER :",
                                promptText: drawRound.chosenWord?.word ?? "",
                                canSwap: drawRound.foundPlayerIDs.isEmpty,
                                onSwap: {
                                    session.swapSecretPrompt()
                                }
                            )

                            // 2. Stitch Studio Easel + Stickers 1-Clic + Nuancier Pop
                            InteractiveDrawingPadView(
                                initialCanvas: drawRound.canvas,
                                onCanvasChanged: { updatedCanvas in
                                    session.sendDrawingCanvasUpdate(updatedCanvas)
                                }
                            )

                            if !drawRound.foundPlayerIDs.isEmpty {
                                PopArtCard(cornerRadius: 16, borderWidth: 3, backgroundColor: PopArt.greenSuccess) {
                                    HStack {
                                        Text("🎉 \(drawRound.foundPlayerIDs.count) joueur(s) ont déjà trouvé ton dessin !")
                                            .font(.system(size: 13, weight: .black, design: .rounded))
                                            .foregroundStyle(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                    } else {
                        let alreadyFound = drawRound.foundPlayerIDs.contains(session.localPlayerID)
                        VStack(spacing: 10) {
                            // Stitch Studio Easel Preview for Guessers
                            PopArtCard(cornerRadius: 22, borderWidth: 3.5, backgroundColor: PopArt.cream) {
                                VStack(spacing: 8) {
                                    HStack {
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(PopArt.redError)
                                                .frame(width: 9, height: 9)
                                            Text("\(drawRound.drawerEmoji) \(drawRound.drawerPlayerName.uppercased()) EN DIRECT")
                                                .font(.system(size: 12, weight: .black, design: .rounded))
                                                .foregroundStyle(PopArt.ink)
                                        }
                                        Spacer()
                                        Text("+\(drawRound.chosenWord?.points ?? 2000) PTS")
                                            .font(.system(size: 12, weight: .black, design: .monospaced))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(PopArt.pink, in: Capsule())
                                            .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                                    }

                                    ZStack {
                                        Color.white
                                        CanvasDotGridView()
                                        VectorCanvasPreviewView(canvas: drawRound.canvas)
                                    }
                                    .aspectRatio(CGFloat(DrawingCanvasData.portraitAspectRatio), contentMode: .fit)
                                    .frame(maxHeight: 265)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(PopArt.ink, lineWidth: 3))
                                }
                                .padding(10)
                            }

                            if alreadyFound {
                                PopArtCard(cornerRadius: 20, borderWidth: 4, backgroundColor: PopArt.greenSuccess) {
                                    VStack(spacing: 6) {
                                        Text("🎉 BRAVO ! TU AS TROUVÉ LE MOT !")
                                            .font(.system(size: 20, weight: .black, design: .rounded))
                                            .foregroundStyle(.white)
                                        Text("« \(drawRound.chosenWord?.word ?? "") » (+\(me?.lastDeltaScore ?? 2000) PTS)")
                                            .font(.system(size: 18, weight: .black, design: .monospaced))
                                            .foregroundStyle(PopArt.yellow)
                                    }
                                    .padding(18)
                                }
                            } else {
                                DrawSomethingTileRackView(
                                    targetLength: max(1, drawRound.wordLength),
                                    targetWord: drawRound.chosenWord?.word ?? "",
                                    categoryHint: drawRound.chosenWord?.categoryHint ?? "Mystère",
                                    scrambledTiles: drawRound.scrambledTiles,
                                    hintsUsedCount: me?.drawHintsUsedCount ?? 0,
                                    onRequestHint: {
                                        session.requestDrawHint()
                                    },
                                    onGuessSubmitted: { guess in
                                        session.submitDrawGuessWord(guess)
                                    }
                                )
                            }
                        }
                    }
                } else {
                    // .drawReveal
                    let delta = me?.lastDeltaScore ?? 0
                    PopArtCard(
                        cornerRadius: 22,
                        borderWidth: 4,
                        backgroundColor: delta > 0 ? PopArt.greenSuccess : PopArt.white
                    ) {
                        VStack(spacing: 10) {
                            Text("🎨 LE MOT ÉTAIT : « \(drawRound.chosenWord?.word ?? "") »")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(delta > 0 ? .white : PopArt.ink)

                            ZStack {
                                Color.white
                                CanvasDotGridView()
                                VectorCanvasPreviewView(canvas: drawRound.canvas)
                            }
                            .aspectRatio(CGFloat(DrawingCanvasData.portraitAspectRatio), contentMode: .fit)
                            .frame(maxHeight: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.ink, lineWidth: 2.5))

                            if delta > 0 {
                                Text("🎉 +\(delta) PTS GAGNÉS SUR CE DESSIN !")
                                    .font(.system(size: 18, weight: .black, design: .monospaced))
                                    .foregroundStyle(PopArt.yellow)
                            } else if delta < 0 {
                                Text("💡 \(delta) PTS (indices utilisés)")
                                    .font(.system(size: 15, weight: .black, design: .monospaced))
                                    .foregroundStyle(PopArt.redError)
                            } else {
                                Text("0 pt sur ce dessin — prépare-toi pour la suite !")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(PopArt.ink.opacity(0.75))
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
    }

    var esquisseControllerSection: some View {
        VStack(spacing: 12) {
            if let esq = snap.activeEsquisseRound {
                if snap.stage == .esquisseShowcase {
                    let nbIndex = min(max(0, esq.showcaseNotebookIndex), max(0, esq.notebooks.count - 1))
                    if esq.notebooks.indices.contains(nbIndex) {
                        let notebook = esq.notebooks[nbIndex]
                        let alreadyVoted = notebook.voteVoterIDs.contains(session.localPlayerID)
                        PopArtCard(cornerRadius: 22, borderWidth: 4, backgroundColor: PopArt.cream) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("📖 ALBUM BD DE \(notebook.ownerEmoji) \(notebook.ownerName.uppercased())")
                                        .font(.system(size: 15, weight: .black, design: .rounded))
                                        .foregroundStyle(PopArt.ink)
                                    Spacer()
                                    Text("CARNET \(nbIndex + 1)/\(esq.notebooks.count)")
                                        .font(.system(size: 12, weight: .black, design: .monospaced))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(PopArt.yellow, in: Capsule())
                                        .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                                }

                                ForEach(Array(notebook.entries.enumerated()), id: \.element.id) { idx, entry in
                                    let stepBadge = idx == 0 ? "1. MOT SECRET" : (idx == 1 ? "2. 1er DESSIN" : (idx == 2 ? "3. DEVIENT..." : "4. CHUTE FINALE !"))
                                    let headerColor = idx == 0 ? PopArt.yellow : (idx == 1 ? Color(hex: "#F3E8FF") : (idx == 2 ? Color(hex: "#FFE4E8") : Color(hex: "#D1FAE5")))
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack {
                                            Text(stepBadge)
                                                .font(.system(size: 11, weight: .black, design: .rounded))
                                                .foregroundStyle(PopArt.ink)
                                            Spacer()
                                            Text("Par \(entry.authorEmoji) \(entry.authorName)")
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundStyle(PopArt.ink.opacity(0.75))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(headerColor)

                                        Divider().overlay(PopArt.ink)

                                        if let text = entry.promptText {
                                            Text("« \(text) »")
                                                .font(.system(size: 18, weight: .black, design: .rounded))
                                                .foregroundStyle(PopArt.ink)
                                                .padding(12)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .background(Color.white)
                                        }
                                        if let drawing = entry.drawing {
                                            ZStack {
                                                Color.white
                                                CanvasDotGridView()
                                                VectorCanvasPreviewView(canvas: drawing)
                                            }
                                            .aspectRatio(CGFloat(DrawingCanvasData.portraitAspectRatio), contentMode: .fit)
                                            .frame(maxHeight: 220)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.white)
                                        }
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.ink, lineWidth: 2.5))
                                }

                                Button {
                                    session.voteEsquisseAlbum(notebook.id)
                                } label: {
                                    HStack {
                                        Text(alreadyVoted ? "❤️ COUP DE CŒUR ENVOYÉ (\(notebook.voteVoterIDs.count) ❤️)" : "❤️ VOTER COUP DE CŒUR (+1 000 PTS)")
                                            .font(.system(size: 15, weight: .black, design: .rounded))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                }
                                .buttonStyle(
                                    PopArtActionButtonStyle(
                                        backgroundColor: alreadyVoted ? PopArt.greenSuccess : PopArt.pink,
                                        foregroundColor: .white,
                                        cornerRadius: 16
                                    )
                                )
                                .disabled(alreadyVoted)
                            }
                            .padding(16)
                        }
                    }
                } else if me?.hasSubmittedEsquisseStep == true {
                    PopArtCard(cornerRadius: 22, borderWidth: 4, backgroundColor: PopArt.greenSuccess) {
                        VStack(spacing: 10) {
                            Text("✅ CARNET TRANSMIS AU VOISIN !")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Attends quelques secondes que les autres artistes terminent leur étape...")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        .padding(22)
                    }
                } else {
                    let assignedID = esq.activeAssignmentByPlayerID[session.localPlayerID]
                    let assignedNotebook = esq.notebooks.first(where: { $0.id == assignedID }) ?? esq.notebooks.first
                    let originalPrompt = assignedNotebook?.entries.first?.promptText ?? ""
                    EsquisseInteractiveStepCard(
                        stage: snap.stage,
                        stepIndex: esq.stepIndex,
                        previousEntry: assignedNotebook?.entries.last,
                        notebookFirstPrompt: originalPrompt,
                        onSwapPrompt: {
                            session.swapSecretPrompt()
                        },
                        onSubmitText: { text in
                            session.submitEsquisseText(text)
                        },
                        onSubmitDrawing: { canvas in
                            session.submitEsquisseDrawing(canvas)
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Reusable Vector Canvas & Draw Something / Esquissé Subviews (Stitch Neo-Brutalist Studio UI)

struct CanvasDotGridView: View {
    var spacing: CGFloat = 18
    var dotRadius: CGFloat = 1.25

    var body: some View {
        Canvas { context, size in
            let dotColor = Color(hex: "#CBD5E1")
            var y: CGFloat = spacing / 2
            while y < size.height {
                var x: CGFloat = spacing / 2
                while x < size.width {
                    let rect = CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(dotColor))
                    x += spacing
                }
                y += spacing
            }
        }
        .allowsHitTesting(false)
    }
}

struct StitchSecretPromptBanner: View {
    let label: String
    let promptText: String
    var canSwap: Bool = true
    var onSwap: () -> Void

    var body: some View {
        PopArtCard(cornerRadius: 16, borderWidth: 3, backgroundColor: PopArt.yellow, shadowOffset: 3) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.ink.opacity(0.75))
                    Text("« \(promptText.uppercased()) »")
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                Spacer(minLength: 4)
                if canSwap {
                    Button {
                        onSwap()
                    } label: {
                        HStack(spacing: 4) {
                            Text("🔄")
                                .font(.system(size: 14))
                            Text("AUTRE MOT")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                    }
                    .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.white, cornerRadius: 12))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

struct VectorCanvasPreviewView: View {
    let canvas: DrawingCanvasData

    var body: some View {
        Canvas { context, size in
            // Proportional stroke scaling so phone, tablet, and Apple TV 16:9 have the EXACT same line thickness!
            let strokeScale = max(0.1, size.width / CGFloat(DrawingCanvasData.referenceWidth))
            for stroke in canvas.strokes {
                guard let first = stroke.points.first else { continue }
                let scaledLineWidth = CGFloat(stroke.lineWidth) * strokeScale
                var path = Path()
                path.move(to: CGPoint(x: first.x * size.width, y: first.y * size.height))
                if stroke.points.count == 1 {
                    path.addEllipse(in: CGRect(
                        x: first.x * size.width - scaledLineWidth / 2,
                        y: first.y * size.height - scaledLineWidth / 2,
                        width: scaledLineWidth,
                        height: scaledLineWidth
                    ))
                    context.fill(path, with: .color(Color(hex: stroke.colorHex)))
                } else {
                    for pt in stroke.points.dropFirst() {
                        path.addLine(to: CGPoint(x: pt.x * size.width, y: pt.y * size.height))
                    }
                    context.stroke(
                        path,
                        with: .color(Color(hex: stroke.colorHex)),
                        style: StrokeStyle(lineWidth: scaledLineWidth, lineCap: .round, lineJoin: .round)
                    )
                }
            }
        }
    }
}

struct InteractiveDrawingPadView: View {
    let initialCanvas: DrawingCanvasData
    var onCanvasChanged: (DrawingCanvasData) -> Void

    @State private var strokes: [DrawingStroke] = []
    @State private var redoGroups: [[DrawingStroke]] = []
    @State private var activePoints: [NormalizedPoint] = []
    @State private var selectedColorHex: String = "#111827"
    @State private var selectedLineWidth: Double = 7.5
    @State private var lastSentAt: Date = .distantPast

    private let palette: [String] = [
        "#111827", "#E11D48", "#FF8C42", "#F59E0B", "#10B981", "#2563EB", "#8E44AD"
    ]

    private let brushSizes: [(label: String, width: Double, dotSize: CGFloat)] = [
        ("Fin", 4.0, 6),
        ("Moyen", 7.5, 11),
        ("Épais", 13.0, 16)
    ]

    private var previewStrokes: [DrawingStroke] {
        guard !activePoints.isEmpty else { return strokes }
        return strokes + [DrawingStroke(colorHex: selectedColorHex, lineWidth: selectedLineWidth, points: activePoints)]
    }

    private func performUndo() {
        guard let popped = strokes.popLast() else { return }
        redoGroups.append([popped])
        onCanvasChanged(DrawingCanvasData(strokes: strokes))
    }

    private func performRedo() {
        guard let restored = redoGroups.popLast() else { return }
        strokes.append(contentsOf: restored)
        onCanvasChanged(DrawingCanvasData(strokes: strokes))
    }

    var body: some View {
        // Unified Single-Screen Studio Easel (Colors on Top + Tools + Portrait 3:4 Canvas — ZERO scrolling needed!)
        PopArtCard(cornerRadius: 20, borderWidth: 3.5, backgroundColor: PopArt.cream, shadowOffset: 4) {
            VStack(spacing: 8) {
                // 1. TOP COLOR BAR (7 Couleurs Pop toujours accessibles tout en haut sans scroller !)
                HStack(spacing: 8) {
                    ForEach(palette, id: \.self) { hex in
                        let isSelected = (selectedColorHex == hex)
                        Button {
                            selectedColorHex = hex
                            if selectedLineWidth > 14.0 {
                                selectedLineWidth = 7.5
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 34, height: 34)
                                    .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: isSelected ? 3.5 : 2.2))
                                if isSelected {
                                    Text("✓")
                                        .font(.system(size: 15, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                            }
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
                .background(PopArt.white, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.ink, lineWidth: 2))

                // 2. COMPACT BRUSH SIZE + GOMME + UNDO / REDO / VIDER ROW
                HStack(spacing: 6) {
                    ForEach(brushSizes, id: \.label) { sizeOpt in
                        let isCurrentSize = abs(selectedLineWidth - sizeOpt.width) < 1.5 && selectedColorHex != "#FFFFFF"
                        Button {
                            if selectedColorHex == "#FFFFFF" {
                                selectedColorHex = "#111827"
                            }
                            selectedLineWidth = sizeOpt.width
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(isCurrentSize ? PopArt.yellow : PopArt.white)
                                    .frame(width: 28, height: 28)
                                    .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 2))
                                Circle()
                                    .fill(PopArt.ink)
                                    .frame(width: sizeOpt.dotSize, height: sizeOpt.dotSize)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    let isEraser = (selectedColorHex == "#FFFFFF")
                    Button {
                        if isEraser {
                            selectedColorHex = "#111827"
                            selectedLineWidth = 7.5
                        } else {
                            selectedColorHex = "#FFFFFF"
                            selectedLineWidth = 18.0
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Text("🧽")
                                .font(.system(size: 12))
                            Text("Gomme")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(isEraser ? .white : PopArt.ink)
                        }
                        .padding(.horizontal, 9)
                        .frame(height: 28)
                        .background(isEraser ? PopArt.blue : PopArt.white, in: Capsule())
                        .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 2)

                    Button {
                        performUndo()
                    } label: {
                        Text("↩️")
                            .font(.system(size: 13, weight: .black))
                            .frame(width: 32, height: 28)
                            .background(PopArt.white, in: RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(PopArt.ink, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                    .opacity(strokes.isEmpty ? 0.4 : 1.0)

                    Button {
                        performRedo()
                    } label: {
                        Text("↪️")
                            .font(.system(size: 13, weight: .black))
                            .frame(width: 32, height: 28)
                            .background(PopArt.white, in: RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(PopArt.ink, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                    .opacity(redoGroups.isEmpty ? 0.4 : 1.0)

                    Button {
                        strokes.removeAll()
                        redoGroups.removeAll()
                        activePoints.removeAll()
                        onCanvasChanged(DrawingCanvasData(strokes: []))
                    } label: {
                        Text("🗑️")
                            .font(.system(size: 13))
                            .frame(width: 32, height: 28)
                            .background(PopArt.pink, in: RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(PopArt.ink, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                }

                // 3. PORTRAIT 3:4 CANVAS (Clamped height so the Submit button & Colors NEVER go off-screen!)
                GeometryReader { geo in
                    ZStack {
                        Color.white
                        CanvasDotGridView()
                        VectorCanvasPreviewView(
                            canvas: DrawingCanvasData(strokes: previewStrokes)
                        )

                        if previewStrokes.isEmpty {
                            Text("👆 Dessine au doigt ici")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink.opacity(0.4))
                                .allowsHitTesting(false)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.ink, lineWidth: 3))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let w = max(1, geo.size.width)
                                let h = max(1, geo.size.height)
                                let nx = min(1.0, max(0.0, value.location.x / w))
                                let ny = min(1.0, max(0.0, value.location.y / h))
                                let pt = NormalizedPoint(x: nx, y: ny)

                                if let last = activePoints.last {
                                    let dist = hypot(pt.x - last.x, pt.y - last.y)
                                    if dist < 0.006 { return }
                                }
                                activePoints.append(pt)

                                if Date().timeIntervalSince(lastSentAt) > 0.12 {
                                    lastSentAt = Date()
                                    onCanvasChanged(DrawingCanvasData(strokes: previewStrokes))
                                }
                            }
                            .onEnded { _ in
                                guard !activePoints.isEmpty else { return }
                                let smoothed = DrawingBank.smoothPoints(activePoints)
                                strokes.append(DrawingStroke(colorHex: selectedColorHex, lineWidth: selectedLineWidth, points: smoothed))
                                redoGroups.removeAll()
                                activePoints.removeAll()
                                onCanvasChanged(DrawingCanvasData(strokes: strokes))
                            }
                    )
                }
                .aspectRatio(CGFloat(DrawingCanvasData.portraitAspectRatio), contentMode: .fit)
                .frame(maxHeight: 275)
                .frame(maxWidth: .infinity)
            }
            .padding(10)
        }
        .onAppear {
            if strokes.isEmpty && !initialCanvas.strokes.isEmpty {
                strokes = initialCanvas.strokes
            }
        }
        .onChange(of: initialCanvas) { _, newVal in
            if newVal.strokes.isEmpty && !strokes.isEmpty {
                strokes.removeAll()
                redoGroups.removeAll()
            }
        }
    }
}

struct DrawSomethingTileRackView: View {
    let targetLength: Int
    let targetWord: String
    let categoryHint: String
    let scrambledTiles: [String]
    let hintsUsedCount: Int
    var onRequestHint: () -> Void
    var onGuessSubmitted: (String) -> Void

    @State private var selectedTileIndices: [Int] = []
    @State private var wrongAttemptFlash: Bool = false

    private var maxHintsAllowed: Int {
        max(1, targetLength - 1)
    }

    private var currentWord: String {
        selectedTileIndices.compactMap { idx in
            scrambledTiles.indices.contains(idx) ? scrambledTiles[idx] : nil
        }.joined()
    }

    private func applyLockedHintLetters(count: Int) {
        let normalizedTargetChars = Array(DrawingBank.normalizeWord(targetWord))
        let clampedCount = min(count, normalizedTargetChars.count)
        guard clampedCount > 0 else { return }

        var chosenIndices: [Int] = []
        for pos in 0..<clampedCount {
            let targetChar = String(normalizedTargetChars[pos])
            if let tileIdx = scrambledTiles.enumerated().first(where: { idx, tile in
                !chosenIndices.contains(idx) && DrawingBank.normalizeWord(tile) == targetChar
            })?.offset {
                chosenIndices.append(tileIdx)
            }
        }
        selectedTileIndices = chosenIndices
    }

    var body: some View {
        PopArtCard(cornerRadius: 22, borderWidth: 3.5, backgroundColor: wrongAttemptFlash ? Color(hex: "#FEE2E2") : PopArt.yellow, shadowOffset: 4) {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Text("🔤 MOT SECRET (\(targetLength) LETTRES)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.ink)

                    Spacer()

                    if hintsUsedCount < maxHintsAllowed {
                        Button {
                            let nextCount = hintsUsedCount + 1
                            onRequestHint()
                            applyLockedHintLetters(count: nextCount)
                        } label: {
                            Text("💡 Indice (-300 pts)")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(PopArt.purple, in: Capsule())
                                .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                        }
                        .buttonStyle(.plain)
                    }

                    if selectedTileIndices.count > hintsUsedCount {
                        Button {
                            _ = selectedTileIndices.popLast()
                        } label: {
                            Text("⌫")
                                .font(.system(size: 13, weight: .black))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(PopArt.white, in: Capsule())
                                .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                        }
                        .buttonStyle(.plain)
                    }
                }

                if hintsUsedCount > 0 {
                    HStack(spacing: 6) {
                        Text("💡 Catégorie : \(categoryHint) • \(hintsUsedCount) lettre(s) révélée(s) (-\(hintsUsedCount * 300) pts)")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.purple)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(PopArt.ink, lineWidth: 2))
                }

                // 3D Word Answer Slots (Stitch style)
                HStack(spacing: 6) {
                    ForEach(0..<targetLength, id: \.self) { pos in
                        let isHintLocked = pos < hintsUsedCount
                        let letter: String = pos < selectedTileIndices.count
                            ? scrambledTiles[selectedTileIndices[pos]]
                            : "_"
                        let isEmptySlot = (pos >= selectedTileIndices.count)
                        Button {
                            if pos >= hintsUsedCount && pos < selectedTileIndices.count {
                                selectedTileIndices.remove(at: pos)
                            }
                        } label: {
                            Text(letter)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(isHintLocked ? .white : (isEmptySlot ? PopArt.ink.opacity(0.28) : PopArt.ink))
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(
                                    isHintLocked ? PopArt.purple : (isEmptySlot ? Color.white : PopArt.greenSuccess.opacity(0.35)),
                                    in: RoundedRectangle(cornerRadius: 11)
                                )
                                .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(PopArt.ink, lineWidth: 2.8))
                                .background(
                                    RoundedRectangle(cornerRadius: 11)
                                        .fill(PopArt.ink)
                                        .offset(x: 0, y: 3)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(isHintLocked)
                    }
                }

                // 12 Scrambled Letter Tiles (Draw Something 3D Pop style)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                    ForEach(Array(scrambledTiles.enumerated()), id: \.offset) { idx, letter in
                        let isUsed = selectedTileIndices.contains(idx)
                        Button {
                            guard !isUsed, selectedTileIndices.count < targetLength else { return }
                            selectedTileIndices.append(idx)
                            if selectedTileIndices.count == targetLength {
                                let attempt = currentWord
                                if DrawingBank.normalizeWord(attempt) == DrawingBank.normalizeWord(targetWord) {
                                    onGuessSubmitted(attempt)
                                } else {
                                    wrongAttemptFlash = true
                                    Task { @MainActor in
                                        try? await Task.sleep(for: .milliseconds(450))
                                        wrongAttemptFlash = false
                                        applyLockedHintLetters(count: hintsUsedCount)
                                        if hintsUsedCount == 0 {
                                            selectedTileIndices.removeAll()
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text(letter)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(isUsed ? PopArt.ink.opacity(0.22) : .white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(isUsed ? PopArt.cream : PopArt.blue, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(PopArt.ink, lineWidth: 2.5))
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(PopArt.ink)
                                        .offset(x: 0, y: isUsed ? 0 : 3)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(isUsed)
                    }
                }
            }
            .padding(14)
        }
        .onChange(of: targetWord) { _, _ in
            selectedTileIndices.removeAll()
        }
        .onChange(of: hintsUsedCount) { _, newCount in
            if newCount > 0 && selectedTileIndices.count < newCount {
                applyLockedHintLetters(count: newCount)
            }
        }
    }
}

struct EsquisseInteractiveStepCard: View {
    let stage: ShowStageState
    let stepIndex: Int
    let previousEntry: EsquisseEntry?
    var notebookFirstPrompt: String = ""
    var onSwapPrompt: () -> Void = {}
    var onSubmitText: (String) -> Void
    var onSubmitDrawing: (DrawingCanvasData) -> Void

    @State private var typedText: String = ""
    @State private var currentCanvas = DrawingCanvasData()
    @State private var starterIdeas: [String] = DrawingBank.pickThreeEsquissePrompts()
    @State private var quickGuesses: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if stage == .esquissePromptEntry {
                PopArtCard(cornerRadius: 22, borderWidth: 4, backgroundColor: PopArt.white) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("✍️ CHOISIS 1 SEUL MOT FACILE !")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.orange)
                            Spacer()
                            Button {
                                starterIdeas = DrawingBank.pickThreeEsquissePrompts(excluding: Set(starterIdeas))
                            } label: {
                                Text("🔄 Autres mots")
                                    .font(.system(size: 12, weight: .black, design: .rounded))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(PopArt.yellow, in: Capsule())
                                    .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                            }
                            .buttonStyle(.plain)
                        }

                        ForEach(starterIdeas, id: \.self) { idea in
                            Button {
                                onSubmitText(idea)
                            } label: {
                                HStack {
                                    Text("🎨 \(idea)")
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                        .foregroundStyle(PopArt.ink)
                                    Spacer()
                                    Text("Choisir ➡️")
                                        .font(.system(size: 12, weight: .black))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(PopArt.greenSuccess, in: Capsule())
                                        .foregroundStyle(.white)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.cream, cornerRadius: 14))
                        }
                    }
                    .padding(16)
                }
            } else if stage == .esquisseDrawing {
                // 1. Yellow Secret Prompt Banner with 🔄 CHANGER button (Stitch design — 1 single easy word!)
                let displayStep = (stepIndex <= 1) ? "MANCHE 1/3" : "MANCHE 3/3"
                StitchSecretPromptBanner(
                    label: "📞 ESQUISSÉ (\(displayStep)) • 1 MOT FACILE À DESSINER :",
                    promptText: previousEntry?.promptText ?? "SOLEIL",
                    canSwap: true,
                    onSwap: {
                        onSwapPrompt()
                    }
                )

                // 2. Stitch Studio Easel + 1-Tap Stickers + Nuancier Pop
                InteractiveDrawingPadView(
                    initialCanvas: currentCanvas,
                    onCanvasChanged: { updated in
                        currentCanvas = updated
                    }
                )

                // 3. Big Emerald Submit Button (Compact height so everything fits on 1 screen without scrolling!)
                Button {
                    onSubmitDrawing(currentCanvas)
                } label: {
                    HStack(spacing: 8) {
                        Text("🚀 ENVOYER MON DESSIN AU VOISIN !")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.greenSuccess, foregroundColor: .white, cornerRadius: 16))
            } else {
                // .esquisseGuessing — Studio Easel Preview + 4 Big 1-Tap Single-Word Pop-Art QCM Buttons + Optional 1-Word Text!
                PopArtCard(cornerRadius: 22, borderWidth: 3.5, backgroundColor: PopArt.cream, shadowOffset: 5) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("🕵️ MANCHE 2/3 : QUEL MOT A DESSINÉ TON VOISIN ?")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.pink)
                            Spacer()
                        }

                        if let drawing = previousEntry?.drawing {
                            ZStack {
                                Color.white
                                CanvasDotGridView()
                                VectorCanvasPreviewView(canvas: drawing)
                            }
                            .aspectRatio(CGFloat(DrawingCanvasData.portraitAspectRatio), contentMode: .fit)
                            .frame(maxHeight: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(PopArt.ink, lineWidth: 3))
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(12)
                }

                PopArtCard(cornerRadius: 20, borderWidth: 3.5, backgroundColor: PopArt.white, shadowOffset: 4) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("⚡ TOUCHE 1 MOT EN UN CLIC :")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.purple)

                        let letters = ["A", "B", "C", "D"]
                        ForEach(Array(quickGuesses.enumerated()), id: \.offset) { idx, suggestion in
                            Button {
                                onSubmitText(suggestion)
                            } label: {
                                HStack(spacing: 10) {
                                    Text(letters[idx % letters.count])
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundStyle(PopArt.ink)
                                        .frame(width: 32, height: 32)
                                        .background(PopArt.yellow, in: RoundedRectangle(cornerRadius: 9))
                                        .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(PopArt.ink, lineWidth: 2))

                                    Text(suggestion)
                                        .font(.system(size: 17, weight: .black, design: .rounded))
                                        .foregroundStyle(PopArt.ink)
                                        .multilineTextAlignment(.leading)

                                    Spacer()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.cream, cornerRadius: 14))
                        }

                        Divider()

                        Text("✍️ Ou écris 1 mot au clavier :")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink.opacity(0.65))

                        HStack(spacing: 8) {
                            TextField("Ex: SOLEIL, PIZZA, POISSON...", text: $typedText)
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .padding(10)
                                .background(PopArt.cream, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(PopArt.ink, lineWidth: 2))
                                .onSubmit {
                                    if !typedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        onSubmitText(typedText)
                                    }
                                }

                            Button {
                                onSubmitText(typedText)
                            } label: {
                                Text("✅")
                                    .font(.system(size: 18, weight: .black))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.greenSuccess, foregroundColor: .white, cornerRadius: 12))
                        }
                    }
                    .padding(14)
                }
            }
        }
        .onAppear {
            quickGuesses = DrawingBank.quickGuessSuggestions(from: notebookFirstPrompt)
        }
        .onChange(of: stepIndex) { _, _ in
            typedText = ""
            currentCanvas = DrawingCanvasData()
            starterIdeas = DrawingBank.pickThreeEsquissePrompts()
            quickGuesses = DrawingBank.quickGuessSuggestions(from: notebookFirstPrompt)
        }
    }
}
