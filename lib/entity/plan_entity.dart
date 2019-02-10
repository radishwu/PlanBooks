class PlanEntity {
  int id;
  String name;
  int total;
  int current;
  String endDate;

  PlanEntity(this.name, this.total, this.current, this.endDate);

  PlanEntity.formMap(Map<String, dynamic> map) {
    id = map["id"];
    name = map['name'];
    total = map['total'];
    current = map['current'];
    endDate = map['end_date'];
  }
}
