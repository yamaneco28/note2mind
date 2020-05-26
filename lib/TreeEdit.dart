import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:note2mind/Node.dart';
import 'package:note2mind/Mindmap.dart';

List<Widget> widgetList;
Node currentNode;

class TreeEdit extends StatelessWidget {
  final String _current;
  final Function _onChanged;

  TreeEdit(this._current, this._onChanged);

  @override
  Widget build(BuildContext context) {
    final Node root = Node.readMarkdown(_current);

    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 60),
        child: Scaffold(
          appBar: _buildAppBar(context, root),
          body: TreeEditField(root: root, onChanged: _onChanged),
        ));
  }

  Widget _buildAppBar(BuildContext context, Node root) {
    return AppBar(
      title: TextField(
        controller: TextEditingController(text: root.title),
        focusNode: root.getFocusNode(),
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        onChanged: (text) {
          root.title = text;
          _onChanged(root.writeMarkdown());
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.image),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (BuildContext context) {
              return MindmapPage(root);
            }));
          },
        ),
      ],
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class TreeEditField extends StatefulWidget {
  TreeEditField({Key key, this.root, this.onChanged}) : super(key: key);

  final Node root;
  final Function onChanged;

  @override
  _TreeEditFieldState createState() => _TreeEditFieldState();
}

class _TreeEditFieldState extends State<TreeEditField> {
  _buildData(Node node, [int level = 0]) {
    node.children.forEach((child) {
      widgetList
          .add(Line(root: child, level: level, onChanged: widget.onChanged));
      _buildData(child, level + 1);
    });
  }

  @override
  void initState() {
    super.initState();

    widgetList = new List<Widget>();
    _buildData(widget.root);
  }

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 200), _onTimer);

    return SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: widgetList,
        ));
  }

  void _onTimer() {
    if (currentNode != null) currentNode.getFocusNode().requestFocus();
  }
}

class Line extends StatefulWidget {
  Line({Key key, this.root, this.level, this.onChanged}) : super(key: key);

  final Node root;
  final int level;
  final Function onChanged;

  @override
  _LineState createState() => _LineState();
}

class _LineState extends State<Line> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.startToEnd,
        child: Container(
          height: 30,
          child: _buildWrappedLine(widget.root),
        ),
        onDismissed: (direction) {
          setState(() {});
        });
  }

  Widget _buildLine(Node node) {
    return TextField(
      controller: TextEditingController(text: node.title),
      focusNode: node.getFocusNode(),
      decoration: InputDecoration(
        border: InputBorder.none,
      ),
      onChanged: (text) {
        node.title = text;
        widget.onChanged(widget.root.writeMarkdown());
      },
      onSubmitted: (text) {
        Node newNode;
        setState(() {
          newNode = node.getParent().insertChild(node, '');
          // widgetList.add(Line(
          //     root: newNode, level: widget.level, onChanged: widget.onChanged));
          widgetList.insert(widgetList.indexOf(widget) + 1,
            Line(root: newNode, level: widget.level + 1, onChanged: widget.onChanged));
        });
        currentNode = newNode;
        currentNode.getFocusNode().requestFocus();
      },
    );
  }

  Widget _buildWrappedLine(Node node) {
    return Row(children: <Widget>[
      SpaceBox.width(30 * widget.level.toDouble()),
      Icon(
        Icons.arrow_right,
        color: Colors.grey[300],
      ),
      Expanded(child: _buildLine(node)),
      Visibility(
        child: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.grey[700],
          ),
          onPressed: () {
            setState(() {
              node.remove();
            });
            widget.onChanged(widget.root.writeMarkdown());
          },
        ),
        visible: false,
      )
    ]);
  }
}

class SpaceBox extends SizedBox {
  SpaceBox({double width = 8, double height = 8})
      : super(width: width, height: height);

  SpaceBox.width([double value = 8]) : super(width: value);
  SpaceBox.height([double value = 8]) : super(height: value);
}
