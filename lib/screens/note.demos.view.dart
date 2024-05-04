import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NoteDemos extends StatelessWidget {
  const NoteDemos({super.key});
  final _title = 'Create Your First Note';
  final _description = 'add a note baby girl ';
  final _createANote = 'Create a note';
  final _importeNotes = 'Importe notes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Padding(
        padding: PaddingItems.horizontalPadding,
        child: Column(
          children: [
            Image.asset(
              "lib/assets/png/image-02.png",
            ),
            _TittleWidget(title: _title),
            Padding(
              padding: PaddingItems.verticalPadding,
              child: _SubTittle(
                description: _description * 8,
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: SizedBox(
                height: ButtonHeight.buttonNormalHeight,
                child: Center(
                  child: Text(
                    _createANote,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
            ),

            TextButton(onPressed: () {}, child: Text(_importeNotes)),
            // const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class PaddingItems {
  static const EdgeInsets horizontalPadding =
      EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: 20);
}

class _TittleWidget extends StatelessWidget {
  const _TittleWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(color: Colors.black, fontWeight: FontWeight.w500),
    );
  }
}

class _SubTittle extends StatelessWidget {
  const _SubTittle({
    super.key,
    required this.description,
    this.textAlign,
  });
  final TextAlign? textAlign;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      textAlign: textAlign,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(color: Colors.black, fontWeight: FontWeight.w300),
    );
  }
}

class ButtonHeight {
  static const double buttonNormalHeight = 50;
}
