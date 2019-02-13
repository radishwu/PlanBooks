class PlanBookEntity {
  int id;
  int planId;
  String title;
  String doneDate;
  int isRead;

  PlanBookEntity();

  PlanBookEntity.formMap(Map<String, dynamic> map) {
    id = map["id"];
    planId = map['plan_id'];
    title = map['title'];
    doneDate = map['done_date'];
    isRead = map['is_read'];
  }
}