# PosterCard: Solid Background + White Overlay

Adjust design so the card background takes the Theme Color, and patterns are white overlays.

## Proposed Changes

### [MODIFY] `lib/features/events/presentation/widgets/poster_card.dart`
- **Card Background**:
  - `Container.decoration.color` = `pTheme.bg` (The selected pastel color).
- **Painter Update (`_PatternPainter`)**:
  - Change drawing color from `baseColor` (theme color) to `Colors.white`.
  - Gradient: Transparent -> White (0.2 ~ 0.3 opacity).
  - Droplets: White circles (0.2 ~ 0.4 opacity).
- **Text/Icon Colors**:
  - Background is now colored (Pastel), so text needs to be dark enough (`pTheme.fg`).
  - Update any hardcoded text styles to use `pTheme.fg` or `theme.textTheme` mixed with the theme logic.

## Logic Flow
User selects "Pastel Pink" -> Card becomes Pink -> White waves/droplets appear at bottom -> Text is Dark Red/Brown.

## Verification
- Check all 5 themes for contrast and visual appeal.
