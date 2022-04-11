import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RandomProvider extends ChangeNotifier {
  List<int> randoms =
      List.generate(9, (index) => Random().nextInt(50)).toList();
  bool isVisible = false;
  List onTap = List.generate(9, (index) => false);
  List<Color> color = [];

  List<int> rand2 = [];

  void showRandoms() {
    isVisible = true;
    Future.delayed(const Duration(seconds: 5)).then((value) {
      isVisible = false;
      notifyListeners();
    });
    notifyListeners();
  }

  void randomize() {
    randoms = List.generate(9, (index) => Random().nextInt(50));
    rand2 = List.generate(9, (index) => randoms[index]);
    onTap = List.generate(9, (index) => false);
    notifyListeners();
  }

  void delete(int index) {

    List<int> sorted = List.generate(randoms.length, (index) => index);
    rand2.sort();
    print(rand2);

    if (randoms[index] == rand2.first) {
      rand2.removeAt(0);
      print(rand2);
      onTap[index] = true;
      print(onTap);
      notifyListeners();
    }
    notifyListeners();
  }
}