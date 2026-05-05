
class Validators {
  // Validator per controllare se il campo non è vuoto
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Questo campo non può essere vuoto';
    }
    return null;
  }

  // Validator per controllare la lunghezza minima
  static String? minLength(String? value, int min) {
    if (value != null && value.length < min) {
      return 'Deve avere almeno $min caratteri';
    }
    return null;
  }

  // Validator per email valida
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email non obbligatoria
    }
    // Regex semplice per validare l'email
    String pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
        r"[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Inserisci un\'email valida';
    }
    return null;
  }
  // Validator per una password forte (almeno un carattere maiuscolo, un numero e un simbolo)
  static String? strongPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La password non può essere vuota';
    }

    // Espressione regolare per almeno una lettera maiuscola, un numero e un simbolo
    String pattern = r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'La password deve contenere almeno una lettera maiuscola, un numero e un simbolo';
    }

    return null;
  }

}
