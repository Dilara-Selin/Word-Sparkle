import 'package:flutter/material.dart';

class TextLearnView extends StatelessWidget {
  const TextLearnView({super.key});
  final String name = 'veli';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        'Welcome $name ${name.length}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: const TextStyle(
            wordSpacing: 2,
            decoration: TextDecoration.overline,
            fontStyle: FontStyle.italic,
            letterSpacing: 2,
            color: Colors.purple,
            fontSize: 20,
            fontWeight: FontWeight.w600),
      ),
      Text(
        'Hello $name ${name.length}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: ProjectSyle.welcomeStyle,
      ),
      Text(
        'Hello $name ${name.length}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: Theme.of(context)
            .textTheme
            .headlineLarge
            ?.copyWith(color: Colors.yellow),
      )
    ])));
  }
}

class ProjectSyle {
  static TextStyle welcomeStyle = const TextStyle(
      wordSpacing: 2,
      decoration: TextDecoration.overline,
      fontStyle: FontStyle.italic,
      letterSpacing: 2,
      color: Colors.purple,
      fontSize: 20,
      fontWeight: FontWeight.w600);
}
