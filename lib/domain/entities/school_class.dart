class SchoolClass {
  const SchoolClass({required this.id, required this.name, this.teacher = '', this.teacherPhone = ''});
  final String id;
  final String name;
  final String teacher;
  final String teacherPhone;

  SchoolClass copyWith({String? name, String? teacher, String? teacherPhone}) => SchoolClass(
      id: id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      teacherPhone: teacherPhone ?? this.teacherPhone);
}
