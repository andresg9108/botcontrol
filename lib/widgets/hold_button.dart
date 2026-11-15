import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class HoldButton extends StatefulWidget {
  const HoldButton({
    super.key,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.pressed,
    required this.onChanged,
    this.height = 110,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final bool pressed;
  final ValueChanged<bool> onChanged;
  final double height;

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton> {
  int? _pointer;

  void _release() {
    if (_pointer == null) return;
    _pointer = null;
    widget.onChanged(false);
  }

  @override
  void didUpdateWidget(covariant HoldButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) _pointer = null;
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${widget.label}, mantener pulsado',
    button: true,
    enabled: widget.enabled,
    excludeSemantics: true,
    child: RawGestureDetector(
      // Reserva los dedos para conducir sin activar el scroll de la pantalla.
      // Reserves touch input for driving without triggering screen scrolling.
      gestures: {
        EagerGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
              EagerGestureRecognizer.new,
              (_) {},
            ),
      },
      child: Listener(
        // Listener permite acelerar y girar con dos dedos al mismo tiempo.
        // Listener allows accelerating and steering with two fingers at once.
        onPointerDown: (event) {
          if (!widget.enabled || _pointer != null) return;
          _pointer = event.pointer;
          widget.onChanged(true);
        },
        onPointerUp: (event) {
          if (event.pointer == _pointer) _release();
        },
        onPointerCancel: (event) {
          if (event.pointer == _pointer) _release();
        },
        onPointerMove: (event) {
          final box = context.findRenderObject() as RenderBox;
          if (event.pointer == _pointer &&
              !(Offset.zero & box.size).contains(event.localPosition)) {
            _release();
          }
        },
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 120),
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.enabled && widget.pressed
                ? AppColors.controlPressed
                : AppColors.panel,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.enabled && widget.pressed
                  ? AppColors.controlPressed
                  : widget.enabled
                  ? AppColors.outline
                  : AppColors.raised,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final icon = Icon(
                  widget.icon,
                  size: 32,
                  color: widget.enabled && widget.pressed
                      ? Colors.white
                      : widget.enabled
                      ? AppColors.accent
                      : AppColors.muted,
                );
                final label = Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.enabled ? Colors.white : AppColors.muted,
                    letterSpacing: 0.3,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                );
                // En poca altura, el texto conserva su escala junto al icono.
                if (constraints.maxHeight < 90 && constraints.maxWidth >= 180) {
                  return Row(
                    children: [
                      icon,
                      const SizedBox(width: 6),
                      Expanded(child: label),
                    ],
                  );
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(fit: BoxFit.scaleDown, child: icon),
                    ),
                    const SizedBox(height: 6),
                    label,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
