# Storybook fridge food page style probe

## `probe_food_bread.png`

- Tool: `image_gen` (built-in); transparent-background post-process: `remove_chroma_key.py`
- Output: `probe_food_bread.png`
- Prompt:

```text
Use case: illustration-story
Asset type: transparent-background storybook food character master PNG, 1024x1024.
Input image: the most recent image is a reference image for the Food Savior brand's hand-painted visual language only; do not copy its Chihuahua into this asset.
Primary request: create one original toast-bread food character, standing front-facing.
Scene/backdrop: a perfectly flat, uniform solid chroma-key green background #00ff00 for later background removal. No shadows, no floor, no texture, no lighting variation.
Subject: one thick slice of toast bread as a friendly original food character, warm bread-brown crust and creamy golden interior. A simple sleepy, slightly goofy face on the front: half-lidded eyes and a tiny small mouth. Two short gray little feet extend from underneath in a standing pose.
Style/medium: Japanese children's picture-book-inspired hand-drawn illustration with crayon and colored-pencil texture, thick but soft dark brown contour lines, warm cream-yellow, bread-brown, and orange palette. Flat 2D illustration, no 3D.
Composition/framing: centered single subject, subject occupies about 70% of the square canvas, generous clean padding on all sides, fully separated from the green background.
Materials/textures: visible handmade wax-crayon and colored-pencil grain inside the bread and outline, gentle imperfect hand-drawn edges, but keep the face clearly readable.
Lighting/mood: warm, playful, quietly adorable, sleepy and dazed.
Text (verbatim): none.
Constraints: original food-character design; no humans and no human face; no copied source characters; no brand text; no text; no watermark. Keep the two eyes clearly half-open and the mouth very small. Keep exactly two short gray feet.
Avoid: toast thief, baguette dog, any recognizable copyrighted character, Chihuahua, extra food, extra limbs, hands, arms, legs beyond the two tiny feet, realistic food photography, 3D, gradients, glow, particles, cast shadow, reflection, background variation, lettering, watermark.
```

## `probe_food_egg_milk.png`

- Tool: `image_gen` (built-in); transparent-background post-process: `remove_chroma_key.py`
- Output: `probe_food_egg_milk.png`
- Prompt:

```text
Use case: illustration-story
Asset type: transparent-background storybook food character master PNG, 1024x1024.
Input image: the most recent image is a reference image for the Food Savior brand's hand-painted visual language only; do not include the Chihuahua in this asset.
Primary request: create one original two-character food duo, a single egg and a small milk carton standing side by side.
Scene/backdrop: a perfectly flat, uniform solid chroma-key green background #00ff00 for later background removal. No shadows, no floor, no texture, no lighting variation.
Subject: one warm cream egg on the left and one small pale cream milk carton on the right, touching or standing close together as a friendly pair. Both characters have simple sleepy, slightly goofy half-lidded eyes and tiny small mouths. The milk carton is slightly taller than the egg. The carton has a minimal blank label area with no writing, no logo, and no symbols.
Style/medium: Japanese children's picture-book-inspired hand-drawn illustration with crayon and colored-pencil texture, thick but soft dark brown contour lines, warm cream-yellow, milk-white, bread-brown, and orange accent palette. Flat 2D illustration, no 3D.
Composition/framing: centered single duo composition, both characters together occupy about 70% of the square canvas, generous clean padding on all sides, fully separated from the green background.
Materials/textures: visible handmade wax-crayon and colored-pencil grain inside the shell and carton, gentle imperfect hand-drawn edges, face details clearly readable at icon size.
Lighting/mood: warm, playful, quietly adorable, sleepy and dazed.
Text (verbatim): none.
Constraints: exactly one egg and exactly one small milk carton; original food-character design; no humans and no human face; no copied source characters; no brand text; no text; no watermark. Keep both faces visibly half-open and mouths very small. Keep the milk carton slightly taller than the egg.
Avoid: toast thief, baguette dog, any recognizable copyrighted character, Chihuahua, extra food, extra characters, arms, hands, legs, realistic food photography, 3D, gradients, glow, particles, cast shadow, reflection, background variation, lettering, watermark.
```

## `probe_chihuahua_peek_happy.png`

- Tool: `image_gen` (built-in), with `assets/icons/food_savior_logo.png` as the reference image; transparent-background post-process: `remove_chroma_key.py`
- Output: `probe_chihuahua_peek_happy.png`
- Prompt:

```text
Use case: illustration-story
Asset type: transparent-background storybook character master PNG, 1024x1024.
Input image: Image 1 is the original Food Savior brand Chihuahua logo, used as an identity reference only. Preserve the recognizable brand cues but create a new pose and composition; do not trace or reproduce the logo's original composition.
Primary request: the original black-and-tan Chihuahua mascot peeking happily from behind a shelf at the bottom edge of the canvas.
Scene/backdrop: a perfectly flat, uniform solid chroma-key green background #00ff00 for later background removal. At the very bottom, include only one simple horizontal cream-colored shelf front edge/board, a clean rounded rectangular strip; no room, no refrigerator, no background scenery, no shadow.
Subject: only the Chihuahua's upper body, head, ears, neck, and two front paws visible above the shelf edge. Black main coat, exactly two separate warm brown/tan eyebrow patches, warm tan muzzle and inner ears, golden-yellow cape behind the shoulders. The dog is leaning forward over the shelf with both front paws resting on the cream shelf edge. Open happy grin with small teeth, eyes closed into curved smiling arcs. Keep the dog cheerful and adorable.
Style/medium: Japanese children's picture-book-inspired hand-drawn illustration with crayon and colored-pencil texture, thick but soft dark brown contour lines, warm cream-yellow, bread-brown, orange, and black palette. Flat 2D illustration, no 3D.
Composition/framing: centered, head and paws rising from the lower shelf edge, subject plus shelf occupies about 70% of the square canvas, generous transparent padding around the ears and sides, fully separated from the green background.
Materials/textures: visible handmade wax-crayon and colored-pencil grain, gently imperfect painted edges, readable silhouette.
Lighting/mood: warm, playful, delighted, happy peekaboo moment.
Text (verbatim): none.
Constraints: use the reference only for the original mascot identity; keep black coat, two independent brown eyebrow patches, golden cape, and Chihuahua ears. Show only upper body and exactly two front paws; the lower body must remain hidden behind the shelf. No bread in paws in this pose. No humans and no human face; no text; no watermark.
Avoid: full-body dog, visible hind legs, extra paws, extra limbs, open eyes, serious expression, realistic dog photography, copied logo layout, toast thief, baguette dog, extra characters, 3D, gradients, glow, particles, cast shadow, reflection, background variation, lettering, watermark.
```
