import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Container searchField() {
  return Container(
    margin: EdgeInsets.only(top: 40, left: 20, right: 20),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Color(0xff1D1617).withValues(alpha: .11),
          blurRadius: 40,
          spreadRadius: 0.0,
        ),
      ],
    ),
    child: TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(15),
        hintText: 'Szukaj...',
        hintStyle: TextStyle(color: Color(0xffDDDADA), fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Opacity(
            opacity: 0.5,
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              height: 10,
              width: 10,
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}
