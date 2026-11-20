class MateriItem {
  final int id;
  final String title;
  final String? description;
  final String? fileUrl;
  final String subjectName;
  final String className;
  final String teacherName;
  final String createdAt;

  const MateriItem({
    required this.id,
    required this.title,
    this.description,
    this.fileUrl,
    required this.subjectName,
    required this.className,
    required this.teacherName,
    required this.createdAt,
  });

  factory MateriItem.fromJson(Map<String, dynamic> json) {
    return MateriItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      fileUrl: json['file_url'],
      subjectName: json['subject_name'] ?? '',
      className: json['class_name'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class GuruKelasMapel {
  final int classSubjectId;
  final int classId;
  final String className;
  final int subjectId;
  final String subjectName;

  const GuruKelasMapel({
    required this.classSubjectId,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
  });

  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v.toString()) ?? 0;

  factory GuruKelasMapel.fromJson(Map<String, dynamic> json) {
    return GuruKelasMapel(
      classSubjectId: _toInt(json['class_subject_id']),
      classId: _toInt(json['class_id']),
      className: json['class_name'] ?? '',
      subjectId: _toInt(json['subject_id']),
      subjectName: json['subject_name'] ?? '',
    );
  }
}