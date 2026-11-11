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
