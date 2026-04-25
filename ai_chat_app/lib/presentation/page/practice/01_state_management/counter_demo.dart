import 'package:flutter/material.dart';


class CounterButton extends StatefulWidget {
  const CounterButton({super.key});

  @override
  State<CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<CounterButton> {
  int _count = 0;  // 状态变量

  void _increment() {
    setState(() {
      _count++;  // 通知 Flutter 重新构建
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('点击了 $_count 次',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.blue),),
        ElevatedButton(
          onPressed: _increment,
          child: const Text('点击'),
        ),
        TextButton(
          onPressed: _increment, 
          child: const Text("文字按钮"),
        ),
        OutlinedButton(
          onPressed: _increment, 
          child: const Text("边框按钮")
        ),
        IconButton(
          onPressed: _increment, 
          icon: const Icon(Icons.settings)
        ),
        TextField(
          
          decoration: const InputDecoration(
            labelText: "用户名",
            hintText: '请输入用户名',
            prefixIcon: Icon(Icons.percent),
            border: OutlineInputBorder(),
          ),
        )
      ],
    );
  }
}