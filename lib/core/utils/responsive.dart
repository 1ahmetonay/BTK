class Responsive {
  const Responsive._();

  static int gridColumns(double width) {
    if (width >= 1280) {
      return 4;
    }
    if (width >= 900) {
      return 3;
    }
    if (width >= 620) {
      return 2;
    }
    return 1;
  }
}
