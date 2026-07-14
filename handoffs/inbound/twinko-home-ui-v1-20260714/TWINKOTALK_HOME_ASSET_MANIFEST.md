# TwinkoTalk Home Asset Manifest

**Status:** Finalized for Home implementation  
**Version:** v1

## 1. Home Background

| Asset | Purpose | Format | Notes |
|---|---|---|---|
| `home_screen_v1.png` | Full-screen Home background | PNG | Use aspect fill; do not stretch; no runtime recoloring |

## 2. Home Character

| Asset | Purpose | Format | Notes |
|---|---|---|---|
| `twinko_default_smile_v1.png` | Canonical central Home Twinko | Transparent PNG | Do not redraw or alter proportions |

## 3. Home Mode Icons

| Asset | Mode | English label | Traditional Chinese | Notes |
|---|---|---|---|---|
| `home_icon_chat_v1.png` | Chat | Chat | 聊天 | Display at the same dimensions as all other icons |
| `home_icon_tarot_v1.png` | Tarot | Tarot | 塔羅 | Opens Tarot |
| `home_icon_zodiac_v1.png` | Horoscope | Zodiac | 星座 | Home label remains `Zodiac` |
| `home_icon_meditate_v1.png` | Meditation | Meditate | 冥想 | Opens placeholder page until implemented |
| `home_icon_music_v1.png` | Music | Music | 音樂 | Opens placeholder page until implemented |

All icons:

- Transparent PNG
- Equal displayed circle diameter
- Preserve original aspect ratio
- Do not resize based on internal symbol size
- Normalize through a fixed rendered frame when needed

## 4. Available Twinko Expression Assets

| Asset | Intended semantic use |
|---|---|
| `twinko_calm_rest_v1.png` | Calm, rest, meditation |
| `twinko_celebration_v1.png` | Celebration, success, positive feedback |
| `twinko_chat_listening_v1.png` | Active listening in Chat |
| `twinko_comforting_v1.png` | Emotional comfort |
| `twinko_cosmic_guide_v1.png` | Zodiac or cosmic guidance |
| `twinko_default_smile_v1.png` | Canonical default and Home |
| `twinko_encouraging_v1.png` | Encouragement |
| `twinko_gentle_concern_v1.png` | Gentle concern |
| `twinko_magical-v1.png` | Magical focus or ritual state |
| `twinko_sad_v1.png` | Sad expression |
| `twinko_sleepy_v1.png` | Sleepy or dreamy state |
| `twinko_thinking_v1.png` | Thinking or processing |

## 5. Asset Usage Rules

- Preserve filenames exactly
- Do not overwrite source files
- Do not recolor approved assets
- Do not distort aspect ratios
- Do not regenerate substitutes
- Do not bake labels into icon images
- Do not bake Twinko into the background
- Keep background, character, icons, labels, and animation layers separate

## 6. Recommended Project Structure

```text
assets/
  home/
    home_screen_v1.png
    home_icon_chat_v1.png
    home_icon_tarot_v1.png
    home_icon_zodiac_v1.png
    home_icon_meditate_v1.png
    home_icon_music_v1.png

  twinko/
    twinko_default_smile_v1.png
    twinko_calm_rest_v1.png
    twinko_celebration_v1.png
    twinko_chat_listening_v1.png
    twinko_comforting_v1.png
    twinko_cosmic_guide_v1.png
    twinko_encouraging_v1.png
    twinko_gentle_concern_v1.png
    twinko_magical-v1.png
    twinko_sad_v1.png
    twinko_sleepy_v1.png
    twinko_thinking_v1.png
```

## 7. Validation Checklist

- [ ] Every referenced filename exists in the repository
- [ ] PNG transparency is preserved
- [ ] Home background renders edge-to-edge
- [ ] All five Home icons display at identical dimensions
- [ ] Central Twinko uses `twinko_default_smile_v1.png`
- [ ] Labels are live text, not image text
- [ ] English and Traditional Chinese are supported
- [ ] Placeholder navigation exists for Meditate and Music
