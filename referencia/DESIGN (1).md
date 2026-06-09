---
name: Artisanal Ledger
colors:
  surface: '#fff8f6'
  surface-dim: '#e0d8d7'
  surface-bright: '#fff8f6'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#faf2f0'
  surface-container: '#f4ecea'
  surface-container-high: '#eee6e5'
  surface-container-highest: '#e9e1df'
  on-surface: '#1e1b1a'
  on-surface-variant: '#504442'
  inverse-surface: '#33302f'
  inverse-on-surface: '#f7efed'
  outline: '#827471'
  outline-variant: '#d4c3bf'
  surface-tint: '#755751'
  primary: '#1e0a07'
  on-primary: '#ffffff'
  primary-container: '#361f1a'
  on-primary-container: '#a7847d'
  inverse-primary: '#e5beb6'
  secondary: '#6b5a60'
  on-secondary: '#ffffff'
  secondary-container: '#f1dae1'
  on-secondary-container: '#6f5e64'
  tertiary: '#00140f'
  on-tertiary: '#ffffff'
  tertiary-container: '#132924'
  on-tertiary-container: '#7a918a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad3'
  primary-fixed-dim: '#e5beb6'
  on-primary-fixed: '#2b1611'
  on-primary-fixed-variant: '#5c403a'
  secondary-fixed: '#f4dde4'
  secondary-fixed-dim: '#d7c1c8'
  on-secondary-fixed: '#24181d'
  on-secondary-fixed-variant: '#524348'
  tertiary-fixed: '#cfe8e0'
  tertiary-fixed-dim: '#b3ccc4'
  on-tertiary-fixed: '#091f1b'
  on-tertiary-fixed-variant: '#354b45'
  background: '#fff8f6'
  on-background: '#1e1b1a'
  surface-variant: '#e9e1df'
typography:
  display-lg:
    fontFamily: Source Serif 4
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Source Serif 4
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-md:
    fontFamily: Source Serif 4
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-sm:
    fontFamily: Source Serif 4
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Work Sans
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Work Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Work Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Work Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.1px
  data-lg:
    fontFamily: Work Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  headline-lg-mobile:
    fontFamily: Source Serif 4
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 34px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 64px
---

## Brand & Style

The design system establishes a high-end, artisanal atmosphere tailored for professional bakers and bakery owners managing complex finances. The aesthetic balances the warmth of a boutique kitchen with the precision of a modern financial tool.

The design style is **Corporate Modern with a Tactile twist**. It utilizes a "Warm Minimalism" approach, characterized by generous whitespace, a sophisticated earthy palette, and subtle elevation that suggests physical layers—much like the structure of fine pastry. The emotional response is one of calm, professional reliability and "handmade" quality, eschewing cold, generic fintech tropes for a more grounded, organic experience.

## Colors

This design system utilizes a palette of deep browns, dusty roses, and cream tones to evoke ingredients like chocolate, flour, and berry. 

- **Primary & Primary Container:** Dark Chocolate tones provide the "ink" of the system, used for high-emphasis elements and primary actions.
- **Secondary & Secondary Container:** Dusty Rose adds a soft, editorial touch for tonal variety and highlighting selection states.
- **Neutrals:** The background is a warm cream (`#FFF8F6`) to reduce eye strain and feel more inviting than pure white, while surfaces use pure white (`#FFFFFF`) to create clear visual separation.
- **Semantic Colors:** Success and Error colors are tuned for high legibility against cream backgrounds while maintaining professional saturation levels.

## Typography

The typography strategy employs a high-contrast pairing between a classic serif and a functional sans-serif.

- **Headlines (Source Serif 4):** Used for titles and branding to convey authority and elegance. The semi-bold and bold weights provide a sturdy, editorial feel.
- **Body & Data (Work Sans):** Chosen for its exceptional legibility in financial contexts. 
- **Financial Data Styling:** All numerical data must use `Work Sans` with **Tabular Figures** enabled (`tnum`) to ensure decimal points and digits align vertically in cost calculations and spreadsheets.

## Layout & Spacing

The layout follows a **Fixed-Fluid Hybrid** model. On desktop, content is centered within a 1200px max-width container to maintain readability. On mobile and tablet, it uses a fluid grid with a 4-column and 8-column structure respectively.

- **Spacing Rhythm:** Based on a 4px/8px incremental scale. 
- **Margins:** 16px safe-area margins for mobile devices; 64px or auto-centering for desktop.
- **Density:** The system prioritizes medium density to allow the typography to "breathe," reflecting a premium, unhurried brand experience.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** supplemented by **Ambient Chocolate Shadows**. 

1. **Level 0 (Base):** The Cream background (`#FFF8F6`).
2. **Level 1 (Cards/Surfaces):** Pure white surfaces with a 1px border in `#D4C3BF`. 
3. **Shadows:** Instead of neutral greys, shadows use a very low-opacity Dark Chocolate tint (`#361F1A` at 8-12% opacity). This maintains the warmth of the palette even in the depth effects. Shadows should feel soft and diffused, with a high blur radius (e.g., 8px to 16px) and minimal offset.

## Shapes

The shape language is **Rounded**, avoiding the harshness of sharp corners while maintaining professional structure. 

- **Cards:** 16px (rounded-lg) to create a soft, containerized feel.
- **Buttons:** 8px to 12px depending on size, ensuring they feel "clickable" and tactile.
- **Inputs:** Consistent with buttons to create a unified form-language.
- **Selection Indicators:** Pill-shaped (fully rounded) for clear visual feedback in navigation components.

## Components

- **Buttons:** Primary buttons use the `#4E342E` (Primary Container) fill with White text. For secondary actions, use an outline style with the `#827471` border.
- **Input Fields:** Utilize a filled style with `#F4ECEA` background. Upon focus, the border transitions to a 2px solid Dark Chocolate (`#361F1A`). Labels remain above the field in `label-lg` Work Sans.
- **Cards:** Essential for the cost calculator. White background, `#D4C3BF` border, 16px radius. When cards are "active" or "selected," use a subtle `#F4DCE4` (Secondary Container) glow or border.
- **Chips:** Used for ingredient categories or status filters. Use the Secondary palette (Dusty Rose) with semi-bold Work Sans text.
- **NavigationBar:** Bottom navigation (mobile) or Side rail (tablet) using Material 3 logic. Background is white, with the active state indicated by a `#F4DCE4` pill-shaped container behind the icon.
- **Data Tables:** Clean, no vertical lines. Use horizontal `#D4C3BF` dividers and `data-lg` typography for final totals.