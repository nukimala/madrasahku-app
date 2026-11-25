class MateriItem {
  final int id;
  final String title;
  final String? description;
  final String? fileUrl;
  final String subjectName;
  final String className;
  final String teacherName;
  final String createdAt;
  final int? topicId;
  final int? topicMinggu;
  final String? topicNama;

  const MateriItem({
    required this.id,
    required this.title,
    this.description,
    this.fileUrl,
    required this.subjectName,
    required this.className,
    required this.teacherName,
    required this.createdAt,
    this.topicId,
    this.topicMinggu,
    this.topicNama,
  });

  factory MateriItem.fromJson(Map<String, dynamic> json) {
    final topic = json['topic'];
    final subj = json['subject'];
    final cls = json['class'];
    return MateriItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      fileUrl: (json['file_url'] ?? json['external_url'])?.toString(),
      subjectName: subj is Map
          ? (subj['name'] ?? '').toString()
          : (json['subject_name'] ?? '').toString(),
      className: cls is Map
          ? (cls['name'] ?? '').toString()
          : (json['class_name'] ?? '').toString(),
      teacherName: (json['author_name'] ?? json['teacher_name'] ?? '').toString(),
      createdAt: (json['published_at'] ?? json['created_at'] ?? '').toString(),
      topicId: topic is Map
          ? (topic['id'] is int ? topic['id'] as int : int.tryParse(topic['id']?.toString() ?? ''))
          : null,
      topicMinggu: topic is Map
          ? (topic['minggu'] is int ? topic['minggu'] as int : int.tryParse(topic['minggu']?.toString() ?? ''))
          : null,
      topicNama: topic is Map ? topic['nama']?.toString() : null,
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