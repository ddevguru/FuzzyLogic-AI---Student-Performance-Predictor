/// Represents an individual gene inside a chromosome.
class Gene<T> {
  final T value;
  final bool isMutated;

  const Gene({
    required this.value,
    this.isMutated = false,
  });

  Gene<T> copyWith({T? value, bool? isMutated}) {
    return Gene<T>(
      value: value ?? this.value,
      isMutated: isMutated ?? this.isMutated,
    );
  }

  @override
  String toString() => value.toString();
}
