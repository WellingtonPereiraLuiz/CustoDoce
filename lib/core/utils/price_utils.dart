class PriceUtils {
  static double roundSuggestedPrice(double raw) {
    final intPart = raw.floor();
    final decimal = raw - intPart;
    if (decimal == 0.0) return raw; // já é inteiro
    if (decimal < 0.50) return intPart + 0.50;
    if (decimal < 0.75) return intPart + 0.99;
    return (intPart + 1).toDouble(); // sobe pro inteiro seguinte
  }
}
