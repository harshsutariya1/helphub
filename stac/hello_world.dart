import 'package:stac/stac_core.dart';

@StacScreen(screenName: "stac_widgets")
StacWidget helloWorld() {
  return StacScaffold(
    appBar: StacAppBar(
      leading: StacIconButton(
        onPressed: StacNavigator.pop(),
        icon: StacIcon(icon: 'arrow_back'),
      ),
    ),
    body: StacCenter(child: StacText(data: 'Hello, world!')),
  );
}
