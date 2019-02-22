import 'package:flutter/material.dart';
import '../entity/plan_entity.dart';
import 'plan_detail_panel.dart';

class PlanDetail extends StatefulWidget {
  final PlanEntity planEntity;

  PlanDetail({Key key, @required this.planEntity}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new PlanDetailPage(planEntity);
}

class PlanDetailPage extends State<PlanDetail>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  final PlanEntity planEntity;

  PlanDetailPage(this.planEntity);

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 100), value: 1.0);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  bool get isPanelVisible {
    final AnimationStatus status = controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: new AnimatedIcon(
              icon: AnimatedIcons.close_menu,
              progress: controller.view,
            ),
            onPressed: () {
              controller.fling(velocity: isPanelVisible ? -1.0 : 1.0);
            },
          )
        ],
        elevation: 2.0,
        backgroundColor: Colors.black87,
        title: new Text(
          planEntity.name,
        ),
      ),
      body: new PlanDetailPanel(
        controller: controller,
        planEntity: planEntity,
      ),
    );
  }
}
