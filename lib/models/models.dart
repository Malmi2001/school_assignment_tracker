class Student {
  final int? id;
  final String name;
  final String email;
  final String contact;

  Student({
    this.id,
    required this.name,
    required this.email,
    required this.contact,
  }) {
    // Error handling for name
    if (name.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }

    // Error handling for email
    if (email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }

    // Error handling for contact
    if (contact.isEmpty) {
      throw ArgumentError('Contact cannot be empty');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contact': contact,
    };
  }

  @override
  String toString() {
    return 'Student(id: $id, name: $name, email: $email, contact: $contact)';
  }

  delete() {}

  save() {}
}

class Mark {
  final int? id;
  final int studentId;
  final String term;
  final String subject;
  final int mark;

  Mark({
    this.id,
    required this.studentId,
    required this.term,
    required this.subject,
    required this.mark,
  }) {
    // Error handling for term
    if (term.isEmpty) {
      throw ArgumentError('Term cannot be empty');
    }

    // Error handling for subject
    if (subject.isEmpty) {
      throw ArgumentError('Subject cannot be empty');
    }

    // Error handling for mark
    if (mark < 0 || mark > 100) {
      throw ArgumentError('Mark must be between 0 and 100');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'term': term,
      'subject': subject,
      'mark': mark,
    };
  }

  @override
  String toString() {
    return 'Mark(id: $id, studentId: $studentId, term: $term, subject: $subject, mark: $mark)';
  }

  delete() {}
}
