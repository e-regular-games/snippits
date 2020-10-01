
## Simple UI Skin in Godot

This demo shows how to apply a custom texture to buttons and panels in Godot. Here are the key take-aways.

- Panel textures are only used once across the app, so a node local StyleBox was used.
- Buttons have multiple StyleBoxes, so a Theme was used and saved external to the scene.
- A Tween was used to add some satisfying movement to showing the panel.
- A combination of nodes which allow anchoring of their children and nodes which force child positions was used.
- The border around the outside was added to make the UI appear consistent across the screen.
