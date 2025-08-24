import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  final List<String> items = List.generate(20, (index) => 'Item ${index + 1}');

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Text('${index + 1}'),
          ),
          title: Text(items[index]),
          subtitle: Text('Description for ${items[index]}'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on ${items[index]}')),
            );
          },
        );
      },
    );
  }
}