import AppKit

enum ImageEditLauncher {
    /// Hands a captured image (a full-screen capture, or a pinned image being
    /// re-edited) off to the editor in image-edit mode.
    static func launch(
        generatedImage image: NSImage,
        source: OverlayWindowController.PresetSource,
        keepsEditorAcrossSpaces: Bool = false,
        onRequestFocusReturn: (() -> Void)? = nil,
        onSuspend: ((OverlayWindowController.SuspendedEditDraft) -> Void)? = nil,
        onComplete: @escaping (NSImage?) -> Void
    ) -> OverlayWindowController? {
        guard image.size.width > 0, image.size.height > 0 else { return nil }

        let controller = OverlayWindowController(
            presetImage: image,
            presetSource: source,
            keepsEditorAcrossSpaces: keepsEditorAcrossSpaces,
            onRequestFocusReturn: onRequestFocusReturn,
            onSuspend: onSuspend,
            onComplete: onComplete
        )
        controller.activate()
        return controller
    }
}
