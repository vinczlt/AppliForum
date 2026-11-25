---
name: Nocturne
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#393939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#c4c7c8'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#8e9192'
  outline-variant: '#444748'
  surface-tint: '#c6c6c7'
  primary: '#ffffff'
  on-primary: '#2f3131'
  primary-container: '#e2e2e2'
  on-primary-container: '#636565'
  inverse-primary: '#5d5f5f'
  secondary: '#c7c6c6'
  on-secondary: '#2f3131'
  secondary-container: '#484949'
  on-secondary-container: '#b8b8b8'
  tertiary: '#ffffff'
  on-tertiary: '#2f3131'
  tertiary-container: '#e2e2e2'
  on-tertiary-container: '#636565'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e2e2e2'
  primary-fixed-dim: '#c6c6c7'
  on-primary-fixed: '#1a1c1c'
  on-primary-fixed-variant: '#454747'
  secondary-fixed: '#e3e2e2'
  secondary-fixed-dim: '#c7c6c6'
  on-secondary-fixed: '#1a1c1c'
  on-secondary-fixed-variant: '#464747'
  tertiary-fixed: '#e2e2e2'
  tertiary-fixed-dim: '#c6c6c7'
  on-tertiary-fixed: '#1a1c1c'
  on-tertiary-fixed-variant: '#454747'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  headline-xl:
    fontFamily: Geist
    fontSize: 36px
    fontWeight: '600'
    lineHeight: 44px
    letterSpacing: -0.03em
  headline-xl-mobile:
    fontFamily: Geist
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Geist
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.025em
  headline-lg-mobile:
    fontFamily: Geist
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 30px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Geist
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
    letterSpacing: -0.015em
  headline-sm:
    fontFamily: Geist
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Geist
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 26px
    letterSpacing: -0.005em
  body-md:
    fontFamily: Geist
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: 0em
  body-sm:
    fontFamily: Geist
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '400'
    lineHeight: 14px
    letterSpacing: 0.04em
  code-inline:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0em
  code-block:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-lg: 1.5rem
  margin: 1rem
  margin-md: 1.5rem
  margin-lg: 2.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
  space-2xl: 3rem
---

## Brand & Style
The design system embodies a nocturnal, focused environment engineered specifically for software engineers, systems architects, and technical researchers. It balances terminal-inspired rigor with high-end editorial clarity. The visual language conveys quiet authority, precision, and zero-distraction focus, avoiding synthetic novelty or decorative gamification.

The core aesthetic draws on refined technical minimalism with subtle brutalist undertones:
- **Absolute Contrast:** Contrast is driven purely by luminosity rather than chromatic saturation.
- **Architectural Planes:** Structural boundaries rely on hairline strokes, razor-sharp alignment, and calculated luminance shifts.
- **Subtlety & Intent:** Interactive states offer instant, crisp visual feedback using strict grayscale steps rather than blur effects or heavy glow.

## Colors
The palette is built strictly from an achromatic spectrum. Color signifies nothing; luminosity conveys all hierarchy, state changes, and semantic depth.

### Color Tiers
- **Canvas Base (`#000000`):** Pure black for the global root canvas and outer app shells, maximizing contrast on OLED displays.
- **Layer 1 Surface (`#0a0a0a`):** Primary container and structural panel backgrounds (e.g., sidebars, navigation bars, thread list containers).
- **Layer 2 Surface (`#121212`):** Elevated surfaces, individual post cards, active rows, and dropdown menus.
- **Border Default (`#262626`):** Standard structural dividers, card frames, and cell borders.
- **Border Subtle (`#1a1a1a`):** De-emphasized interior dividers and nested dividers.
- **Border Strong (`#404040`):** Interactive element borders in resting state, tab underlines, and active card perimeters.
- **Border Focus / Hover (`#ffffff`):** Active interactive focus indicators and primary button perimeters.
- **Text Primary (`#ffffff`):** Thread titles, headlines, primary actions, and focused code segments.
- **Text Secondary (`#a3a3a3`):** Body typography, technical metadata, and subheaders.
- **Text Muted (`#737373`):** Timestamps, thread stats, vote counters, and placeholder content.
- **Code Block Canvas (`#080808`):** Ultra-dark ground for raw mono snippets with a subtle `#262626` outline.

## Typography
Typography is split into two complementary roles:
1. **Geist (Prose & Structural Chrome):** High-density geometric clarity with neutral proportions. Tight letter-spacing gives headers an editorial polish, while generous body line-height maintains reading endurance across long-form architecture debates and documentation.
2. **JetBrains Mono (Technical Metadata & Code):** Used for code blocks, inline snippets, version tags, timestamps, thread coordinates, and user metadata badges.

### Typographic Hierarchy Rules
- Thread titles in lists use `headline-sm` or `headline-md` at `#ffffff` with a hover shift to `#a3a3a3`.
- Long-form markdown content inside discussion posts uses `body-lg` at `#a3a3a3` for relaxed reading; bold emphasis tags within prose invert to `#ffffff`.
- Metadata (authorship, relative timestamps, commit hashes, tag indicators) strictly maps to `label-md` or `label-sm` rendered in `#737373`.

## Layout & Spacing
The layout uses a constrained fluid grid calibrated for readability and content density.

### Breakpoints & Layout Model
- **Mobile (< 768px):** Single-column vertical stream. Page margin is `margin` (`1rem`). Side navigation collapses into a bottom status bar or minimal top sheet.
- **Tablet (768px - 1024px):** 2-column layout (Compact Navigation / Channels at 220px fixed, Main Stream fluid). Gutter is `gutter` (`1rem`), and edge margin is `margin-md` (`1.5rem`).
- **Desktop (> 1024px):** 3-column architecture (Left Navigation at 240px, Fluid Main Thread Stream with a max-width of 760px, Right Rail for Thread Meta & Hot Nodes at 300px). Gutter expands to `gutter-lg` (`1.5rem`), outer canvas margin to `margin-lg` (`2.5rem`).

### Rhythm Rules
- Component paddings strictly use the `space-*` tokens.
- Internal card padding defaults to `space-md` on mobile and `space-lg` on desktop.
- Vertical space between distinct forum posts or comments is locked to `space-md`. Nested replies are indented by `space-lg` and bordered with a left hairline rule.

## Elevation & Depth
Depth in this design system is architectural and flat. It completely rejects blur-heavy drop shadows, colored halos, and skeuomorphic gradients in favor of **Tonal Layering** and **Low-Contrast Hairline Outlines**.

### Elevation Stack
- **Surface Level 0 (Canvas, `#000000`):** The global backdrop. Un-bordered and pure dark.
- **Surface Level 1 (Panels & Sidebar, `#0a0a0a`):** Separated from the canvas via a 1px solid stroke (`#1a1a1a` or `#262626`).
- **Surface Level 2 (Cards, Rows, Modals, `#121212`):** Discrete interactive containers. Defined by a continuous 1px border of `#262626`.
- **Surface Level 3 (Popovers, Tooltips, Command Palettes, `#171717`):** Floating developer overlays. Surrounded by a 1px border of `#404040` and a crisp, non-diffuse ambient occlusion edge: `0 4px 16px rgba(0, 0, 0, 0.8)`.

### State Elevations
Hovering over any card or list item does not lift it on the Z-axis. Instead, it triggers a border luminosity step: the border transitions from `#262626` to `#404040`, while the background shifts subtly from `#121212` to `#171717`.

## Shapes
The design system employs a soft, restrained corner radius (`roundedness: 1`), balancing structural precision with modern ergonomics.

### Implementation Rules
- **Base Elements (Buttons, Inputs, Badges, Chips):** `0.25rem` (`4px`). Provides a crisp, engineered feel reminiscent of command-line terminals and IDE interfaces.
- **Containers (Cards, Code Blocks, Dialogs):** `rounded-lg` at `0.5rem` (`8px`). Prevents dense technical screens from appearing harsh.
- **Floating Modals & Dropdown Windows:** `rounded-xl` at `0.75rem` (`12px`).
- **Pill Shapes:** Strictly forbidden. Avatars, status badges, and vote counters remain square or rounded with base radii (`4px`). Fully circular elements are reserved exclusively for circular user avatars (`50%` radius).

## Components

### Buttons
- **Primary:** Background `#ffffff`, text `#000000`, border 1px solid `#ffffff`, font `Geist` weight 500. On hover, background shifts to `#e5e5e5`. On active/press, `#cccccc`.
- **Secondary:** Background `#121212`, text `#ffffff`, border 1px solid `#333333`. On hover, background `#1a1a1a`, border `#404040`.
- **Ghost / Tertiary:** Background transparent, text `#a3a3a3`, border 1px solid transparent. On hover, background `#121212`, text `#ffffff`.
- **Destructive:** Background `#121212`, text `#ffffff`, border 1px solid `#737373` (labeled with explicit text warning, remaining strictly within the monochrome system).

### Chips & Tags
- **Category & Language Chips:** Background `#0a0a0a`, border 1px solid `#262626`, typography `label-sm` (`JetBrains Mono`), text `#a3a3a3`.
- **Filter Active:** Background `#ffffff`, text `#000000`, border 1px solid `#ffffff`.
- Padding: `0.2rem 0.5rem`.

### Form Controls (Inputs, Checkboxes, Radios)
- **Text Inputs:** Background `#0a0a0a`, border 1px solid `#333333`, text `#ffffff`, placeholder `#737373`. Radius `4px`. On focus, border `#ffffff` with a zero-offset outline: `box-shadow: 0 0 0 1px #ffffff`.
- **Checkboxes:** Custom square 16x16 box, background `#0a0a0a`, border 1px solid `#404040`. When checked, background `#ffffff` with a black checkmark icon (`#000000`).
- **Radio Buttons:** Custom circle 16x16, background `#0a0a0a`, border 1px solid `#404040`. When checked, background `#0a0a0a` with an inner solid circle of `#ffffff` (size 6px).

### Cards & Thread Items
- **Thread List Card:** Background `#0a0a0a`, border 1px solid `#1a1a1a`, padding `space-md`. Border transitions to `#333333` on hover.
- **Pinned / Featured Card:** Background `#121212`, border 1px solid `#333333`. Top edge accented with a 2px hairline border of `#ffffff`.

### Lists & Tree Views
- Nested technical discussions use a continuous vertical 1px guide line (`#1a1a1a`). Hovering a parent reply lights the active branch guide line to `#404040`.

### Technical & Forum-Specific Components
- **Code Block:** Container `#080808`, border 1px solid `#262626`. Header bar displaying language (`label-sm`) and file path in `#737373`, separated by a 1px border. Copy button styled as ghost micro-button.
- **Vote Counter:** Stacked vertical capsule, background `#0e0e0e`, border 1px solid `#262626`, text `label-md` (`JetBrains Mono`) `#a3a3a3`. Upvote/downvote icons shift to `#ffffff` when active.
- **Diff Display:** Additions rendered with text `#ffffff` over background `#141414` with a `+` gutter indicator; deletions rendered with text `#737373` (struck through) over background `#0a0a0a` with a `-` indicator.