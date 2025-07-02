import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;

  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Szukaj...',
              hintStyle: const TextStyle(
                color: Color(0xffDDDADA),
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.all(15),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8),
                child: Opacity(
                  opacity: 0.5,
                  child: SvgPicture.asset(
                    'assets/icons/search.svg',
                    height: 10,
                    width: 10,
                  ),
                ),
              ),
              suffixIcon:
                  value.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          FocusScope.of(context).unfocus();
                          onChanged('');
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          );
        },
      ),
    );
  }
}
