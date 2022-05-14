import 'package:flutter/material.dart';
import 'package:repo_batch/common/color.dart';

class CommonTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CommonTextButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(AppColors.buttonColor),
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: 100,
        height: 46,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}


class CommonImageButton extends StatefulWidget {

  final GestureTapCallback onTap;
  final String imgPath;
  final double width;
  final String toolTipMsg;

  const CommonImageButton({
    Key? key,
    required this.width,
    required this.imgPath,
    required this.onTap,
    this.toolTipMsg = '',
  }) : super(key: key);

  @override
  State<CommonImageButton> createState() => _CommonImageButtonState();
}

class _CommonImageButtonState extends State<CommonImageButton> {

  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    if (widget.toolTipMsg.isNotEmpty) {
      return Tooltip(
        message: widget.toolTipMsg,
        textStyle: const TextStyle(
          fontSize: 12,
          color: Colors.white70,
        ),
        waitDuration: const Duration(milliseconds: 500),
        showDuration: const Duration(milliseconds: 100),
        child: _buildImageContent(),
      );
    }
    return _buildImageContent();
  }

  Widget _buildImageContent() {
    return InkWell(
      onTap: widget.onTap,
      onHover: (hover) {
        setState(() {
          _hover = hover;
        });
      },
      child: Opacity(
        opacity: _hover ? 0.5 : 1,
        child: Image(
          width: widget.width,
          image: AssetImage(widget.imgPath),
        ),
      ),
    );
  }
}