import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Frame size of the source sprite sheet (192x192px, 3x3 grid → 64x64px/frame).
const _frameSize = 64.0;
const _framesPerRow = 3;
const _frameCount = 9;
const _stepTime = 0.2;

/// Loops the puppy's 4-frame wagging-tail sprite sheet.
///
/// Keeps [FixedResolutionViewport] pinned to one frame's size so the sprite
/// fills the widget exactly, with no camera panning/zoom to configure.
class PetSpriteGame extends FlameGame {
  PetSpriteGame() : super(camera: CameraComponent.withFixedResolution(width: _frameSize, height: _frameSize));

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    // Flame's default Images prefix is 'assets/images/'; the sprite lives
    // under 'assets/animals/' instead, so load it without that prefix.
    images.prefix = '';
    final image = await images.load('assets/animals/puppy/puppy wagging tail2.png');

    final animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: _frameCount,
        amountPerRow: _framesPerRow,
        stepTime: _stepTime,
        textureSize: Vector2.all(_frameSize),
      ),
    );
    // Nearest-neighbor filtering keeps pixel-art edges crisp when scaled up.
    for (final frame in animation.frames) {
      frame.sprite.paint.filterQuality = FilterQuality.none;
    }

    world.add(
      SpriteAnimationComponent(
        animation: animation,
        size: Vector2.all(_frameSize),
        anchor: Anchor.center,
      ),
    );
  }
}

/// Drop-in replacement for the emoji pet display: a fixed-size, non-interactive
/// looping animation. Wrap in a [SizedBox] of [size]x[size] at the call site if
/// a different footprint is needed.
class PetSpriteView extends StatelessWidget {
  const PetSpriteView({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: GameWidget(
        game: PetSpriteGame(),
        backgroundBuilder: (context) => const SizedBox.expand(),
      ),
    );
  }
}
