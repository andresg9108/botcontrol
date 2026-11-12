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
          duration: const Duration(milliseconds: 90),
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.pressed ? AppColors.accent : AppColors.panel,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.pressed ? AppColors.accent : Colors.white10,
            ),
          ),
          child: Opacity(
            opacity: widget.enabled ? 1 : 0.3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 34,
                  color: widget.pressed ? Colors.black : AppColors.accent,
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.pressed ? Colors.black : Colors.white,
                      letterSpacing: 1.3,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
