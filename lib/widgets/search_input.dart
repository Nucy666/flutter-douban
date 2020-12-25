import 'package:flutter/material.dart';

typedef SearchInputOnFocusCallback = void Function();
typedef SearchInputOnSubmittedCallback = void Function(String value);
typedef SearchInputTextChangedCallback = void Function(String value);

class SearchInputWidget extends StatelessWidget {
  SearchInputOnFocusCallback onTap;
  SearchInputOnSubmittedCallback onSubmitted;
  SearchInputTextChangedCallback onTextChamged;
  bool autofocus;
  SearchInputWidget({this.onTap, this.onSubmitted, this.onTextChamged,this.autofocus});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: onTap,
      onSubmitted: onSubmitted,
      onChanged: onTextChamged,
      autofocus: autofocus,
      decoration: InputDecoration(
          hintText: '搜索',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
          border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8)),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black26,
          )),
    );
  }
}
